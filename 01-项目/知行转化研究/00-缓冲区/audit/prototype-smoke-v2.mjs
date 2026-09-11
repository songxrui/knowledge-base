import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { spawn } from "node:child_process";
import { tmpdir } from "node:os";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const chromePath = process.env.CHROME_PATH || "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe";
const auditDir = path.dirname(fileURLToPath(import.meta.url));
const outputDir = path.join(auditDir, "v2-screenshots");
mkdirSync(outputDir, { recursive: true });
const port = 20000 + Math.floor(Math.random() * 400);
const profileDir = mkdtempSync(path.join(tmpdir(), "codex-v2-browser-"));
const pageUrl = pathToFileURL(path.resolve(auditDir, "..", "prototype", "index.html")).href;
const chrome = spawn(chromePath, [
  "--headless=new", "--disable-gpu", "--hide-scrollbars", "--no-first-run",
  "--no-default-browser-check", "--allow-file-access-from-files",
  `--remote-debugging-port=${port}`, `--user-data-dir=${profileDir}`, "about:blank",
], { stdio: ["ignore", "ignore", "pipe"] });
let chromeError = "";
chrome.stderr.on("data", (chunk) => { chromeError += chunk.toString(); });

const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
async function getJson(url) {
  const deadline = Date.now() + 12000;
  while (Date.now() < deadline) {
    try { const response = await fetch(url); if (response.ok) return response.json(); } catch {}
    await wait(100);
  }
  throw new Error(`Chrome CDP unavailable: ${chromeError.slice(-400)}`);
}

class CdpClient {
  constructor(url) { this.socket = new WebSocket(url); this.seq = 0; this.pending = new Map(); }
  async open() {
    await new Promise((resolve, reject) => {
      const timer = setTimeout(() => reject(new Error("CDP WebSocket timeout")), 8000);
      this.socket.addEventListener("open", () => { clearTimeout(timer); resolve(); }, { once: true });
      this.socket.addEventListener("error", reject, { once: true });
    });
    this.socket.addEventListener("message", (event) => {
      const message = JSON.parse(event.data);
      if (message.id && this.pending.has(message.id)) {
        const { resolve, reject } = this.pending.get(message.id);
        this.pending.delete(message.id);
        if (message.error) reject(new Error(message.error.message)); else resolve(message.result);
      }
    });
  }
  send(method, params = {}) {
    const id = ++this.seq;
    return new Promise((resolve, reject) => { this.pending.set(id, { resolve, reject }); this.socket.send(JSON.stringify({ id, method, params })); });
  }
  close() { this.socket.close(); }
}

async function evaluate(client, expression, returnByValue = true) {
  const result = await client.send("Runtime.evaluate", { expression, returnByValue, awaitPromise: true });
  if (result.exceptionDetails) throw new Error(result.exceptionDetails.exception?.description || "Runtime evaluation failed");
  return result.result.value;
}
async function run(client, fn, ...args) {
  return evaluate(client, `(${fn.toString()})(${args.map((arg) => JSON.stringify(arg)).join(",")})`);
}
async function navigate(client) {
  await client.send("Page.navigate", { url: pageUrl });
  await wait(450);
}
async function viewport(client, width, height = 900, scale = 1) {
  await client.send("Emulation.setDeviceMetricsOverride", { width, height, deviceScaleFactor: scale, mobile: false });
}
async function media(client, features = []) {
  await client.send("Emulation.setEmulatedMedia", { media: "screen", features });
}
async function screenshot(client, name) {
  const result = await client.send("Page.captureScreenshot", { format: "png" });
  const file = path.join(outputDir, name);
  writeFileSync(file, Buffer.from(result.data, "base64"));
  assert.ok(existsSync(file), `screenshot missing: ${name}`);
  return file;
}
async function setValue(client, id, value) {
  await run(client, (fieldId, fieldValue) => {
    const field = document.getElementById(fieldId);
    field.value = fieldValue;
    field.dispatchEvent(new Event("input", { bubbles: true }));
    field.dispatchEvent(new Event("change", { bubbles: true }));
  }, id, value);
}
async function click(client, id) { await run(client, (buttonId) => document.getElementById(buttonId).click(), id); await wait(80); }
async function submit(client, id) { await run(client, (formId) => document.getElementById(formId).requestSubmit(), id); await wait(120); }
async function key(client, value) {
  const keyCode = { Escape: 27, Enter: 13, " ": 32 }[value] || 0;
  const code = value === " " ? "Space" : value;
  await client.send("Input.dispatchKeyEvent", { type: "keyDown", key: value, code, windowsVirtualKeyCode: keyCode, nativeVirtualKeyCode: keyCode });
  if (value === "Enter" || value === " ") {
    await client.send("Input.dispatchKeyEvent", { type: "char", key: value === " " ? " " : "\r", text: value === " " ? " " : "\r" });
  }
  await client.send("Input.dispatchKeyEvent", { type: "keyUp", key: value, code, windowsVirtualKeyCode: keyCode, nativeVirtualKeyCode: keyCode });
  await wait(100);
}
async function health(client) {
  return run(client, () => ({
    workspace: document.body.dataset.workspace,
    visibleSections: [...document.querySelectorAll(".workspace-section")].filter((section) => !section.hidden).map((section) => section.id),
    visibleForms: [...document.querySelectorAll("form")].filter((form) => !form.hidden && form.closest(".workspace-section") && !form.closest(".workspace-section").hidden).map((form) => form.id),
    primaryButtons: [...document.querySelectorAll(".workspace-section:not([hidden]) .button.primary")].filter((button) => !button.hidden).map((button) => button.id || button.textContent.trim()),
    globalPrimaryButtons: [...document.querySelectorAll("#next-action-button, .workspace-section:not([hidden]) .button.primary")].filter((button) => !button.hidden).map((button) => button.id || button.textContent.trim()),
    currentStep: document.querySelector('.step-tab[aria-current="step"]')?.id || null,
    width: innerWidth,
    documentWidth: document.documentElement.scrollWidth,
    overflow: document.documentElement.scrollWidth - innerWidth,
    ledgerCards: document.querySelectorAll("#observation-list .ledger-item").length,
    ledgerRows: document.querySelectorAll("#observation-table-body tr").length,
    stage: document.querySelector("[data-contract-stage]:not([hidden])")?.dataset.contractStage || null,
  }));
}

const evidence = { command: "node 00-缓冲区/audit/prototype-smoke-v2.mjs", screenshots: [], states: [], preferenceChecks: [] };
const sha256 = (file) => createHash("sha256").update(readFileSync(file)).digest("hex").toUpperCase();
evidence.artifacts = Object.fromEntries([
  "index.html", "styles.css", "app.js", "logic.js", "ui-state.js", "tests.mjs",
].map((name) => [name, sha256(path.resolve(auditDir, "..", "prototype", name))]));
evidence.artifacts["prototype-smoke-v2.mjs"] = sha256(fileURLToPath(import.meta.url));
let client;
try {
  const targets = await getJson(`http://127.0.0.1:${port}/json/list`);
  const target = targets.find((item) => item.type === "page");
  if (!target) throw new Error("Chrome page target unavailable");
  client = new CdpClient(target.webSocketDebuggerUrl);
  await client.open();
  await client.send("Page.enable");
  await client.send("Runtime.enable");
  await navigate(client);
  await run(client, () => localStorage.clear());
  await navigate(client);

  await viewport(client, 320);
  const empty = await health(client);
  assert.deepEqual(empty.visibleSections, ["goal-section"]);
  assert.equal(empty.overflow, 0);
  assert.equal(empty.globalPrimaryButtons.length, 1);
  evidence.states.push({ name: "empty", health: empty });
  evidence.screenshots.push(await screenshot(client, "goal-320.png"));
  await submit(client, "goal-form");
  const goalError = await run(client, () => ({
    invalid: document.getElementById("goal-title").getAttribute("aria-invalid"),
    describedBy: document.getElementById("goal-title").getAttribute("aria-describedby"),
    error: document.getElementById("goal-title-error").textContent,
    focused: document.activeElement.id,
  }));
  assert.equal(goalError.invalid, "true");
  assert.equal(goalError.focused, "goal-title");
  evidence.states.push({ name: "goal-field-error", detail: goalError });

  await viewport(client, 1024);
  await setValue(client, "goal-title", "完成一次低风险访谈");
  await setValue(client, "goal-why", "确认真实机会是否存在");
  await submit(client, "goal-form");
  const contractStageOne = await health(client);
  assert.deepEqual(contractStageOne.visibleSections, ["contract-section"]);
  assert.equal(contractStageOne.stage, "1");
  assert.equal(contractStageOne.globalPrimaryButtons.length, 1);
  evidence.states.push({ name: "contract-stage-1", health: contractStageOne });
  evidence.screenshots.push(await screenshot(client, "contract-stage-1-1024.png"));
  await click(client, "contract-next-button");
  const contractError = await run(client, () => ({
    invalid: document.getElementById("contract-activity").getAttribute("aria-invalid"),
    focused: document.activeElement.id,
    error: document.getElementById("contract-activity-error").textContent,
  }));
  assert.equal(contractError.invalid, "true");
  assert.equal(contractError.focused, "contract-activity");
  evidence.states.push({ name: "contract-field-error", detail: contractError });

  await setValue(client, "contract-activity", "把一页访谈提纲发给已同意接收的人");
  await setValue(client, "contract-evidence", "保留发送时间与对方是否回复");
  await click(client, "contract-next-button");
  assert.equal((await health(client)).stage, "2");
  await setValue(client, "contract-due", "2099-12-31");
  await setValue(client, "contract-timebox", "15");
  await setValue(client, "metric-one-name", "有效回复");
  await setValue(client, "metric-one-unit", "条");
  await click(client, "contract-next-button");
  assert.equal((await health(client)).stage, "3");
  await setValue(client, "contract-rule", "有明确回复就保持；没有机会就记录原因。");
  await click(client, "lock-contract-button");
  const observation = await health(client);
  assert.deepEqual(observation.visibleSections, ["observation-section"]);
  assert.equal(observation.primaryButtons.length, 1);
  assert.equal(observation.globalPrimaryButtons.length, 1);
  evidence.states.push({ name: "observation", health: observation });
  evidence.screenshots.push(await screenshot(client, "observation-1024.png"));

  await click(client, "step-ledger");
  const emptyLedger = await run(client, () => ({
    health: {
      workspace: document.body.dataset.workspace,
      visibleSections: [...document.querySelectorAll(".workspace-section")].filter((section) => !section.hidden).map((section) => section.id),
    },
    emptyText: document.getElementById("empty-ledger").textContent,
    emptyVisible: !document.getElementById("empty-ledger").hidden,
  }));
  assert.deepEqual(emptyLedger.health.visibleSections, ["ledger-section"]);
  assert.equal(emptyLedger.emptyVisible, true);
  evidence.states.push({ name: "empty-ledger", detail: emptyLedger });
  await click(client, "step-observation");

  await setValue(client, "observation-note", "今天留下了一条可回看的事实。");
  await submit(client, "observation-form");
  const ledger = await health(client);
  assert.deepEqual(ledger.visibleSections, ["ledger-section"]);
  assert.equal(ledger.ledgerCards, 1);
  assert.equal(ledger.globalPrimaryButtons.length, 1);
  evidence.states.push({ name: "ledger-current", health: ledger });
  evidence.screenshots.push(await screenshot(client, "ledger-1024.png"));

  const revisionBefore = await run(client, () => localStorage.getItem(window.NextEvidence.STORAGE_KEY));
  await click(client, "step-contract");
  await click(client, "revise-contract-button");
  await setValue(client, "contract-activity", "不应保存的修订草稿");
  await click(client, "cancel-revision-button");
  const revisionCancel = await run(client, (before) => ({
    unchanged: localStorage.getItem(window.NextEvidence.STORAGE_KEY) === before,
    workspace: document.body.dataset.workspace,
    version: document.getElementById("contract-version").textContent,
  }), revisionBefore);
  assert.equal(revisionCancel.unchanged, true);
  assert.equal(revisionCancel.version, "v1 已锁定");
  evidence.states.push({ name: "cancel-revision-preserves-v1", detail: revisionCancel });

  await run(client, () => {
    const logic = window.NextEvidence;
    let state = logic.createState("2026-07-12T08:00:00.000Z");
    state = logic.createGoal(state, { title: "历史版本展示", why: "验证回查", riskLevel: "low" }, "2026-07-12T08:01:00.000Z");
    const input = { activity: "第一版活动", evidence: "第一版事实", dueDate: "2099-12-31", timeboxMinutes: 10, contactMode: "direct", metrics: [{ name: "回复", unit: "条" }], decisionRule: "保持" };
    state = logic.lockContractVersion(state, input, "2026-07-12T08:02:00.000Z");
    state = logic.recordObservation(state, { contractId: state.contracts[0].id, date: "2026-07-13", opportunity: "available", evidenceObserved: true, minutes: 10, metricValues: {}, decision: "keep", note: "v1事实" }, "2026-07-13T08:00:00.000Z");
    state = logic.lockContractVersion(state, { ...input, activity: "第二版活动" }, "2026-07-14T08:00:00.000Z");
    state = logic.recordObservation(state, { contractId: state.contracts[1].id, date: "2026-07-14", opportunity: "available", evidenceObserved: false, minutes: 10, metricValues: {}, decision: "keep", note: "v2事实" }, "2026-07-14T08:00:00.000Z");
    localStorage.setItem(logic.STORAGE_KEY, logic.exportState(state));
  });
  await navigate(client);
  await viewport(client, 390);
  await click(client, "step-ledger");
  const currentHistory = await health(client);
  assert.deepEqual(currentHistory.visibleSections, ["ledger-section"]);
  assert.equal(currentHistory.ledgerCards, 1);
  assert.equal(currentHistory.overflow, 0);
  await click(client, "ledger-all-button");
  const allHistory = await health(client);
  assert.equal(allHistory.ledgerCards, 2);
  assert.equal(allHistory.overflow, 0);
  evidence.states.push({ name: "ledger-all-history-390", health: allHistory });
  evidence.screenshots.push(await screenshot(client, "ledger-all-history-390.png"));

  for (const width of [320, 390, 735, 1024, 1440]) {
    await viewport(client, width);
    const stateHealth = await health(client);
    assert.equal(stateHealth.overflow, 0, `horizontal overflow at ${width}px`);
    evidence.states.push({ name: `history-${width}`, health: stateHealth });
    evidence.screenshots.push(await screenshot(client, `history-${width}.png`));
  }
  for (const scale of [1, 1.25, 1.5, 2]) {
    await viewport(client, 1024, 900, scale);
    const scaled = await health(client);
    assert.equal(scaled.overflow, 0, `horizontal overflow at scale ${scale}`);
    evidence.preferenceChecks.push({ type: "device-scale-factor", scale, health: scaled });
  }
  for (const [name, features] of [
    ["dark", [{ name: "prefers-color-scheme", value: "dark" }]],
    ["high-contrast", [{ name: "prefers-contrast", value: "more" }]],
    ["reduced-motion", [{ name: "prefers-reduced-motion", value: "reduce" }]],
  ]) {
    await media(client, features);
    await viewport(client, 390);
    const preference = await health(client);
    assert.equal(preference.overflow, 0, `overflow in ${name}`);
    evidence.preferenceChecks.push({ type: name, health: preference });
    if (name === "dark") {
      const styleProbe = await run(client, () => {
        const button = document.querySelector(".button.primary");
        const label = document.querySelector(".field > span");
        const status = document.querySelector(".status-label");
        const buttonStyle = getComputedStyle(button);
        const labelStyle = getComputedStyle(label);
        const statusStyle = getComputedStyle(status);
        return {
          buttonColor: buttonStyle.color,
          buttonBackground: buttonStyle.backgroundColor,
          buttonMinHeight: buttonStyle.minHeight,
          buttonRadius: buttonStyle.borderRadius,
          labelColor: labelStyle.color,
          statusColor: statusStyle.color,
          statusRadius: statusStyle.borderRadius,
          opportunityColor: getComputedStyle(document.querySelector(".segmented-control input:checked + span")).color,
          opportunityBackground: getComputedStyle(document.querySelector(".segmented-control input:checked + span")).backgroundColor,
          opportunityMinHeight: getComputedStyle(document.querySelector(".segmented-control input:checked + span")).minHeight,
          subgridBackground: getComputedStyle(document.querySelector(".subgrid")).backgroundColor,
        };
      });
      assert.equal(styleProbe.buttonMinHeight, "44px");
      assert.equal(styleProbe.buttonRadius, "8px");
      assert.notEqual(styleProbe.buttonColor, "rgb(255, 255, 255)");
      assert.equal(styleProbe.statusRadius, "999px");
      assert.equal(styleProbe.opportunityMinHeight, "44px");
      assert.notEqual(styleProbe.subgridBackground, "rgb(244, 247, 245)");
      evidence.preferenceChecks.push({ type: "dark-computed-style", styleProbe });
    }
    evidence.screenshots.push(await screenshot(client, `history-${name}-390.png`));
  }
  await media(client, []);
  await run(client, () => document.body.dataset.reducedTransparency = "true");
  evidence.preferenceChecks.push({ type: "reduced-transparency-fallback", health: await health(client) });

  await click(client, "data-menu-button");
  await click(client, "import-button");
  await setValue(client, "import-text", "{invalid");
  await click(client, "confirm-import-button");
  const invalidImport = await run(client, () => ({
    open: document.getElementById("import-dialog").open,
    invalid: document.getElementById("import-text").getAttribute("aria-invalid"),
    error: document.getElementById("import-message").textContent,
    rowsPreserved: document.querySelectorAll("#observation-table-body tr").length,
  }));
  assert.equal(invalidImport.open, true);
  assert.equal(invalidImport.invalid, "true");
  assert.equal(invalidImport.rowsPreserved, 2);
  await key(client, "Escape");
  const focusReturn = await run(client, () => ({ open: document.getElementById("import-dialog").open, focused: document.activeElement.id }));
  assert.equal(focusReturn.open, false);
  assert.equal(focusReturn.focused, "import-button");
  evidence.states.push({ name: "invalid-import-and-focus-return", detail: { ...invalidImport, ...focusReturn } });

  await run(client, () => localStorage.clear());
  await navigate(client);
  await setValue(client, "goal-title", "高风险模拟检查");
  await setValue(client, "goal-risk", "high");
  await submit(client, "goal-form");
  await setValue(client, "contract-activity", "仅做有界模拟");
  await setValue(client, "contract-evidence", "保留模拟输出");
  await click(client, "contract-next-button");
  await click(client, "contract-next-button");
  const highRisk = await run(client, () => ({
    stage: document.querySelector("[data-contract-stage]:not([hidden])")?.dataset.contractStage,
    mode: document.getElementById("contact-mode").value,
    invalid: document.getElementById("contact-mode").getAttribute("aria-invalid"),
    activityPreserved: document.getElementById("contract-activity").value,
    safetyVisible: !document.getElementById("safety-boundary").hidden,
  }));
  assert.equal(highRisk.stage, "2");
  assert.equal(highRisk.mode, "direct");
  assert.equal(highRisk.invalid, "true");
  assert.equal(highRisk.activityPreserved, "仅做有界模拟");
  assert.equal(highRisk.safetyVisible, true);
  evidence.states.push({ name: "high-risk-conflict-preserves-input", detail: highRisk });

  await setValue(client, "contact-mode", "simulation");
  await setValue(client, "contract-due", "2099-12-31");
  await setValue(client, "contract-timebox", "10");
  await setValue(client, "metric-one-name", "模拟输出");
  await click(client, "contract-next-button");
  await setValue(client, "contract-rule", "输出可复述就保持，否则退出。");
  await click(client, "lock-contract-button");

  const conflictBefore = await run(client, () => localStorage.getItem(window.NextEvidence.STORAGE_KEY));
  await run(client, () => window.dispatchEvent(new StorageEvent("storage", { key: window.NextEvidence.STORAGE_KEY, newValue: "other-tab" })));
  const conflict = await run(client, (before) => ({ message: document.getElementById("message").textContent, preserved: localStorage.getItem(window.NextEvidence.STORAGE_KEY) === before }), conflictBefore);
  assert.match(conflict.message, /另一标签页/);
  assert.equal(conflict.preserved, true);
  evidence.states.push({ name: "cross-tab-conflict", detail: { ...conflict, before: conflictBefore } });

  await run(client, () => { window.confirm = () => false; });
  const clearBefore = await run(client, () => localStorage.getItem(window.NextEvidence.STORAGE_KEY));
  await click(client, "data-menu-button");
  await click(client, "clear-button");
  const clearCancel = await run(client, (before) => ({ unchanged: localStorage.getItem(window.NextEvidence.STORAGE_KEY) === before, goalStatus: document.getElementById("goal-status").textContent }), clearBefore);
  assert.equal(clearCancel.unchanged, true);
  evidence.states.push({ name: "clear-cancel-preserves-data", detail: clearCancel });

  await setValue(client, "observation-decision", "exit");
  await setValue(client, "observation-note", "取消退出，继续观察。");
  const exitCancelBefore = await run(client, () => localStorage.getItem(window.NextEvidence.STORAGE_KEY));
  await submit(client, "observation-form");
  const exitCancel = await run(client, (before) => ({ unchanged: localStorage.getItem(window.NextEvidence.STORAGE_KEY) === before, workspace: document.body.dataset.workspace }), exitCancelBefore);
  assert.equal(exitCancel.unchanged, true);
  assert.equal(exitCancel.workspace, "observation");
  evidence.states.push({ name: "exit-cancel-preserves-data", detail: exitCancel });

  await run(client, () => { window.confirm = () => true; });
  await submit(client, "observation-form");
  const exited = await run(client, () => ({ workspace: document.body.dataset.workspace, goalStatus: document.getElementById("goal-status").textContent, visibleSections: [...document.querySelectorAll(".workspace-section")].filter((section) => !section.hidden).map((section) => section.id) }));
  assert.equal(exited.workspace, "ledger");
  assert.equal(exited.goalStatus, "已退出");
  assert.deepEqual(exited.visibleSections, ["ledger-section"]);
  evidence.states.push({ name: "exit-success", detail: exited });

  await run(client, () => { document.getElementById("ledger-current-button").focus(); });
  const focusBeforeTab = await run(client, () => document.activeElement.id);
  await key(client, "Tab");
  const focusAfterTab = await run(client, () => document.activeElement.id);
  assert.notEqual(focusAfterTab, focusBeforeTab);
  await run(client, () => document.getElementById("ledger-current-button").focus());
  await client.send("Input.dispatchKeyEvent", { type: "keyDown", key: "Tab", code: "Tab", modifiers: 8 });
  await client.send("Input.dispatchKeyEvent", { type: "keyUp", key: "Tab", code: "Tab", modifiers: 8 });
  const focusAfterShiftTab = await run(client, () => document.activeElement.id);
  assert.notEqual(focusAfterShiftTab, "ledger-current-button");
  await run(client, () => document.getElementById("ledger-all-button").focus());
  await key(client, "Enter");
  const enterActivated = await run(client, () => document.getElementById("ledger-all-button").getAttribute("aria-pressed"));
  assert.equal(enterActivated, "true");
  await run(client, () => document.getElementById("ledger-current-button").focus());
  await key(client, " ");
  const spaceActivated = await run(client, () => document.getElementById("ledger-current-button").getAttribute("aria-pressed"));
  assert.equal(spaceActivated, "true");
  evidence.states.push({ name: "keyboard-tab-shift-tab-enter-space", detail: { focusBeforeTab, focusAfterTab, focusAfterShiftTab, enterActivated, spaceActivated } });

  await run(client, () => { localStorage.setItem(window.NextEvidence.STORAGE_KEY, "{broken"); location.reload(); });
  await wait(500);
  const recovery = await health(client);
  assert.deepEqual(recovery.visibleSections, ["recovery-panel"]);
  evidence.states.push({ name: "recovery", health: recovery });
  evidence.screenshots.push(await screenshot(client, "recovery-390.png"));

  client.close();
  evidence.screenshotHashes = Object.fromEntries(evidence.screenshots.map((file) => [path.basename(file), sha256(file)]));
  writeFileSync(path.join(auditDir, "prototype-smoke-v2.json"), JSON.stringify(evidence, null, 2));
  console.log(JSON.stringify(evidence, null, 2));
} catch (error) {
  throw error;
} finally {
  client?.close();
  chrome.kill();
  await wait(900);
  try {
    rmSync(profileDir, { recursive: true, force: true, maxRetries: 8, retryDelay: 250 });
  } catch (error) {
    if (error.code === "EBUSY" || error.code === "EPERM") {
      console.warn(`Chrome profile cleanup deferred: ${error.code}`);
    } else {
      throw error;
    }
  }
}
