(function attachNextEvidence(root, factory) {
  const api = factory();
  if (typeof module === "object" && module.exports) {
    module.exports = api;
  } else {
    root.NextEvidence = api;
  }
}(typeof globalThis !== "undefined" ? globalThis : this, function buildNextEvidence() {
  "use strict";

  const APP_ID = "next-evidence";
  const SCHEMA_VERSION = 1;
  const STORAGE_KEY = "next-evidence:v1";
  const RISK_LEVELS = ["low", "medium", "high", "safety-critical"];
  const GOAL_STATUSES = ["active", "exited"];
  const CONTACT_MODES = ["direct", "simulation", "supervised"];
  const CONTRACT_STATUSES = ["locked", "superseded", "closed"];
  const OPPORTUNITIES = ["available", "noOpportunity"];
  const DECISIONS = [
    { id: "keep", label: "保持" },
    { id: "revise", label: "修订" },
    { id: "boundedLearning", label: "有界学习" },
    { id: "resource", label: "补资源" },
    { id: "measurement", label: "修测量" },
    { id: "exit", label: "退出目标" },
    { id: "support", label: "寻求支持" },
  ];
  const DECISION_IDS = DECISIONS.map((item) => item.id);

  let fallbackId = 0;

  function clone(value) {
    return JSON.parse(JSON.stringify(value));
  }

  function makeId(prefix) {
    if (typeof globalThis !== "undefined"
      && globalThis.crypto
      && typeof globalThis.crypto.randomUUID === "function") {
      return `${prefix}_${globalThis.crypto.randomUUID()}`;
    }
    fallbackId += 1;
    return `${prefix}_${Date.now().toString(36)}_${fallbackId.toString(36)}`;
  }

  function timestamp(value) {
    const date = value ? new Date(value) : new Date();
    if (Number.isNaN(date.getTime())) {
      throw new Error("时间戳无效。");
    }
    return date.toISOString();
  }

  function cleanText(value, label, maxLength = 500) {
    const text = typeof value === "string" ? value.trim() : "";
    if (!text) {
      throw new Error(`${label}为必填项。`);
    }
    if (text.length > maxLength) {
      throw new Error(`${label}过长。`);
    }
    return text;
  }

  function optionalText(value, maxLength = 1000) {
    if (value === undefined || value === null) return "";
    const text = String(value).trim();
    if (text.length > maxLength) {
      throw new Error("文本过长。");
    }
    return text;
  }

  function validDate(value) {
    if (typeof value !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(value)) {
      return false;
    }
    const parsed = new Date(`${value}T00:00:00Z`);
    return !Number.isNaN(parsed.getTime())
      && parsed.toISOString().slice(0, 10) === value;
  }

  function normalizeRisk(value) {
    if (!RISK_LEVELS.includes(value)) {
      throw new Error("风险等级无效。");
    }
    return value;
  }

  function requiresSafetyBoundary(riskLevel) {
    return riskLevel === "high" || riskLevel === "safety-critical";
  }

  function normalizeMetrics(metrics) {
    if (!Array.isArray(metrics) || metrics.length < 1 || metrics.length > 2) {
      throw new Error("一份合同必须包含一至两个指标。");
    }
    return metrics.map((metric) => ({
      id: makeId("metric"),
      name: cleanText(metric && metric.name, "指标名称", 80),
      unit: optionalText(metric && metric.unit, 30),
    }));
  }

  function createState(now) {
    const createdAt = timestamp(now);
    return {
      app: APP_ID,
      schemaVersion: SCHEMA_VERSION,
      createdAt,
      updatedAt: createdAt,
      goal: null,
      contracts: [],
      observations: [],
    };
  }

  function assertBaseState(state) {
    if (!state || state.app !== APP_ID || state.schemaVersion !== SCHEMA_VERSION) {
      throw new Error("不支持的状态数据格式。");
    }
    if (!Array.isArray(state.contracts) || !Array.isArray(state.observations)) {
      throw new Error("状态集合无效。");
    }
  }

  function createGoal(state, input, now) {
    assertBaseState(state);
    if (state.goal) {
      throw new Error("“下一次证据”同一时间只能保留一个目标。");
    }
    const updatedAt = timestamp(now);
    return {
      ...clone(state),
      updatedAt,
      goal: {
        id: makeId("goal"),
        title: cleanText(input && input.title, "目标", 160),
        why: optionalText(input && input.why, 500),
        riskLevel: normalizeRisk(input && input.riskLevel),
        createdAt: updatedAt,
        status: "active",
      },
    };
  }

  function getActiveContract(state) {
    assertBaseState(state);
    const active = state.contracts.filter((contract) => contract.status === "locked");
    return active.length ? active[active.length - 1] : null;
  }

  function validateContractInput(state, input) {
    if (!state.goal) {
      throw new Error("锁定合同前请先创建一个目标。");
    }
    if (state.goal.status !== "active") {
      throw new Error("已退出的目标不能创建新合同。");
    }
    const contactMode = input && input.contactMode;
    if (!CONTACT_MODES.includes(contactMode)) {
      throw new Error("接触方式无效。");
    }
    if (requiresSafetyBoundary(state.goal.riskLevel) && contactMode === "direct") {
      throw new Error("高风险任务必须采用模拟或监督接触。");
    }
    const timeboxMinutes = Number(input && input.timeboxMinutes);
    if (!Number.isInteger(timeboxMinutes) || timeboxMinutes < 1 || timeboxMinutes > 20) {
      throw new Error("活动时间盒必须在一至二十分钟之间。");
    }
    if (!validDate(input && input.dueDate)) {
      throw new Error("请输入有效的截止日期。");
    }
    return {
      activity: cleanText(input.activity, "活动", 300),
      evidence: cleanText(input.evidence, "完成证据", 300),
      dueDate: input.dueDate,
      timeboxMinutes,
      contactMode,
      decisionRule: cleanText(input.decisionRule, "决策规则", 500),
      metrics: normalizeMetrics(input.metrics),
    };
  }

  function lockContractVersion(state, input, now) {
    assertBaseState(state);
    const normalized = validateContractInput(state, input);
    const lockedAt = timestamp(now);
    const previousVersion = state.contracts.reduce(
      (highest, contract) => Math.max(highest, Number(contract.version) || 0),
      0,
    );
    const contracts = state.contracts.map((contract) => (
      contract.status === "locked"
        ? { ...clone(contract), status: "superseded", supersededAt: lockedAt }
        : clone(contract)
    ));
    contracts.push({
      id: makeId("contract"),
      goalId: state.goal.id,
      version: previousVersion + 1,
      status: "locked",
      riskLevel: state.goal.riskLevel,
      lockedAt,
      ...normalized,
    });
    return {
      ...clone(state),
      updatedAt: lockedAt,
      contracts,
    };
  }

  function normalizeMetricValues(contract, values) {
    if (!values || typeof values !== "object" || Array.isArray(values)) {
      return {};
    }
    const allowed = new Set(contract.metrics.map((metric) => metric.id));
    return Object.fromEntries(Object.entries(values)
      .filter(([key, value]) => allowed.has(key) && value !== "" && value !== null)
      .map(([key, value]) => [key, optionalText(value, 80)]));
  }

  function recordObservation(state, input, now) {
    assertBaseState(state);
    const active = getActiveContract(state);
    if (!active || !input || input.contractId !== active.id) {
      throw new Error("观察必须引用当前已锁定合同。");
    }
    if (!validDate(input.date)) {
      throw new Error("请输入有效的观察日期。");
    }
    if (!OPPORTUNITIES.includes(input.opportunity)) {
      throw new Error("机会状态无效。");
    }
    if (!DECISION_IDS.includes(input.decision)) {
      throw new Error("请选择受支持的下一决定。");
    }

    const noOpportunity = input.opportunity === "noOpportunity";
    const note = optionalText(input.note, 1000);
    if (noOpportunity && !note) {
      throw new Error("无机会记录必须说明客观原因。");
    }
    const minutes = noOpportunity ? 0 : Number(input.minutes);
    if (!Number.isInteger(minutes) || minutes < 0 || minutes > 20) {
      throw new Error("观察用时必须在零至二十分钟之间。");
    }
    const usedToday = state.observations
      .filter((observation) => observation.date === input.date)
      .reduce((sum, observation) => sum + observation.minutes, 0);
    if (usedToday + minutes > 20) {
      throw new Error("每日证据活动不能超过二十分钟。");
    }

    const observedAt = timestamp(now);
    const observation = {
      id: makeId("observation"),
      goalId: state.goal.id,
      contractId: active.id,
      contractVersion: active.version,
      date: input.date,
      opportunity: input.opportunity,
      evidenceObserved: noOpportunity ? false : Boolean(input.evidenceObserved),
      minutes,
      metricValues: noOpportunity ? {} : normalizeMetricValues(active, input.metricValues),
      decision: input.decision,
      note,
      observedAt,
    };
    const exitsGoal = observation.decision === "exit";
    const contracts = exitsGoal
      ? state.contracts.map((contract) => (
        contract.id === active.id
          ? { ...clone(contract), status: "closed", closedAt: observedAt }
          : clone(contract)
      ))
      : clone(state.contracts);
    const goal = exitsGoal
      ? { ...clone(state.goal), status: "exited", exitedAt: observedAt }
      : clone(state.goal);
    return {
      ...clone(state),
      updatedAt: observedAt,
      goal,
      contracts,
      observations: [...clone(state.observations), observation],
    };
  }

  function computeEcr(state, contractId) {
    assertBaseState(state);
    const eligible = state.observations.filter((observation) => (
      observation.opportunity === "available"
      && (!contractId || observation.contractId === contractId)
    ));
    const completed = eligible.filter((observation) => observation.evidenceObserved).length;
    return {
      completed,
      opportunities: eligible.length,
      value: eligible.length ? completed / eligible.length : null,
    };
  }

  function assertUnique(items, field, label) {
    const values = items.map((item) => item[field]);
    if (new Set(values).size !== values.length) {
      throw new Error(`${label}不能重复。`);
    }
  }

  function assertKnownKeys(value, allowedKeys, label) {
    const allowed = new Set(allowedKeys);
    const unknown = Object.keys(value).filter((key) => !allowed.has(key));
    if (unknown.length) {
      throw new Error(`${label}包含未知字段：${unknown.join("、")}。`);
    }
  }

  function validateImportedContract(contract, goal) {
    if (!contract || typeof contract !== "object") throw new Error("合同无效。");
    assertKnownKeys(contract, [
      "id", "goalId", "version", "status", "riskLevel", "lockedAt", "supersededAt",
      "closedAt", "activity", "evidence", "dueDate", "timeboxMinutes", "contactMode",
      "decisionRule", "metrics",
    ], "合同");
    cleanText(contract.id, "合同标识", 200);
    if (contract.goalId !== goal.id) throw new Error("合同与目标不匹配。");
    if (!Number.isInteger(contract.version) || contract.version < 1) {
      throw new Error("合同版本无效。");
    }
    if (!CONTRACT_STATUSES.includes(contract.status)) throw new Error("合同状态无效。");
    const contractRisk = normalizeRisk(contract.riskLevel);
    if (contractRisk !== goal.riskLevel) {
      throw new Error("合同风险快照与目标不一致。");
    }
    if (!CONTACT_MODES.includes(contract.contactMode)) throw new Error("接触方式无效。");
    if (requiresSafetyBoundary(contractRisk) && contract.contactMode === "direct") {
      throw new Error("不允许导入高风险直接测试。");
    }
    cleanText(contract.activity, "活动", 300);
    cleanText(contract.evidence, "完成证据", 300);
    cleanText(contract.decisionRule, "决策规则", 500);
    if (!validDate(contract.dueDate)) throw new Error("合同截止日期无效。");
    if (!Number.isInteger(contract.timeboxMinutes)
      || contract.timeboxMinutes < 1
      || contract.timeboxMinutes > 20) {
      throw new Error("合同时间盒无效。");
    }
    if (!Array.isArray(contract.metrics) || contract.metrics.length < 1 || contract.metrics.length > 2) {
      throw new Error("导入的合同必须包含一至两个指标。");
    }
    contract.metrics.forEach((metric) => {
      if (!metric || typeof metric !== "object" || Array.isArray(metric)) {
        throw new Error("指标无效。");
      }
      assertKnownKeys(metric, ["id", "name", "unit"], "指标");
      cleanText(metric && metric.id, "指标标识", 200);
      cleanText(metric && metric.name, "指标名称", 80);
      optionalText(metric && metric.unit, 30);
    });
    assertUnique(contract.metrics, "id", "指标标识");
  }

  function validateImportedObservation(observation, state, contractById) {
    if (!observation || typeof observation !== "object") throw new Error("观察记录无效。");
    assertKnownKeys(observation, [
      "id", "goalId", "contractId", "contractVersion", "date", "opportunity",
      "evidenceObserved", "minutes", "metricValues", "decision", "note", "observedAt",
    ], "观察记录");
    cleanText(observation.id, "观察标识", 200);
    if (observation.goalId !== state.goal.id) throw new Error("观察记录与目标不匹配。");
    const contract = contractById.get(observation.contractId);
    if (!contract || observation.contractVersion !== contract.version) {
      throw new Error("观察记录与合同不匹配。");
    }
    if (!validDate(observation.date)) throw new Error("观察日期无效。");
    if (!OPPORTUNITIES.includes(observation.opportunity)) throw new Error("机会状态无效。");
    if (typeof observation.evidenceObserved !== "boolean") {
      throw new Error("完成证据状态必须是布尔值。");
    }
    if (!DECISION_IDS.includes(observation.decision)) throw new Error("下一决定无效。");
    if (!Number.isInteger(observation.minutes)
      || observation.minutes < 0
      || observation.minutes > 20) {
      throw new Error("观察分钟数无效。");
    }
    if (observation.opportunity === "noOpportunity"
      && (observation.evidenceObserved || observation.minutes !== 0
        || Object.keys(observation.metricValues || {}).length !== 0)) {
      throw new Error("`noOpportunity` 观察不能包含证据活动。");
    }
    if (!observation.metricValues
      || typeof observation.metricValues !== "object"
      || Array.isArray(observation.metricValues)) {
      throw new Error("观察指标无效。");
    }
    const metricIds = new Set(contract.metrics.map((metric) => metric.id));
    Object.entries(observation.metricValues).forEach(([id, value]) => {
      if (!metricIds.has(id)) throw new Error("观察记录引用了未知指标。");
      optionalText(value, 80);
    });
    const note = optionalText(observation.note, 1000);
    if (observation.opportunity === "noOpportunity" && !note) {
      throw new Error("无机会记录必须说明客观原因。");
    }
  }

  function assertValidBackup(state) {
    assertBaseState(state);
    assertKnownKeys(state, [
      "app", "schemaVersion", "createdAt", "updatedAt", "goal", "contracts", "observations",
    ], "备份");
    timestamp(state.createdAt);
    timestamp(state.updatedAt);
    if (!state.goal || typeof state.goal !== "object") {
      if (state.contracts.length || state.observations.length) {
        throw new Error("缺少目标的数据无效。");
      }
      return;
    }
    assertKnownKeys(state.goal, [
      "id", "title", "why", "riskLevel", "createdAt", "status", "exitedAt",
    ], "目标");
    cleanText(state.goal.id, "目标标识", 200);
    cleanText(state.goal.title, "目标", 160);
    optionalText(state.goal.why, 500);
    normalizeRisk(state.goal.riskLevel);
    if (!GOAL_STATUSES.includes(state.goal.status)) throw new Error("不支持的目标状态。");

    state.contracts.forEach((contract) => validateImportedContract(contract, state.goal));
    assertUnique(state.contracts, "id", "合同标识");
    assertUnique(state.contracts, "version", "合同版本");
    const contractsByVersion = state.contracts
      .slice()
      .sort((a, b) => a.version - b.version);
    contractsByVersion.forEach((contract, index) => {
      if (contract.version !== index + 1) {
        throw new Error("合同版本时间线必须从 v1 连续递增。");
      }
    });
    if (contractsByVersion.length > 0) {
      const latestContract = contractsByVersion[contractsByVersion.length - 1];
      const historicalContracts = contractsByVersion.slice(0, -1);
      const historyValid = historicalContracts.every(
        (contract) => contract.status === "superseded",
      );
      const latestStatus = state.goal.status === "active" ? "locked" : "closed";
      if (!historyValid || latestContract.status !== latestStatus) {
        throw new Error("合同版本时间线与目标状态不一致。");
      }
    }
    const contractById = new Map(state.contracts.map((contract) => [contract.id, contract]));
    state.observations.forEach((observation) => (
      validateImportedObservation(observation, state, contractById)
    ));
    assertUnique(state.observations, "id", "观察标识");

    const exitObservations = state.observations.filter(
      (observation) => observation.decision === "exit",
    );
    if (exitObservations.length > 1) {
      throw new Error("同一目标只能包含一条退出决定。");
    }
    if (exitObservations.length === 1) {
      const exitContract = contractById.get(exitObservations[0].contractId);
      const latestVersion = state.contracts.reduce(
        (highest, contract) => Math.max(highest, contract.version),
        0,
      );
      if (state.goal.status !== "exited" || !exitContract
        || exitContract.status !== "closed" || exitContract.version !== latestVersion) {
        throw new Error("退出决定必须对应已退出目标和最新的已关闭合同。");
      }
    } else if (state.goal.status === "exited") {
      throw new Error("已退出目标必须保留对应的退出决定。");
    }

    const minutesByDate = new Map();
    state.observations.forEach((observation) => {
      const next = (minutesByDate.get(observation.date) || 0) + observation.minutes;
      if (next > 20) throw new Error("导入数据中的每日活动超过二十分钟。");
      minutesByDate.set(observation.date, next);
    });
  }

  function validateState(state) {
    try {
      assertValidBackup(state);
      return { ok: true, error: "" };
    } catch (error) {
      return { ok: false, error: error.message };
    }
  }

  function exportState(state) {
    assertValidBackup(state);
    return JSON.stringify(state, null, 2);
  }

  function diagnosticSuggestion(payload) {
    const isRouterExport = Boolean(
      payload
      && payload.schemaVersion === "1.0"
      && payload.draft
      && typeof payload.draft === "object"
      && payload.draft.schemaVersion === "1.0"
      && payload.assessment
      && typeof payload.assessment === "object"
      && payload.assessment.schemaVersion === "1.0",
    );
    if (isRouterExport) {
      const assessment = payload.assessment;
      const routeCopy = assessment.routeCopy && typeof assessment.routeCopy === "object"
        ? assessment.routeCopy
        : {};
      const supportMessage = optionalText(
        routeCopy.instruction
          || (assessment.risk && assessment.risk.message)
          || "请优先使用诊断工具中的支持路线。",
        500,
      );
      if (assessment.currentRoute === "urgent_support" || assessment.canContinue === false) {
        return {
          blocked: true,
          message: supportMessage || "请优先使用诊断工具中的支持路线。",
          source: "next-step-router-result",
        };
      }
      if (assessment.canContinue !== true) {
        throw new Error("诊断导出数据没有确认可继续状态。");
      }
      return {
        blocked: false,
        title: cleanText(payload.draft.goal, "Suggested goal", 160),
        why: supportMessage,
        riskLevel: "medium",
        source: "next-step-router-result",
      };
    }

    const recognizedApps = [
      "reversible-progress-diagnostic",
      "next-evidence-diagnostic",
      "diagnostic-tool",
    ];
    const recognized = recognizedApps.includes(payload && payload.app)
      || (payload && payload.kind === "diagnostic-result");
    if (!recognized || payload.schemaVersion !== 1) return null;

    const result = payload.result && typeof payload.result === "object" ? payload.result : payload;
    const rawGoal = result.suggestedGoal || result.recommendedGoal || result.focusAction || result.goal;
    const title = typeof rawGoal === "object" && rawGoal
      ? rawGoal.title
      : rawGoal;
    if (typeof title !== "string" || !title.trim()) {
      throw new Error("诊断 JSON 数据中没有可供确认的目标建议。");
    }
    const rawRisk = result.riskLevel || payload.riskLevel || "medium";
    const riskLevel = RISK_LEVELS.includes(rawRisk) ? rawRisk : "medium";
    return {
      blocked: false,
      title: cleanText(title, "Suggested goal", 160),
      why: optionalText(result.focus || result.reason || result.summary, 500),
      riskLevel,
      source: payload.app || payload.kind,
    };
  }

  function importJsonSafely(currentState, rawJson) {
    let parsed;
    try {
      parsed = JSON.parse(rawJson);
      if (parsed && parsed.app === APP_ID) {
        assertValidBackup(parsed);
        return { ok: true, kind: "backup", state: clone(parsed), error: "" };
      }
      const suggestion = diagnosticSuggestion(parsed);
      if (suggestion) {
        if (suggestion.blocked) {
          return {
            ok: false,
            kind: "support",
            state: currentState,
            error: suggestion.message,
          };
        }
        return {
          ok: true,
          kind: "diagnostic",
          state: currentState,
          suggestion,
          error: "",
        };
      }
      throw new Error("不支持的导入数据格式。");
    } catch (error) {
      return {
        ok: false,
        kind: "rejected",
        state: currentState,
        error: error.message,
      };
    }
  }

  function clearState(state, now) {
    assertBaseState(state);
    return createState(now);
  }

  return {
    APP_ID,
    CONTACT_MODES,
    DECISIONS,
    RISK_LEVELS,
    SCHEMA_VERSION,
    STORAGE_KEY,
    clearState,
    computeEcr,
    createGoal,
    createState,
    exportState,
    getActiveContract,
    importJsonSafely,
    lockContractVersion,
    recordObservation,
    requiresSafetyBoundary,
    validateState,
  };
}));
