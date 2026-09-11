import assert from "node:assert/strict";
import { createRequire } from "node:module";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const require = createRequire(import.meta.url);
const logic = require("./logic.js");
const here = dirname(fileURLToPath(import.meta.url));
const tests = [];

const BASE_ANSWERS = Object.freeze({
  U0: "no",
  G1: "yes",
  G2: "yes",
  G3: "yes",
  G4: "no",
  P1: "yes",
  P2: "yes",
  P3: "yes",
  P4: "no",
  R1: "yes",
  R2: "no",
  R3: "no",
  K1: "yes",
  K2: "yes",
  K3: "no",
  K4: "yes",
  A1: "yes",
  A2: "yes",
  A3: "yes",
  A4: "yes",
  F1: "yes",
  F2: "yes",
  F3: "yes",
  F4: "yes",
  EA1: "no",
  EA2: "no",
  EA3: "no",
  W1: "yes",
  W2: "no",
  W3: "no",
  W4: "no",
  M1: "no",
  M2: "yes",
  M3: "yes",
  S1: "no",
  S2: "no",
  S3: "no",
});

function test(name, run) {
  tests.push({ name, run });
}

function assessment(answerOverrides = {}, inputOverrides = {}) {
  return logic.evaluateAssessment({
    goal: "向三位目标用户展示可点击原型",
    context: "低风险内部测试",
    purpose: "committed_goal",
    answers: { ...BASE_ANSWERS, ...answerOverrides },
    ...inputOverrides,
  });
}

function finding(result, cause) {
  const match = result.findings.find((item) => item.cause === cause);
  assert.ok(match, `missing finding: ${cause}`);
  return match;
}

function supportedCauses(result) {
  return result.findings.filter((item) => item.state === "supported").map((item) => item.cause);
}

test("T01: failed representative task routes to bounded learning", () => {
  const result = assessment({ K2: "no", K3: "yes" });
  assert.equal(finding(result, "knowledge").state, "supported");
  assert.equal(result.currentRoute, "bounded_learning");
  assert.equal(finding(result, "emotional_avoidance").state, "not_supported");
});

test("T02: an undefined observable action is detected without prescribing more study", () => {
  const result = assessment({ A2: "no", A3: "no" });
  assert.equal(finding(result, "action_definition").state, "supported");
  assert.equal(finding(result, "knowledge").state, "not_supported");
  assert.equal(result.currentRoute, "define_action");
});

test("T03: missing organizational approval routes to resources and permission", () => {
  const result = assessment({ P3: "no" });
  assert.equal(finding(result, "environment_permission").state, "supported");
  assert.equal(result.currentRoute, "get_resources");
});

test("T04: slow or non-attributable feedback routes to measurement work", () => {
  const result = assessment({ F1: "no", F3: "no" });
  assert.equal(finding(result, "feedback").state, "supported");
  assert.equal(result.currentRoute, "improve_feedback");
});

test("T05: low-stakes willingness shift supports emotional avoidance only after all gates pass", () => {
  const result = assessment({ EA1: "yes", EA2: "yes", EA3: "yes" });
  assert.equal(finding(result, "emotional_avoidance").state, "supported");
  assert.equal(result.currentRoute, "constraint_test");
});

test("T06: a high-risk professional task cannot be labeled direct perfectionism", () => {
  const result = assessment({ R3: "yes", W2: "yes", W3: "yes" });
  assert.equal(result.risk.state, "supervised_only");
  assert.equal(result.currentRoute, "supervised_or_expert");
  assert.equal(finding(result, "perfectionism_concern").state, "test_needed");
});

test("T07: moving a self-set threshold after the external minimum supports perfectionism concern", () => {
  const result = assessment({ W2: "yes", W3: "yes" });
  assert.equal(finding(result, "perfectionism_concern").state, "supported");
  assert.equal(finding(result, "emotional_avoidance").state, "not_supported");
});

test("T08: maintenance that improves measurement is treated as legitimate infrastructure", () => {
  const result = assessment({ M1: "yes", M2: "yes", M3: "yes" });
  assert.equal(finding(result, "maintenance_overhead").state, "not_supported");
});

test("T09: maintenance that displaced a real opportunity without benefit is detected", () => {
  const result = assessment({ M1: "yes", M2: "no", M3: "no" });
  assert.equal(finding(result, "maintenance_overhead").state, "supported");
  assert.equal(result.currentRoute, "freeze_maintenance");
});

test("T10: an identity-only goal with no recognized value can be exited legally", () => {
  const result = assessment({ G1: "no", G2: "no", G3: "no", G4: "yes" });
  assert.equal(finding(result, "goal_not_important").state, "supported");
  assert.equal(result.currentRoute, "exit_goal");
});

test("T11: care or workload constraints are environment barriers, not personal avoidance", () => {
  const result = assessment({ P1: "no", P4: "yes", EA1: "yes", EA2: "yes", EA3: "yes" });
  assert.equal(finding(result, "environment_permission").state, "supported");
  assert.equal(finding(result, "emotional_avoidance").state, "test_needed");
  assert.equal(result.currentRoute, "get_resources");
});

test("T12: persistent cross-domain impairment activates a support route without a disease label", () => {
  const result = assessment({ S1: "yes" });
  assert.equal(finding(result, "professional_support_route").state, "safety_route");
  assert.equal(result.currentRoute, "professional_support");
  assert.equal(result.canContinue, false);
  assert.doesNotMatch(JSON.stringify(result), /抑郁症|焦虑症|多动症|诊断为/);
});

test("T13: U0 immediate safety risk stops every productivity route", () => {
  const result = assessment({ U0: "yes", A2: "no", P3: "no" });
  assert.equal(result.safety.urgentStop, true);
  assert.equal(result.currentRoute, "urgent_support");
  assert.equal(result.canContinue, false);
  assert.deepEqual(supportedCauses(result), []);
});

test("T14: multiple structural findings survive while emotion remains provisional", () => {
  const result = assessment({ A2: "no", F2: "no", EA1: "yes", EA2: "yes", EA3: "yes" });
  assert.equal(finding(result, "action_definition").state, "supported");
  assert.equal(finding(result, "feedback").state, "supported");
  assert.equal(finding(result, "emotional_avoidance").state, "test_needed");
  assert.deepEqual(supportedCauses(result).sort(), ["action_definition", "feedback"]);
});

test("T15: unknown knowledge answers request a test and never become a negative answer", () => {
  const result = assessment({ K1: "unknown", K2: "unknown", K3: "unknown" });
  assert.equal(finding(result, "knowledge").state, "test_needed");
  assert.equal(result.currentRoute, "clarify_unknown");
});

test("T16: declared exploration is protected from all nine problem labels", () => {
  const result = assessment({}, { purpose: "exploration" });
  assert.equal(result.currentRoute, "exploration");
  assert.equal(result.findings.length, 9);
  assert.ok(result.findings.every((item) => item.state === "not_supported"));
});

test("T17: deep learning with a failed transfer test and an exit date is a legitimate route", () => {
  const result = assessment({ K2: "no", K3: "yes", K4: "yes", M1: "no" });
  assert.equal(result.currentRoute, "bounded_learning");
  assert.equal(finding(result, "knowledge").state, "supported");
  assert.equal(finding(result, "maintenance_overhead").state, "not_supported");
});

test("T18: an acknowledged obligation is not classified as an unimportant goal", () => {
  const result = assessment({ G1: "no", G2: "no", G3: "yes", G4: "yes" });
  assert.equal(finding(result, "goal_not_important").state, "not_supported");
});

test("T19: one weak result below the declared update threshold remains a feedback problem", () => {
  const result = assessment({ F3: "no", F4: "yes" });
  assert.equal(finding(result, "feedback").state, "supported");
  assert.equal(result.currentRoute, "improve_feedback");
  assert.match(finding(result, "feedback").nextMove, /必要重复|更新/);
});

test("T20: uncertain reversible loss prevents a direct constraint test", () => {
  const result = assessment({ R1: "unknown" });
  assert.equal(result.risk.state, "supervised_only");
  assert.equal(result.currentRoute, "supervised_or_expert");
  assert.equal(result.canContinue, false);
});

test("T21: missing U0 is not silently normalized to safe", () => {
  const result = logic.evaluateAssessment({ goal: "测试", answers: {} });
  assert.equal(result.safety.confirmed, false);
  assert.equal(result.currentRoute, "urgent_support");
  assert.equal(result.canContinue, false);
});

test("T22: a direct third-party risk overrides ordinary action routing", () => {
  const result = assessment({ R2: "yes", A2: "no", P3: "no" });
  assert.equal(result.risk.state, "stop");
  assert.equal(result.currentRoute, "stop_or_redesign");
});

test("T23: emotional avoidance remains provisional when feedback is missing", () => {
  const result = assessment({ F2: "no", EA1: "yes", EA2: "yes", EA3: "yes" });
  assert.equal(finding(result, "feedback").state, "supported");
  assert.equal(finding(result, "emotional_avoidance").state, "test_needed");
});

test("T24: perfectionism remains provisional when action definition is missing", () => {
  const result = assessment({ A1: "no", W2: "yes", W4: "yes" });
  assert.equal(finding(result, "action_definition").state, "supported");
  assert.equal(finding(result, "perfectionism_concern").state, "test_needed");
});

test("T25: every committed assessment returns exactly the requested nine distinct causes", () => {
  const result = assessment();
  assert.equal(result.findings.length, 9);
  assert.deepEqual(result.findings.map((item) => item.cause), logic.CAUSE_ORDER);
  assert.equal(new Set(result.findings.map((item) => item.cause)).size, 9);
});

test("T26: sensitive support answers are excluded from the default persisted draft", () => {
  const persisted = logic.buildPersistableDraft({
    goal: "测试",
    answers: { U0: "no", S1: "yes", S2: "prefer_not", S3: "unknown", K2: "unknown", A1: "yes" },
  });
  assert.equal(Object.hasOwn(persisted.answers, "U0"), false);
  assert.equal(Object.hasOwn(persisted.answers, "S1"), false);
  assert.equal(Object.hasOwn(persisted.answers, "S2"), false);
  assert.equal(Object.hasOwn(persisted.answers, "S3"), false);
  assert.equal(persisted.answers.K2, "unknown");
  assert.equal(persisted.answers.A1, "yes");
});

test("T27: user text is bounded and cannot preserve executable angle brackets", () => {
  const cleaned = logic.sanitizeText("<script>\u0000alert(1)</script>".repeat(30), 40);
  assert.ok(cleaned.length <= 40);
  assert.doesNotMatch(cleaned, /[<>]/);
});

test("T28: invalid answer values normalize to unknown instead of no", () => {
  assert.equal(logic.normalizeAnswer("definitely"), "unknown");
  assert.equal(logic.normalizeAnswers({ K2: "definitely" }).K2, "unknown");
});

test("T29: assessment data contains no synthetic scoring or medical classification fields", () => {
  const keys = [];
  function visit(value) {
    if (!value || typeof value !== "object") return;
    Object.entries(value).forEach(([key, child]) => {
      keys.push(key);
      visit(child);
    });
  }
  visit(assessment({ K2: "no", K3: "yes", A2: "no" }));
  assert.equal(keys.some((key) => /score|probability|severity|diagnosis|streak/i.test(key)), false);
});

test("T30: the static client has no network API or unsafe HTML rendering path", () => {
  const source = ["index.html", "logic.js", "app.js"].map((name) => readFileSync(join(here, name), "utf8")).join("\n");
  assert.doesNotMatch(source, /fetch\s*\(|XMLHttpRequest|WebSocket|EventSource|https?:\/\//);
  assert.doesNotMatch(source, /\.innerHTML\s*=|insertAdjacentHTML|document\.write/);
  assert.match(source, /connect-src 'none'/);
});

let passed = 0;
for (const item of tests) {
  try {
    item.run();
    passed += 1;
    console.log(`PASS ${String(passed).padStart(2, "0")} - ${item.name}`);
  } catch (error) {
    console.error(`FAIL - ${item.name}`);
    console.error(error.stack || error.message || error);
    process.exitCode = 1;
    break;
  }
}

if (passed === tests.length) {
  console.log(`\n${passed}/${tests.length} tests passed.`);
}
