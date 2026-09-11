import assert from "node:assert/strict";
import test from "node:test";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
const router = require("../../diagnostic-tool/logic.js");
const product = require("../prototype/logic.js");

function safeCommittedAnswers() {
  const answers = Object.fromEntries(router.QUESTION_IDS.map((id) => [id, "no"]));
  Object.assign(answers, {
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
    A1: "yes",
    A2: "yes",
    A3: "yes",
    A4: "yes",
    F1: "yes",
    F2: "yes",
    F3: "yes",
    F4: "yes",
    W1: "yes",
    M1: "no",
    M2: "yes",
    M3: "yes",
    S1: "no",
    S2: "no",
    S3: "no",
  });
  return answers;
}

function makeRouterExport(input) {
  const draft = router.buildPersistableDraft(input);
  const assessment = router.evaluateAssessment(input);
  return {
    schemaVersion: router.SCHEMA_VERSION,
    exportedAt: "2026-07-12T08:00:00.000Z",
    draft,
    assessment,
    privacy: "sensitive answers omitted",
  };
}

test("actual router export becomes a reviewable product suggestion without sensitive fields", () => {
  const diagnostic = makeRouterExport({
    goal: "向三位目标用户展示可点击原型",
    context: "private-context-that-must-not-cross",
    purpose: "committed_goal",
    answers: safeCommittedAnswers(),
  });
  const current = product.createState("2026-07-12T08:00:00.000Z");
  const result = product.importJsonSafely(current, JSON.stringify(diagnostic));

  assert.equal(diagnostic.schemaVersion, "1.0");
  assert.equal(diagnostic.draft.schemaVersion, "1.0");
  assert.equal(result.ok, true);
  assert.equal(result.kind, "diagnostic");
  assert.deepEqual(result.state, current);
  assert.equal(result.suggestion.title, diagnostic.draft.goal);
  assert.equal(result.suggestion.why, diagnostic.assessment.routeCopy.instruction);
  assert.equal(JSON.stringify(result.suggestion).includes("private-context-that-must-not-cross"), false);
  assert.equal(JSON.stringify(result.suggestion).includes('"answers"'), false);
});

test("actual urgent router export is blocked and never becomes a product goal", () => {
  const answers = safeCommittedAnswers();
  answers.U0 = "yes";
  const diagnostic = makeRouterExport({
    goal: "不应进入产品的目标",
    context: "private-urgent-context",
    purpose: "committed_goal",
    answers,
  });
  const current = product.createState("2026-07-12T08:00:00.000Z");
  const result = product.importJsonSafely(current, JSON.stringify(diagnostic));

  assert.equal(diagnostic.assessment.currentRoute, "urgent_support");
  assert.equal(diagnostic.assessment.canContinue, false);
  assert.equal(result.ok, false);
  assert.equal(result.kind, "support");
  assert.deepEqual(result.state, current);
  assert.equal(Object.hasOwn(result, "suggestion"), false);
  assert.equal(JSON.stringify(result).includes("private-urgent-context"), false);
});
