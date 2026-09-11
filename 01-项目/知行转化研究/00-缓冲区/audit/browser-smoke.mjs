import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { existsSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const auditDir = path.dirname(fileURLToPath(import.meta.url));
const chromePath = process.env.CHROME_PATH
  || "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe";
const port = 19000 + Math.floor(Math.random() * 800);
const baseUrl = process.env.BASE_URL || "http://127.0.0.1:8765";

if (!existsSync(chromePath)) {
  throw new Error("Chrome executable was not found.");
}
const profileRoot = path.resolve(tmpdir());
const profileDir = mkdtempSync(path.join(profileRoot, "codex-browser-"));

const chrome = spawn(
  chromePath,
  [
    "--headless=new",
    "--disable-gpu",
    "--hide-scrollbars",
    "--no-first-run",
    "--no-default-browser-check",
    "--remote-debugging-port=" + port,
    "--user-data-dir=" + profileDir,
    "about:blank",
  ],
  { stdio: ["ignore", "ignore", "pipe"] },
);

let chromeError = "";
chrome.stderr.on("data", (chunk) => {
  chromeError += chunk.toString();
});

function delay(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

async function getJson(url, options) {
  const response = await fetch(url, options);
  if (!response.ok) throw new Error("CDP HTTP " + response.status + ": " + url);
  return response.json();
}

async function waitForDebugger() {
  const deadline = Date.now() + 12_000;
  while (Date.now() < deadline) {
    try {
      return await getJson("http://127.0.0.1:" + port + "/json/version");
    } catch {
      await delay(120);
    }
  }
  throw new Error("Chrome DevTools did not start. " + chromeError.slice(-500));
}

class CdpClient {
  constructor(url) {
    this.sequence = 0;
    this.pending = new Map();
    this.listeners = new Map();
    this.socket = new WebSocket(url);
  }

  async open() {
    if (this.socket.readyState === WebSocket.OPEN) return;
    await new Promise((resolve, reject) => {
      const timeout = setTimeout(() => reject(new Error("WebSocket open timed out.")), 8_000);
      this.socket.addEventListener("open", () => {
        clearTimeout(timeout);
        resolve();
      }, { once: true });
      this.socket.addEventListener("error", () => {
        clearTimeout(timeout);
        reject(new Error("WebSocket failed to open."));
      }, { once: true });
    });
  }

  on(method, listener) {
    const current = this.listeners.get(method) || [];
    current.push(listener);
    this.listeners.set(method, current);
  }

  installMessageHandler() {
    this.socket.addEventListener("message", (event) => {
      const message = JSON.parse(event.data);
      if (message.id) {
        const pending = this.pending.get(message.id);
        if (!pending) return;
        this.pending.delete(message.id);
        if (message.error) {
          pending.reject(new Error(message.error.code + ": " + message.error.message));
        } else {
          pending.resolve(message.result);
        }
        return;
      }
      (this.listeners.get(message.method) || []).forEach((listener) => listener(message.params));
    });
  }

  send(method, params = {}) {
    const id = ++this.sequence;
    const result = new Promise((resolve, reject) => {
      this.pending.set(id, { resolve, reject });
    });
    this.socket.send(JSON.stringify({ id, method, params }));
    return result;
  }

  waitFor(method, timeoutMilliseconds = 8_000) {
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => reject(new Error(method + " timed out.")), timeoutMilliseconds);
      const listener = (params) => {
        clearTimeout(timeout);
        const current = this.listeners.get(method) || [];
        this.listeners.set(method, current.filter((item) => item !== listener));
        resolve(params);
      };
      this.on(method, listener);
    });
  }

  close() {
    this.socket.close();
  }
}

async function evaluate(client, expression) {
  const response = await client.send("Runtime.evaluate", {
    expression,
    awaitPromise: true,
    returnByValue: true,
  });
  if (response.exceptionDetails) {
    const description = response.exceptionDetails.exception
      && response.exceptionDetails.exception.description;
    throw new Error(description || response.exceptionDetails.text || "Page evaluation failed.");
  }
  return response.result.value;
}

function callInPage(client, fn, argument) {
  const serialized = typeof argument === "undefined" ? "" : JSON.stringify(argument);
  return evaluate(client, "(" + fn.toString() + ")(" + serialized + ")");
}

async function setViewport(client, width, height, mobile) {
  await client.send("Emulation.setDeviceMetricsOverride", {
    width,
    height,
    deviceScaleFactor: 1,
    mobile,
    screenWidth: width,
    screenHeight: height,
  });
}

async function navigate(client, url) {
  const loaded = client.waitFor("Page.loadEventFired");
  await client.send("Page.navigate", { url });
  await loaded;
  await delay(180);
}

async function screenshot(client, filename) {
  const result = await client.send("Page.captureScreenshot", {
    format: "png",
    fromSurface: true,
    captureBeyondViewport: false,
  });
  const target = path.join(auditDir, filename);
  const bytes = Buffer.from(result.data, "base64");
  writeFileSync(target, bytes);
  assert.ok(bytes.length > 10_000, filename + " appears blank or incomplete.");
  return { filename, bytes: bytes.length };
}

function getPageHealth() {
  const visible = (element) => {
    const style = getComputedStyle(element);
    return style.display !== "none" && style.visibility !== "hidden";
  };
  const topbar = document.querySelector(".topbar");
  const topbarBackground = topbar ? getComputedStyle(topbar).backgroundColor : "";
  const topbarChannels = topbarBackground.match(/[\d.]+/g)?.map(Number) || [];
  const offenders = [...document.querySelectorAll("body *")]
    .filter(visible)
    .filter((element) => {
      if (element.closest(".table-wrap")) return false;
      const rect = element.getBoundingClientRect();
      return rect.left < -1 || rect.right > innerWidth + 1;
    })
    .slice(0, 12)
    .map((element) => {
      const rect = element.getBoundingClientRect();
      return {
        tag: element.tagName,
        id: element.id,
        className: String(element.className || ""),
        text: String(element.textContent || "").trim().slice(0, 50),
        left: Math.round(rect.left),
        right: Math.round(rect.right),
      };
    });
  return {
    title: document.title,
    innerWidth,
    innerHeight,
    documentWidth: document.documentElement.scrollWidth,
    bodyWidth: document.body.scrollWidth,
    topbarBackgroundAlpha: topbarChannels.length === 4 ? topbarChannels[3] : 1,
    offenders,
  };
}

let client;
try {
  await waitForDebugger();
  const pages = await getJson("http://127.0.0.1:" + port + "/json/list");
  const page = pages.find((item) => item.type === "page");
  if (!page) throw new Error("No Chrome page target was found.");

  client = new CdpClient(page.webSocketDebuggerUrl);
  await client.open();
  client.installMessageHandler();

  const requests = [];
  const runtimeErrors = [];
  client.on("Network.requestWillBeSent", ({ request }) => requests.push(request.url));
  client.on("Network.loadingFailed", ({ errorText, canceled }) => {
    if (!canceled) runtimeErrors.push({ type: "network", text: errorText });
  });
  client.on("Runtime.exceptionThrown", ({ exceptionDetails }) => {
    runtimeErrors.push({
      type: "runtime",
      text: exceptionDetails.text,
      description: exceptionDetails.exception && exceptionDetails.exception.description,
      url: exceptionDetails.url,
      lineNumber: exceptionDetails.lineNumber,
      columnNumber: exceptionDetails.columnNumber,
    });
  });
  client.on("Log.entryAdded", ({ entry }) => {
    if (entry.level === "error") {
      runtimeErrors.push({
        type: "log",
        text: entry.text,
        url: entry.url,
        lineNumber: entry.lineNumber,
      });
    }
  });

  await Promise.all([
    client.send("Page.enable"),
    client.send("Runtime.enable"),
    client.send("Network.enable"),
    client.send("Log.enable"),
  ]);

  await setViewport(client, 1440, 1000, false);
  await navigate(client, baseUrl + "/diagnostic-tool/");
  const diagnosticInitial = await callInPage(client, getPageHealth);
  const diagnosticInitialExtra = await callInPage(client, function () {
    return {
      questionCount: document.querySelectorAll("fieldset.question").length,
      scriptReady: Boolean(window.RouterLogic),
    };
  });
  assert.equal(diagnosticInitialExtra.scriptReady, true);
  assert.ok(diagnosticInitialExtra.questionCount >= 9);
  assert.equal(diagnosticInitial.documentWidth, diagnosticInitial.innerWidth);

  await callInPage(client, function () {
    localStorage.clear();
    const answers = Object.fromEntries(RouterLogic.QUESTION_IDS.map((id) => [id, "no"]));
    Object.assign(answers, {
      U0: "no",
      G1: "yes", G2: "yes", G3: "yes", G4: "no",
      P1: "yes", P2: "yes", P3: "yes", P4: "no",
      R1: "yes", R2: "no", R3: "no",
      K1: "yes", K2: "yes", K3: "no",
      A1: "yes", A2: "yes", A3: "yes", A4: "yes",
      F1: "yes", F2: "yes", F3: "yes", F4: "yes",
      W1: "yes", W2: "no", W3: "no", W4: "no",
      M1: "no", M2: "yes", M3: "yes",
      S1: "no", S2: "no", S3: "no",
    });
    const goal = document.querySelector("#goal");
    goal.value = "向三位目标用户展示可点击原型";
    goal.dispatchEvent(new Event("input", { bubbles: true }));
    document.querySelector("#context").value = "只用于浏览器隐私测试";
    for (const [id, value] of Object.entries(answers)) {
      const selector = 'input[name="answer-' + id + '"][value="' + value + '"]';
      const input = document.querySelector(selector);
      if (!input) throw new Error("Missing answer input " + id + "=" + value);
      input.checked = true;
      input.dispatchEvent(new Event("change", { bubbles: true }));
    }
    document.querySelector("#router-form").requestSubmit();
  });
  await delay(120);

  const diagnosticResult = await callInPage(client, function () {
    const saved = JSON.parse(localStorage.getItem("next-step-router-draft-v1"));
    return {
      resultsVisible: !document.querySelector("#results").hidden,
      findingCount: document.querySelectorAll(".finding-card").length,
      routeText: document.querySelector("#route-result").textContent.trim().slice(0, 120),
      savedSensitiveIds: ["U0", "S1", "S2", "S3"].filter(
        (id) => Object.hasOwn(saved.answers, id),
      ),
    };
  });
  assert.equal(diagnosticResult.resultsVisible, true);
  assert.equal(diagnosticResult.findingCount, 9);
  assert.deepEqual(diagnosticResult.savedSensitiveIds, []);
  await callInPage(client, function () {
    document.documentElement.style.scrollBehavior = "auto";
    document.querySelector("#results").scrollIntoView({ block: "start", behavior: "auto" });
  });
  await delay(60);
  const diagnosticDesktopHealth = await callInPage(client, getPageHealth);
  assert.equal(diagnosticDesktopHealth.documentWidth, diagnosticDesktopHealth.innerWidth);
  const diagnosticDesktopShot = await screenshot(client, "diagnostic-result-desktop.png");

  await setViewport(client, 390, 844, true);
  await delay(120);
  await callInPage(client, function () {
    document.documentElement.style.scrollBehavior = "auto";
    document.querySelector("#results").scrollIntoView({ block: "start", behavior: "auto" });
  });
  await delay(60);
  const diagnosticMobile = await callInPage(client, getPageHealth);
  assert.equal(diagnosticMobile.innerWidth, 390);
  assert.equal(diagnosticMobile.documentWidth, 390);
  assert.equal(diagnosticMobile.topbarBackgroundAlpha, 1);
  assert.deepEqual(diagnosticMobile.offenders, []);
  const diagnosticMobileShot = await screenshot(client, "diagnostic-result-mobile.png");

  await setViewport(client, 1440, 1000, false);
  await navigate(client, baseUrl + "/00-%E7%BC%93%E5%86%B2%E5%8C%BA/prototype/");
  const reloaded = client.waitFor("Page.loadEventFired");
  await callInPage(client, function () {
    localStorage.clear();
    location.reload();
  });
  await reloaded;
  await delay(120);

  const productInitial = await callInPage(client, getPageHealth);
  const productInitialExtra = await callInPage(client, function () {
    return {
      logicReady: Boolean(window.NextEvidence),
      nextAction: document.querySelector("#next-action-title").textContent.trim(),
      currentStep: document.querySelector(".step-tab.is-current")?.id || "",
      contractLocked: document.querySelector("#step-contract").disabled,
      recoveryHidden: document.querySelector("#recovery-panel").hidden,
    };
  });
  assert.equal(productInitialExtra.logicReady, true);
  assert.equal(productInitialExtra.nextAction, "确认一个目标");
  assert.equal(productInitialExtra.currentStep, "step-goal");
  assert.equal(productInitialExtra.contractLocked, true);
  assert.equal(productInitialExtra.recoveryHidden, true);
  assert.equal(productInitial.documentWidth, productInitial.innerWidth);

  await callInPage(client, function () {
    const set = (selector, value) => {
      const element = document.querySelector(selector);
      element.value = value;
      element.dispatchEvent(new Event("input", { bubbles: true }));
      element.dispatchEvent(new Event("change", { bubbles: true }));
    };
    set("#goal-title", "向三位目标用户展示可点击原型");
    set("#goal-why", "决定是否继续开发，而不是证明自己会成功");
    set("#goal-risk", "low");
    document.querySelector("#goal-form").requestSubmit();

    set("#contract-activity", "在预约的访谈中展示同一个原型");
    set("#contract-evidence", "三份带时间戳的任务完成记录");
    set("#contract-due", "2026-07-19");
    set("#contract-timebox", "15");
    set("#contact-mode", "direct");
    set("#metric-one-name", "完成关键任务");
    set("#metric-one-unit", "是/否");
    set("#metric-two-name", "卡点位置");
    set("#metric-two-unit", "步骤");
    set("#contract-rule", "三人中两人无法完成同一步骤时修订交互，否则保持。");
    const preview = document.querySelector("#contract-preview-text").textContent;
    if (!preview.includes("在预约的访谈中展示同一个原型")
      || !preview.includes("三份带时间戳的任务完成记录")) {
      throw new Error("Contract preview did not reflect the form values.");
    }
    document.querySelector("#contract-form").requestSubmit();

    set("#observation-date", "2026-07-13");
    const noOpportunity = document.querySelector(
      'input[name="opportunity"][value="noOpportunity"]',
    );
    noOpportunity.checked = true;
    noOpportunity.dispatchEvent(new Event("change", { bubbles: true }));
    if (!document.querySelector("#opportunity-note").textContent.includes("不进入分母")
      || !document.querySelector("#evidence-fields").hidden) {
      throw new Error("noOpportunity guidance or field suppression is missing.");
    }
    set("#observation-decision", "keep");
    set("#observation-note", "今天没有预约访谈，不计作测试失败。");
    document.querySelector("#observation-form").requestSubmit();

    set("#observation-date", "2026-07-14");
    const available = document.querySelector(
      'input[name="opportunity"][value="available"]',
    );
    available.checked = true;
    available.dispatchEvent(new Event("change", { bubbles: true }));
    document.querySelector("#evidence-observed").checked = true;
    set("#observation-minutes", "5");
    set("#observation-decision", "revise");
    set("#observation-note", "活动范围需要缩小");
    document.querySelector("#observation-form").requestSubmit();

    set("#contract-activity", "在下一次预约访谈中展示同一个原型");
    document.querySelector("#contract-form").requestSubmit();
    document.querySelector("#ledger-section").scrollIntoView({ block: "start" });
  });
  await delay(160);

  const productResult = await callInPage(client, function () {
    return {
      goalStatus: document.querySelector("#goal-status").textContent.trim(),
      activeVersion: document.querySelector("#active-version-count").textContent.trim(),
      historyCount: document.querySelectorAll("#contract-history li").length,
      ecr: document.querySelector("#ecr-count").textContent.trim(),
      noOpportunity: document.querySelector("#no-opportunity-count").textContent.trim(),
      rows: document.querySelectorAll("#observation-table-body tr").length,
      nextAction: document.querySelector("#next-action-title").textContent.trim(),
      currentStep: document.querySelector(".step-tab.is-current")?.id || "",
      historyDetail: document.querySelector("#contract-history li small")?.textContent || "",
      ecrNote: document.querySelector("#ecr-note").textContent.trim(),
    };
  });
  assert.equal(productResult.activeVersion, "v2");
  assert.equal(productResult.historyCount, 2);
  assert.equal(productResult.ecr, "0 / 0");
  assert.equal(productResult.noOpportunity, "0");
  assert.equal(productResult.rows, 2);
  assert.equal(productResult.nextAction, "记录第一次机会");
  assert.equal(productResult.currentStep, "step-observation");
  assert.match(productResult.historyDetail, /变更：活动/);
  assert.match(productResult.historyDetail, /活动范围需要缩小/);
  assert.match(productResult.ecrNote, /不代表失败/);

  const productInteractionSafety = await callInPage(client, function () {
    const before = localStorage.getItem("next-evidence:v1");
    const decision = document.querySelector("#observation-decision");
    decision.value = "exit";
    decision.dispatchEvent(new Event("change", { bubbles: true }));
    const originalConfirm = window.confirm;
    window.confirm = () => false;
    document.querySelector("#observation-form").requestSubmit();
    window.confirm = originalConfirm;
    const exitCancelPreserved = localStorage.getItem("next-evidence:v1") === before;
    decision.value = "keep";
    decision.dispatchEvent(new Event("change", { bubbles: true }));

    const externalSnapshot = before + " ";
    localStorage.setItem("next-evidence:v1", externalSnapshot);
    document.querySelector("#observation-form").requestSubmit();
    const crossTabWriteBlocked = localStorage.getItem("next-evidence:v1") === externalSnapshot;
    const conflictVisible = document.querySelector("#message").textContent.includes("另一标签页");
    localStorage.setItem("next-evidence:v1", before);

    document.querySelector("#import-button").click();
    const text = document.querySelector("#import-text");
    text.value = "{bad-json";
    text.dispatchEvent(new Event("input", { bubbles: true }));
    document.querySelector("#confirm-import-button").click();
    const invalidVisibleInDialog = document.querySelector("#import-dialog").open
      && !document.querySelector("#import-message").hidden
      && document.querySelector("#import-message").classList.contains("error");

    text.value = before;
    text.dispatchEvent(new Event("input", { bubbles: true }));
    document.querySelector("#confirm-import-button").click();
    const previewVisible = !document.querySelector("#import-preview").hidden;
    const confirmLabel = document.querySelector("#confirm-import-button").textContent.trim();
    const previewPreserved = localStorage.getItem("next-evidence:v1") === before;
    document.querySelector("#confirm-import-button").click();
    const backupApplied = !document.querySelector("#import-dialog").open
      && document.querySelector("#message").textContent.includes("备份已导入")
      && localStorage.getItem("next-evidence:v1") === before;
    return {
      exitCancelPreserved,
      crossTabWriteBlocked,
      conflictVisible,
      invalidVisibleInDialog,
      previewVisible,
      confirmLabel,
      previewPreserved,
      backupApplied,
    };
  });
  assert.equal(productInteractionSafety.exitCancelPreserved, true);
  assert.equal(productInteractionSafety.crossTabWriteBlocked, true);
  assert.equal(productInteractionSafety.conflictVisible, true);
  assert.equal(productInteractionSafety.invalidVisibleInDialog, true);
  assert.equal(productInteractionSafety.previewVisible, true);
  assert.equal(productInteractionSafety.confirmLabel, "确认替换本地数据");
  assert.equal(productInteractionSafety.previewPreserved, true);
  assert.equal(productInteractionSafety.backupApplied, true);

  const productDesktopHealth = await callInPage(client, getPageHealth);
  assert.equal(productDesktopHealth.documentWidth, productDesktopHealth.innerWidth);
  const productDesktopShot = await screenshot(client, "product-result-desktop.png");
  await callInPage(client, function () {
    document.querySelector(".workflow-overview").scrollIntoView({ block: "start" });
  });
  await delay(60);
  const productWorkflowDesktopShot = await screenshot(client, "product-workflow-desktop.png");

  await setViewport(client, 390, 844, true);
  await delay(120);
  await callInPage(client, function () {
    document.querySelector(".workflow-overview").scrollIntoView({ block: "start" });
  });
  await delay(60);
  const productWorkflowMobileShot = await screenshot(client, "product-workflow-mobile.png");
  await callInPage(client, function () {
    document.querySelector("#ledger-section").scrollIntoView({ block: "start" });
  });
  const productMobile = await callInPage(client, getPageHealth);
  assert.equal(productMobile.innerWidth, 390);
  assert.equal(productMobile.documentWidth, 390);
  assert.deepEqual(productMobile.offenders, []);
  const productMobileShot = await screenshot(client, "product-result-mobile.png");

  const recoveryReloaded = client.waitFor("Page.loadEventFired");
  await callInPage(client, function () {
    localStorage.setItem("next-evidence:v1", "{corrupt-local-data");
    location.reload();
  });
  await recoveryReloaded;
  await delay(160);
  const productRecovery = await callInPage(client, function () {
    const rawBefore = localStorage.getItem("next-evidence:v1");
    const title = document.querySelector("#goal-title");
    title.value = "不应覆盖恢复数据的目标";
    title.dispatchEvent(new Event("input", { bubbles: true }));
    document.querySelector("#goal-risk").value = "low";
    document.querySelector("#goal-form").requestSubmit();
    const writeBlocked = localStorage.getItem("next-evidence:v1") === rawBefore;
    document.querySelector("#clear-button").click();
    return {
      panelVisible: !document.querySelector("#recovery-panel").hidden,
      writeBlocked,
      clearBlocked: localStorage.getItem("next-evidence:v1") === rawBefore,
      message: document.querySelector("#message").textContent.trim(),
      nextAction: document.querySelector("#next-action-title").textContent.trim(),
    };
  });
  assert.equal(productRecovery.panelVisible, true);
  assert.equal(productRecovery.writeBlocked, true);
  assert.equal(productRecovery.clearBlocked, true);
  assert.match(productRecovery.message, /下载|明确弃用/);
  assert.equal(productRecovery.nextAction, "先处理恢复数据");

  const externalRequests = requests.filter(
    (url) => !url.startsWith(baseUrl) && !url.startsWith("data:") && url !== "about:blank",
  );
  assert.deepEqual(externalRequests, []);
  assert.deepEqual(runtimeErrors, []);

  console.log(JSON.stringify({
    diagnostic: {
      initial: { ...diagnosticInitial, ...diagnosticInitialExtra },
      result: diagnosticResult,
      mobile: diagnosticMobile,
      screenshots: [diagnosticDesktopShot, diagnosticMobileShot],
    },
    product: {
      initial: { ...productInitial, ...productInitialExtra },
      result: productResult,
      interactionSafety: productInteractionSafety,
      mobile: productMobile,
      recovery: productRecovery,
      screenshots: [
        productDesktopShot,
        productMobileShot,
        productWorkflowDesktopShot,
        productWorkflowMobileShot,
      ],
    },
    network: { requestCount: requests.length, externalRequests },
    runtimeErrors,
  }, null, 2));
} finally {
  if (client) {
    await Promise.race([
      client.send("Browser.close").catch(() => {}),
      delay(1_000),
    ]);
    client.close();
  }
  if (chrome.exitCode === null) {
    await Promise.race([
      new Promise((resolve) => chrome.once("exit", resolve)),
      delay(4_000),
    ]);
  }
  if (chrome.exitCode === null) {
    chrome.kill();
    await Promise.race([
      new Promise((resolve) => chrome.once("exit", resolve)),
      delay(2_000),
    ]);
  }
  assert.equal(path.dirname(profileDir), profileRoot, "Unexpected Chrome profile parent.");
  assert.match(path.basename(profileDir), /^codex-browser-/, "Unexpected Chrome profile name.");
  for (let attempt = 0; attempt < 2; attempt += 1) {
    if (existsSync(profileDir)) {
      rmSync(profileDir, {
        recursive: true,
        force: true,
        maxRetries: 10,
        retryDelay: 200,
      });
    }
    await delay(250);
  }
  assert.equal(existsSync(profileDir), false, "Chrome profile directory survived cleanup.");
}
