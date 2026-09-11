import assert from "node:assert/strict";
import test from "node:test";

import logic from "./logic.js";
import ui from "./ui-state.js";

const {
  DECISIONS,
  clearState,
  computeEcr,
  createGoal,
  createState,
  exportState,
  getActiveContract,
  importJsonSafely,
  lockContractVersion,
  recordObservation,
} = logic;

function baseState(riskLevel = "low") {
  return createGoal(createState("2026-07-12T08:00:00.000Z"), {
    title: "发布一份真实报价",
    why: "验证潜在客户是否愿意继续谈",
    riskLevel,
  }, "2026-07-12T08:01:00.000Z");
}

function contractInput(overrides = {}) {
  return {
    activity: "把一页报价发给一位已同意接收的潜在客户",
    evidence: "保留发送时间与对方是否回复",
    dueDate: "2026-07-13",
    timeboxMinutes: 15,
    contactMode: "direct",
    decisionRule: "有明确异议就只改一个变量；没有机会则记录 noOpportunity",
    metrics: [
      { name: "发送份数", unit: "份" },
      { name: "有效回复", unit: "条" },
    ],
    ...overrides,
  };
}

function lockedState(riskLevel = "low", overrides = {}) {
  return lockContractVersion(
    baseState(riskLevel),
    contractInput(overrides),
    "2026-07-12T08:02:00.000Z",
  );
}

function observationInput(state, overrides = {}) {
  return {
    contractId: getActiveContract(state).id,
    date: "2026-07-13",
    opportunity: "available",
    evidenceObserved: true,
    minutes: 10,
    metricValues: {},
    decision: "keep",
    note: "保留一条事实",
    ...overrides,
  };
}

test("locking a revision creates a new version without rewriting version one", () => {
  const first = lockedState();
  const versionOneBefore = structuredClone(first.contracts[0]);

  const second = lockContractVersion(
    first,
    contractInput({ activity: "发送修订后的一页报价" }),
    "2026-07-13T08:00:00.000Z",
  );

  assert.equal(second.contracts.length, 2);
  assert.equal(second.contracts[0].version, 1);
  assert.equal(second.contracts[0].status, "superseded");
  const { status: afterStatus, supersededAt, ...versionOneAfter } = second.contracts[0];
  const { status: beforeStatus, ...versionOneOriginal } = versionOneBefore;
  assert.equal(afterStatus, "superseded");
  assert.equal(beforeStatus, "locked");
  assert.equal(supersededAt, "2026-07-13T08:00:00.000Z");
  assert.deepEqual(versionOneAfter, versionOneOriginal);
  assert.equal(second.contracts[1].version, 2);
  assert.equal(second.contracts[1].status, "locked");
  assert.equal(getActiveContract(second).version, 2);
});

test("ECR excludes noOpportunity observations from its denominator", () => {
  let state = lockedState();
  const contract = getActiveContract(state);

  state = recordObservation(state, {
    contractId: contract.id,
    date: "2026-07-13",
    opportunity: "available",
    evidenceObserved: true,
    minutes: 8,
    metricValues: { [contract.metrics[0].id]: "1" },
    decision: "keep",
    note: "按合同完成",
  });
  state = recordObservation(state, {
    contractId: contract.id,
    date: "2026-07-14",
    opportunity: "noOpportunity",
    evidenceObserved: true,
    minutes: 12,
    metricValues: { [contract.metrics[0].id]: "99" },
    decision: "resource",
    note: "对方当天不接收材料",
  });
  state = recordObservation(state, {
    contractId: contract.id,
    date: "2026-07-15",
    opportunity: "available",
    evidenceObserved: false,
    minutes: 6,
    metricValues: {},
    decision: "revise",
    note: "活动定义仍过大",
  });

  assert.deepEqual(computeEcr(state), {
    completed: 1,
    opportunities: 2,
    value: 0.5,
  });
  const noOpportunity = state.observations[1];
  assert.equal(noOpportunity.evidenceObserved, false);
  assert.equal(noOpportunity.minutes, 0);
  assert.deepEqual(noOpportunity.metricValues, {});
});

test("import rejects non-boolean evidence without changing ECR", () => {
  let current = lockedState();
  const contract = getActiveContract(current);
  current = recordObservation(current, {
    contractId: contract.id,
    date: "2026-07-13",
    opportunity: "available",
    evidenceObserved: false,
    minutes: 5,
    metricValues: {},
    decision: "keep",
    note: "未留下完成证据",
  });
  const before = exportState(current);
  const ecrBefore = computeEcr(current);
  const corrupted = JSON.parse(before);
  corrupted.observations[0].evidenceObserved = "false";

  const result = importJsonSafely(current, JSON.stringify(corrupted));

  assert.equal(result.ok, false);
  assert.match(result.error, /布尔值/);
  assert.equal(exportState(result.state), before);
  assert.deepEqual(computeEcr(result.state), ecrBefore);
});

test("import rejects evidence fields added to a noOpportunity record", () => {
  let current = lockedState();
  const contract = getActiveContract(current);
  current = recordObservation(current, {
    contractId: contract.id,
    date: "2026-07-13",
    opportunity: "noOpportunity",
    evidenceObserved: false,
    minutes: 0,
    metricValues: {},
    decision: "resource",
    note: "权限尚未到位",
  });
  const before = exportState(current);
  const corruptions = [
    (observation) => { observation.evidenceObserved = true; },
    (observation) => { observation.minutes = 1; },
    (observation) => { observation.metricValues[contract.metrics[0].id] = "1"; },
  ];

  corruptions.forEach((corrupt) => {
    const payload = JSON.parse(before);
    corrupt(payload.observations[0]);
    const result = importJsonSafely(current, JSON.stringify(payload));
    assert.equal(result.ok, false);
    assert.equal(exportState(result.state), before);
  });
});

test("noOpportunity requires an objective reason in new and imported records", () => {
  let current = lockedState();
  const contract = getActiveContract(current);
  const input = {
    contractId: contract.id,
    date: "2026-07-13",
    opportunity: "noOpportunity",
    evidenceObserved: false,
    minutes: 0,
    metricValues: {},
    decision: "resource",
    note: "",
  };

  assert.throws(() => recordObservation(current, input), /客观原因/);

  current = recordObservation(current, {
    ...input,
    note: "等待必要权限",
  });
  const before = exportState(current);
  const corrupted = JSON.parse(before);
  corrupted.observations[0].note = "";
  const result = importJsonSafely(current, JSON.stringify(corrupted));
  assert.equal(result.ok, false);
  assert.match(result.error, /客观原因/);
  assert.equal(exportState(result.state), before);
});

test("schema rejection returns the exact existing data unchanged", () => {
  const current = lockedState();
  const before = exportState(current);
  const result = importJsonSafely(current, JSON.stringify({
    app: "next-evidence",
    schemaVersion: 999,
    goal: null,
    contracts: [],
    observations: [],
  }));

  assert.equal(result.ok, false);
  assert.equal(exportState(result.state), before);
  assert.equal(exportState(current), before);
});

test("an observation with an unknown metric is rejected without data loss", () => {
  let current = lockedState();
  const contract = getActiveContract(current);
  current = recordObservation(current, {
    contractId: contract.id,
    date: "2026-07-13",
    opportunity: "available",
    evidenceObserved: true,
    minutes: 5,
    metricValues: {},
    decision: "keep",
    note: "合法原始记录",
  });
  const before = exportState(current);
  const corrupted = JSON.parse(before);
  corrupted.observations[0].metricValues.unknown_metric = "9";
  const result = importJsonSafely(current, JSON.stringify(corrupted));

  assert.equal(result.ok, false);
  assert.equal(exportState(result.state), before);
});

test("malformed JSON never replaces current data", () => {
  const current = lockedState();
  const result = importJsonSafely(current, "{not-json");

  assert.equal(result.ok, false);
  assert.deepEqual(result.state, current);
});

test("high-risk goals cannot lock a direct constraint test", () => {
  assert.throws(
    () => lockedState("high"),
    /模拟或监督/,
  );
});

test("high-risk goals may lock a bounded simulation contract", () => {
  const state = lockedState("high", { contactMode: "simulation" });
  assert.equal(getActiveContract(state).contactMode, "simulation");
});

test("import rejects a contract risk snapshot that disagrees with its goal", () => {
  const current = lockedState();
  const before = exportState(current);
  const corrupted = JSON.parse(before);
  corrupted.contracts[0].riskLevel = "high";

  const result = importJsonSafely(current, JSON.stringify(corrupted));

  assert.equal(result.ok, false);
  assert.match(result.error, /风险快照/);
  assert.equal(exportState(result.state), before);
  assert.equal(exportState(current), before);
});

test("import rejects an inverted contract version timeline", () => {
  const versionOne = lockedState();
  const current = lockContractVersion(
    versionOne,
    contractInput({ activity: "发送第二版报价" }),
    "2026-07-13T08:00:00.000Z",
  );
  const before = exportState(current);
  const corrupted = JSON.parse(before);
  corrupted.contracts[0].status = "locked";
  delete corrupted.contracts[0].supersededAt;
  corrupted.contracts[1].status = "superseded";
  corrupted.contracts[1].supersededAt = "2026-07-14T08:00:00.000Z";

  const result = importJsonSafely(current, JSON.stringify(corrupted));

  assert.equal(result.ok, false);
  assert.match(result.error, /版本时间线/);
  assert.equal(exportState(result.state), before);
});

test("one contract contains one or two metrics, never zero or three", () => {
  assert.throws(
    () => lockedState("low", { metrics: [] }),
    /一至两个指标/,
  );
  assert.throws(
    () => lockedState("low", {
      metrics: [
        { name: "A", unit: "x" },
        { name: "B", unit: "x" },
        { name: "C", unit: "x" },
      ],
    }),
    /一至两个指标/,
  );
});

test("daily observation time cannot exceed twenty minutes", () => {
  let state = lockedState();
  const contract = getActiveContract(state);
  state = recordObservation(state, {
    contractId: contract.id,
    date: "2026-07-13",
    opportunity: "available",
    evidenceObserved: true,
    minutes: 12,
    metricValues: {},
    decision: "keep",
    note: "第一次观察",
  });

  assert.throws(
    () => recordObservation(state, {
      contractId: contract.id,
      date: "2026-07-13",
      opportunity: "available",
      evidenceObserved: false,
      minutes: 9,
      metricValues: {},
      decision: "measurement",
      note: "第二次观察",
    }),
    /二十分钟/,
  );
});

test("import rejects a daily total above twenty minutes", () => {
  let current = lockedState();
  const contract = getActiveContract(current);
  current = recordObservation(current, {
    contractId: contract.id,
    date: "2026-07-13",
    opportunity: "available",
    evidenceObserved: true,
    minutes: 12,
    metricValues: {},
    decision: "keep",
    note: "第一条",
  });
  current = recordObservation(current, {
    contractId: contract.id,
    date: "2026-07-14",
    opportunity: "available",
    evidenceObserved: false,
    minutes: 9,
    metricValues: {},
    decision: "measurement",
    note: "第二条",
  });
  const before = exportState(current);
  const corrupted = JSON.parse(before);
  corrupted.observations[1].date = "2026-07-13";

  const result = importJsonSafely(current, JSON.stringify(corrupted));

  assert.equal(result.ok, false);
  assert.match(result.error, /每日活动/);
  assert.equal(exportState(result.state), before);
});

test("all supported decisions can be recorded without a score", () => {
  assert.deepEqual(DECISIONS.map((item) => item.id), [
    "keep",
    "revise",
    "boundedLearning",
    "resource",
    "measurement",
    "exit",
    "support",
  ]);
});

test("revision stays explicit and ECR remains isolated by contract version", () => {
  let state = lockedState();
  const versionOne = getActiveContract(state);
  state = recordObservation(state, {
    contractId: versionOne.id,
    date: "2026-07-13",
    opportunity: "available",
    evidenceObserved: true,
    minutes: 5,
    metricValues: {},
    decision: "revise",
    note: "活动范围需要缩小",
  });

  assert.equal(state.contracts.length, 1);
  assert.equal(getActiveContract(state).version, 1);

  state = lockContractVersion(
    state,
    contractInput({ activity: "只发送报价标题给一位潜在客户" }),
    "2026-07-14T08:00:00.000Z",
  );
  const versionTwo = getActiveContract(state);
  state = recordObservation(state, {
    contractId: versionTwo.id,
    date: "2026-07-14",
    opportunity: "available",
    evidenceObserved: false,
    minutes: 4,
    metricValues: {},
    decision: "keep",
    note: "有机会但未留下证据",
  });

  assert.equal(state.contracts[0].activity, contractInput().activity);
  assert.deepEqual(computeEcr(state, versionOne.id), {
    completed: 1,
    opportunities: 1,
    value: 1,
  });
  assert.deepEqual(computeEcr(state, versionTwo.id), {
    completed: 0,
    opportunities: 1,
    value: 0,
  });
});

test("the exit decision closes the active contract and goal", () => {
  let state = lockedState();
  const contract = getActiveContract(state);
  state = recordObservation(state, {
    contractId: contract.id,
    date: "2026-07-13",
    opportunity: "available",
    evidenceObserved: false,
    minutes: 3,
    metricValues: {},
    decision: "exit",
    note: "目标不再值得继续",
  });

  assert.equal(state.goal.status, "exited");
  assert.equal(state.contracts[0].status, "closed");
  assert.equal(getActiveContract(state), null);
  assert.throws(() => lockContractVersion(state, contractInput()), /已退出/);
  assert.throws(() => recordObservation(state, {
    contractId: contract.id,
    date: "2026-07-14",
    opportunity: "available",
    evidenceObserved: true,
    minutes: 1,
    metricValues: {},
    decision: "keep",
    note: "不应被接受",
  }), /当前已锁定合同/);
});

test("import rejects an exit decision that remains active", () => {
  let current = lockedState();
  const contract = getActiveContract(current);
  current = recordObservation(current, {
    contractId: contract.id,
    date: "2026-07-13",
    opportunity: "available",
    evidenceObserved: false,
    minutes: 3,
    metricValues: {},
    decision: "exit",
    note: "目标不再值得继续",
  });
  const before = exportState(current);
  const corrupted = JSON.parse(before);
  corrupted.goal.status = "active";
  corrupted.contracts[0].status = "locked";

  const result = importJsonSafely(current, JSON.stringify(corrupted));

  assert.equal(result.ok, false);
  assert.match(result.error, /退出决定/);
  assert.equal(exportState(result.state), before);
  assert.equal(importJsonSafely(createState(), before).ok, true);
});

test("legacy diagnostic JSON creates a reviewable suggestion without replacing state", () => {
  const current = createState("2026-07-12T08:00:00.000Z");
  const diagnostic = {
    app: "reversible-progress-diagnostic",
    schemaVersion: 1,
    kind: "diagnostic-result",
    result: {
      suggestedGoal: "完成一次低风险用户访谈",
      riskLevel: "medium",
      focus: "先确认测量是否可读",
    },
  };
  const result = importJsonSafely(current, JSON.stringify(diagnostic));

  assert.equal(result.ok, true);
  assert.equal(result.kind, "diagnostic");
  assert.equal(result.suggestion.title, "完成一次低风险用户访谈");
  assert.deepEqual(result.state, current);
});

test("real diagnostic export imports only goal and safe route instruction", () => {
  const current = createState("2026-07-12T08:00:00.000Z");
  const diagnostic = {
    schemaVersion: "1.0",
    exportedAt: "2026-07-12T08:10:00.000Z",
    draft: {
      schemaVersion: "1.0",
      goal: "完成一次低风险用户访谈",
      context: "不应进入产品的敏感上下文",
      purpose: "committed_goal",
      answers: { K1: "yes", S1: "prefer_not" },
    },
    assessment: {
      schemaVersion: "1.0",
      currentRoute: "measurement_first",
      canContinue: true,
      routeCopy: {
        title: "先修测量",
        instruction: "先定义一个能区分两种结果的观察。",
      },
      findings: [{ detail: "不应导入的成因与回答" }],
      risk: { state: "direct_ok", message: "可继续" },
    },
  };
  const result = importJsonSafely(current, JSON.stringify(diagnostic));

  assert.equal(result.ok, true);
  assert.equal(result.kind, "diagnostic");
  assert.equal(result.suggestion.title, "完成一次低风险用户访谈");
  assert.equal(result.suggestion.why, "先定义一个能区分两种结果的观察。");
  assert.equal(JSON.stringify(result.suggestion).includes("敏感上下文"), false);
  assert.equal(JSON.stringify(result.suggestion).includes("成因与回答"), false);
  assert.deepEqual(result.state, current);
});

test("urgent real diagnostic export refuses productivity prefill and preserves state", () => {
  const current = lockedState();
  const before = exportState(current);
  const urgent = {
    schemaVersion: "1.0",
    exportedAt: "2026-07-12T08:10:00.000Z",
    draft: {
      schemaVersion: "1.0",
      goal: "提高本周产出",
      context: "不应进入产品的安全回答",
      purpose: "committed_goal",
      answers: {},
    },
    assessment: {
      schemaVersion: "1.0",
      currentRoute: "urgent_support",
      canContinue: false,
      routeCopy: {
        title: "先保证基本安全",
        instruction: "暂停生产力任务并联系可信支持。",
      },
      findings: [{ detail: "不应导入" }],
      risk: { state: "stop", message: "基本安全优先" },
    },
  };
  const result = importJsonSafely(current, JSON.stringify(urgent));

  assert.equal(result.ok, false);
  assert.equal(result.kind, "support");
  assert.equal(result.error, "暂停生产力任务并联系可信支持。");
  assert.equal(result.suggestion, undefined);
  assert.equal(exportState(result.state), before);
});

test("exported state round-trips through validated import", () => {
  const current = lockedState();
  const imported = importJsonSafely(createState(), exportState(current));

  assert.equal(imported.ok, true);
  assert.equal(imported.kind, "backup");
  assert.deepEqual(imported.state, current);
});

test("v1 export keeps the exact business shape and excludes interface state", () => {
  const exported = JSON.parse(exportState(lockedState()));

  assert.deepEqual(Object.keys(exported).sort(), [
    "app", "contracts", "createdAt", "goal", "observations", "schemaVersion", "updatedAt",
  ]);
  assert.deepEqual(Object.keys(exported.goal).sort(), [
    "createdAt", "id", "riskLevel", "status", "title", "why",
  ]);
  assert.equal(JSON.stringify(exported).includes("currentWorkspace"), false);
  assert.equal(JSON.stringify(exported).includes("contractStage"), false);
  assert.equal(JSON.stringify(exported).includes("ledgerScope"), false);
});

test("v1 import rejects unknown interface fields without replacing current data", () => {
  const current = lockedState();
  const before = exportState(current);
  const polluted = JSON.parse(before);
  polluted.currentWorkspace = "ledger";
  const result = importJsonSafely(current, JSON.stringify(polluted));

  assert.equal(result.ok, false);
  assert.match(result.error, /未知字段/);
  assert.equal(exportState(result.state), before);
});

test("v1 import rejects unknown nested fields without propagating them", () => {
  const current = lockedState();
  const before = exportState(current);
  const polluted = JSON.parse(before);
  polluted.contracts[0].expanded = true;
  const result = importJsonSafely(current, JSON.stringify(polluted));

  assert.equal(result.ok, false);
  assert.equal(exportState(result.state), before);
});

test("primary workspace follows the business-state matrix", () => {
  const empty = createState("2026-07-12T08:00:00.000Z");
  const goalOnly = baseState();
  const locked = lockedState();
  const revise = recordObservation(locked, observationInput(locked, { decision: "revise" }));
  const exited = recordObservation(locked, observationInput(locked, { decision: "exit" }));

  assert.equal(ui.derivePrimaryWorkspace(empty), "goal");
  assert.equal(ui.derivePrimaryWorkspace(goalOnly), "contract");
  assert.equal(ui.derivePrimaryWorkspace(locked), "observation");
  assert.equal(ui.derivePrimaryWorkspace(revise), "contract");
  assert.equal(ui.derivePrimaryWorkspace(exited), "ledger");
  assert.equal(ui.derivePrimaryWorkspace(locked, { recoveryPending: true }), "recovery");
});

test("ledger scope defaults to the active or most recently closed contract", () => {
  let current = lockedState();
  const firstId = getActiveContract(current).id;
  current = recordObservation(current, observationInput(current, { note: "v1" }));
  current = lockContractVersion(current, contractInput({ activity: "第二版活动" }));
  const secondId = getActiveContract(current).id;
  current = recordObservation(current, observationInput(current, { contractId: secondId, note: "v2" }));

  assert.equal(ui.ledgerRecords(current, "current").length, 1);
  assert.equal(ui.ledgerRecords(current, "current")[0].contractId, secondId);
  assert.equal(ui.ledgerRecords(current, "all").length, 2);
  assert.equal(ui.ledgerRecords(current, "all")[1].contractId, firstId);
});

test("clear removes the goal, contracts, and observations", () => {
  const cleared = clearState(lockedState(), "2026-07-20T08:00:00.000Z");

  assert.equal(cleared.goal, null);
  assert.deepEqual(cleared.contracts, []);
  assert.deepEqual(cleared.observations, []);
});
