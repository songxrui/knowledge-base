(function startNextEvidence() {
  "use strict";

  const logic = window.NextEvidence;
  const ui = window.NextEvidenceUI;
  if (!logic || !ui) {
    document.body.textContent = "“下一次证据”的核心逻辑加载失败。";
    return;
  }

  const $ = (id) => document.getElementById(id);
  const riskLabels = {
    low: "低风险",
    medium: "中等风险",
    high: "高风险",
    "safety-critical": "安全关键",
  };
  const modeLabels = {
    direct: "低风险直接测试",
    simulation: "有界模拟",
    supervised: "监督下测试",
  };
  const decisionLabels = Object.fromEntries(
    logic.DECISIONS.map((decision) => [decision.id, decision.label]),
  );
  const statusLabels = {
    active: "进行中",
    exited: "已退出",
    locked: "已锁定",
    superseded: "已替代",
    closed: "已关闭",
  };
  const decisionGuidance = {
    keep: {
      help: "记录什么信号支持继续使用当前合同。",
      placeholder: "只写支持保持的事实，不写自我评价。",
    },
    revise: {
      help: "记录要改变的一个合同字段和依据。",
      placeholder: "例如：活动范围过大，下版只缩小活动，不改证据。",
    },
    boundedLearning: {
      help: "记录缺失知识和停止学习的条件。",
      placeholder: "例如：只查清接口限制，得到可测试答案后停止。",
    },
    resource: {
      help: "记录缺少的权限、时间、设备或协作条件。",
      placeholder: "例如：等待对方授权；授权前不把无机会计作失败。",
    },
    measurement: {
      help: "记录当前证据为什么不可判读，以及要修的测量。",
      placeholder: "例如：回复无法归因；下一版只改变反馈窗口。",
    },
    exit: {
      help: "记录目标为何不再值得继续；提交后将关闭目标与合同。",
      placeholder: "退出是有效结论。记录价值、代价或证据变化。",
    },
    support: {
      help: "记录需要哪类支持，以及暂不自行推进的边界。",
      placeholder: "例如：先联系具备相应资质或权限的人。",
    },
  };

  let persistedSnapshot = null;
  let recoveryRaw = null;
  let storageFailure = "";
  let state = loadInitialState();
  let revisionOpen = false;
  let pendingImport = null;
  let currentWorkspace = ui.derivePrimaryWorkspace(state, {
    recoveryPending: recoveryRaw !== null,
  });
  let contractStage = 1;
  let ledgerScope = "current";

  const workspaceIds = {
    goal: "goal-section",
    contract: "contract-section",
    observation: "observation-section",
    ledger: "ledger-section",
    recovery: "recovery-panel",
  };
  const workspaceHeadings = {
    goal: "goal-heading",
    contract: "contract-heading",
    observation: "observation-heading",
    ledger: "ledger-heading",
    recovery: "recovery-heading",
  };

  function readStoredState() {
    try {
      return window.localStorage.getItem(logic.STORAGE_KEY);
    } catch (error) {
      storageFailure = `浏览器拒绝访问本地存储：${error.message}`;
      return null;
    }
  }

  function writeStoredState(serialized) {
    if (storageFailure) throw new Error(storageFailure);
    try {
      window.localStorage.setItem(logic.STORAGE_KEY, serialized);
    } catch (error) {
      storageFailure = `无法保存到本地存储：${error.message}`;
      throw new Error(storageFailure);
    }
  }

  function removeStoredState() {
    if (storageFailure) throw new Error(storageFailure);
    try {
      window.localStorage.removeItem(logic.STORAGE_KEY);
    } catch (error) {
      storageFailure = `无法清空本地存储：${error.message}`;
      throw new Error(storageFailure);
    }
  }

  function localDate(offsetDays = 0) {
    const date = new Date();
    date.setHours(12, 0, 0, 0);
    date.setDate(date.getDate() + offsetDays);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, "0");
    const day = String(date.getDate()).padStart(2, "0");
    return `${year}-${month}-${day}`;
  }

  function loadInitialState() {
    const empty = logic.createState();
    const raw = readStoredState();
    if (storageFailure) {
      window.setTimeout(() => showMessage(`${storageFailure}。请允许本地存储后刷新。`, true), 0);
      return empty;
    }
    if (!raw) return empty;
    persistedSnapshot = raw;
    const imported = logic.importJsonSafely(empty, raw);
    if (imported.ok && imported.kind === "backup") return imported.state;
    recoveryRaw = raw;
    window.setTimeout(() => {
      showMessage("现有本地数据未通过校验。新记录已暂停写入，请先处理恢复数据。", true);
    }, 0);
    return empty;
  }

  function showMessage(text, isError = false) {
    const element = $("message");
    element.textContent = text;
    element.classList.toggle("error", isError);
    element.setAttribute("role", isError ? "alert" : "status");
    element.setAttribute("aria-live", isError ? "assertive" : "polite");
    element.hidden = false;
  }

  function clearMessage() {
    const element = $("message");
    element.hidden = true;
    element.textContent = "";
    element.classList.remove("error");
  }

  function clearFieldErrors(container = document) {
    container.querySelectorAll(".field-error").forEach((error) => {
      error.hidden = true;
      error.textContent = "";
    });
    container.querySelectorAll('[aria-invalid="true"]').forEach((field) => {
      field.removeAttribute("aria-invalid");
    });
  }

  function showFieldError(fieldId, message, focus = true) {
    const field = $(fieldId);
    const error = $(`${fieldId}-error`);
    if (!field || !error) {
      showMessage(message, true);
      return false;
    }
    field.setAttribute("aria-invalid", "true");
    error.textContent = message;
    error.hidden = false;
    if (focus) field.focus();
    return false;
  }

  function fieldForContractError(message) {
    if (/完成证据/.test(message)) return "contract-evidence";
    if (/活动/.test(message) && !/时间盒/.test(message)) return "contract-activity";
    if (/截止日期/.test(message)) return "contract-due";
    if (/时间盒|二十分钟/.test(message)) return "contract-timebox";
    if (/接触方式|高风险/.test(message)) return "contact-mode";
    if (/指标/.test(message)) return "metric-one-name";
    if (/决策规则/.test(message)) return "contract-rule";
    return "contract-rule";
  }

  function renderContractStage(focus = false) {
    document.querySelectorAll("[data-contract-stage]").forEach((stage) => {
      stage.hidden = Number(stage.dataset.contractStage) !== contractStage;
    });
    document.querySelectorAll("[data-contract-progress]").forEach((item) => {
      const stage = Number(item.dataset.contractProgress);
      item.classList.toggle("is-current", stage === contractStage);
      item.classList.toggle("is-complete", stage < contractStage);
      if (stage === contractStage) item.setAttribute("aria-current", "step");
      else item.removeAttribute("aria-current");
    });
    $("contract-back-button").hidden = contractStage === 1;
    $("contract-next-button").hidden = contractStage === 3;
    $("lock-contract-button").hidden = contractStage !== 3;
    if (focus) {
      const stage = document.querySelector(`[data-contract-stage="${contractStage}"]`);
      stage?.querySelector("input, textarea, select")?.focus();
    }
  }

  function validateContractStage(stage) {
    clearFieldErrors($("contract-form"));
    if (stage === 1) {
      if (!$("contract-activity").value.trim()) {
        return showFieldError("contract-activity", "请先写下这一版唯一要做的活动。");
      }
      if (!$("contract-evidence").value.trim()) {
        return showFieldError("contract-evidence", "请写下完成后可以回看的证据。");
      }
    }
    if (stage === 2) {
      if (!$("contract-due").value) return showFieldError("contract-due", "请选择截止日期。");
      const minutes = Number($("contract-timebox").value);
      if (!Number.isInteger(minutes) || minutes < 1 || minutes > 20) {
        return showFieldError("contract-timebox", "时间盒必须是 1–20 分钟的整数。");
      }
      if (logic.requiresSafetyBoundary(state.goal?.riskLevel)
        && $("contact-mode").value === "direct") {
        return showFieldError("contact-mode", "高风险目标请选择有界模拟或监督下测试；其他输入已保留。");
      }
      if (!$("metric-one-name").value.trim()) {
        return showFieldError("metric-one-name", "至少填写一个可观察指标。");
      }
    }
    if (stage === 3 && !$("contract-rule").value.trim()) {
      return showFieldError("contract-rule", "请写下观察后如何作出下一决定。");
    }
    return true;
  }

  function commit(nextState, successMessage) {
    if (recoveryRaw !== null) {
      throw new Error("请先下载或明确弃用未通过校验的本地数据。");
    }
    if (readStoredState() !== persistedSnapshot) {
      throw new Error("另一标签页已经更新本地数据。请刷新本页后再继续，当前写入已取消。");
    }
    const validation = logic.validateState(nextState);
    if (!validation.ok) throw new Error(validation.error);
    const serialized = logic.exportState(nextState);
    writeStoredState(serialized);
    persistedSnapshot = serialized;
    state = nextState;
    currentWorkspace = ui.derivePrimaryWorkspace(state, {
      recoveryPending: recoveryRaw !== null,
      revisionOpen,
    });
    render();
    showMessage(successMessage);
  }

  function setText(id, text) {
    $(id).textContent = text || "-";
  }

  function downloadText(contents, filename, type = "application/json") {
    const blob = new Blob([contents], { type });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = filename;
    document.body.append(link);
    link.click();
    link.remove();
    URL.revokeObjectURL(url);
  }

  function moveTo(targetId, focusId) {
    const workspace = Object.entries(workspaceIds)
      .find(([, sectionId]) => sectionId === targetId)?.[0];
    if (workspace) {
      const availability = ui.workspaceAvailability(state);
      if (workspace !== "recovery" && !availability[workspace]) return;
      currentWorkspace = workspace;
      renderWorkspace();
      renderWorkflow();
    }
    window.requestAnimationFrame(() => {
      const target = $(targetId);
      if (!target || target.hidden) return;
      target.scrollIntoView({ block: "start", behavior: "auto" });
      const focusTarget = focusId ? $(focusId) : null;
      if (focusTarget && !focusTarget.disabled && !focusTarget.hidden) {
        focusTarget.focus({ preventScroll: true });
      }
    });
  }

  function renderWorkspace() {
    const availability = ui.workspaceAvailability(state);
    if (currentWorkspace !== "recovery" && !availability[currentWorkspace]) {
      currentWorkspace = ui.derivePrimaryWorkspace(state, {
        recoveryPending: recoveryRaw !== null,
        revisionOpen,
      });
    }
    Object.entries(workspaceIds).forEach(([workspace, id]) => {
      const section = $(id);
      if (!section) return;
      const isRecovery = workspace === "recovery";
      const canShow = isRecovery ? recoveryRaw !== null : availability[workspace];
      section.hidden = !(canShow && currentWorkspace === workspace);
      section.classList.toggle("is-active", canShow && currentWorkspace === workspace);
    });
    document.body.dataset.workspace = currentWorkspace;
  }

  function openWorkspace(workspace, focusId) {
    const id = workspaceIds[workspace];
    if (!id) return;
    moveTo(id, focusId || workspaceHeadings[workspace]);
    renderWorkflow();
  }

  function latestObservationFor(contract) {
    if (!contract) return null;
    return state.observations
      .slice()
      .reverse()
      .find((observation) => observation.contractId === contract.id) || null;
  }

  function setStep(id, { available, complete, current, status }) {
    const button = $(id);
    button.disabled = !available;
    button.classList.toggle("is-complete", complete);
    button.classList.toggle("is-current", current);
    button.querySelector("small").textContent = status;
    if (current) button.setAttribute("aria-current", "step");
    else button.removeAttribute("aria-current");
  }

  function renderRecovery() {
    if (recoveryRaw !== null) currentWorkspace = "recovery";
  }

  function renderWorkflow() {
    const active = logic.getActiveContract(state);
    const latest = latestObservationFor(active);
    const activeObservations = active
      ? state.observations.filter((observation) => observation.contractId === active.id)
      : [];
    const hasGoal = Boolean(state.goal);
    const exited = Boolean(state.goal && state.goal.status === "exited");
    let action = {
      title: "确认一个目标",
      copy: "只保留一个真正值得验证的目标。",
      button: "开始",
      target: "goal-section",
      focus: "goal-title",
      current: "goal",
    };

    if (recoveryRaw !== null) {
      action = {
        title: "先处理恢复数据",
        copy: "未通过校验的数据不会被新记录覆盖。",
        button: "查看恢复选项",
        target: "recovery-panel",
        focus: "download-recovery-button",
        current: "goal",
      };
    } else if (exited) {
      action = {
        title: "目标已经退出",
        copy: "退出是有效结果。可查看账本、导出备份或清空后开始新目标。",
        button: "查看退出记录",
        target: "ledger-section",
        current: "ledger",
      };
    } else if (hasGoal && !active) {
      action = {
        title: "锁定活动证据合同",
        copy: "先预览一次活动、完成证据和截止，再生成不可静默覆盖的版本。",
        button: "填写合同",
        target: "contract-section",
        focus: "contract-activity",
        current: "contract",
      };
    } else if (active && (revisionOpen || (latest && latest.decision === "revise"))) {
      action = {
        title: "完成合同修订",
        copy: "上次决定要求修订；只有锁定新版本后，旧合同才会被替代。",
        button: revisionOpen ? "继续填写" : "开始修订",
        target: "contract-section",
        focus: revisionOpen ? "contract-activity" : "revise-contract-button",
        current: "contract",
      };
    } else if (active && latest && latest.decision !== "keep") {
      action = {
        title: decisionLabels[latest.decision],
        copy: decisionGuidance[latest.decision].help,
        button: "查看决定记录",
        target: "ledger-section",
        current: "ledger",
      };
    } else if (active) {
      action = {
        title: latest ? "等待下一次真实机会" : "记录第一次机会",
        copy: latest
          ? "场景再次出现时，记录机会、证据和下一决定。"
          : "先判断约定场景是否真实出现，再记录证据。",
        button: "记录观察",
        target: "observation-section",
        focus: "observation-date",
        current: "observation",
      };
    }

    setText("next-action-title", action.title);
    setText("next-action-copy", action.copy);
    setText("next-action-button", action.button);
    $("next-action-button").dataset.target = action.target;
    $("next-action-button").dataset.focus = action.focus || "";
    const targetSection = $(action.target);
    const hasWorkspacePrimary = targetSection && Array.from(targetSection.querySelectorAll(".button.primary"))
      .some((button) => !button.hidden);
    $("next-action-button").hidden = Boolean(
      currentWorkspace === action.current && hasWorkspacePrimary,
    );

    setStep("step-goal", {
      available: true,
      complete: hasGoal,
      current: currentWorkspace === "goal",
      status: hasGoal ? statusLabels[state.goal.status] : "待开始",
    });
    setStep("step-contract", {
      available: Boolean(hasGoal && !exited),
      complete: state.contracts.length > 0,
      current: currentWorkspace === "contract",
      status: active ? `v${active.version} 已锁定` : (hasGoal && !exited ? "待锁定" : "尚未解锁"),
    });
    setStep("step-observation", {
      available: Boolean(active),
      complete: activeObservations.length > 0,
      current: currentWorkspace === "observation",
      status: activeObservations.length ? `${activeObservations.length} 条当前版本记录` : (active ? "待记录" : "尚未解锁"),
    });
    setStep("step-ledger", {
      available: Boolean(hasGoal || state.contracts.length || state.observations.length),
      complete: state.observations.length > 0,
      current: currentWorkspace === "ledger",
      status: state.observations.length ? `${state.observations.length} 条记录` : "尚无记录",
    });
  }

  function renderGoal() {
    const hasGoal = Boolean(state.goal);
    $("goal-form").hidden = hasGoal;
    $("goal-summary").hidden = !hasGoal;
    $("goal-status").hidden = !hasGoal;

    if (!hasGoal) return;
    setText("goal-summary-title", state.goal.title);
    setText("goal-summary-risk", riskLabels[state.goal.riskLevel]);
    setText("goal-summary-why", state.goal.why || "未填写");
    setText("goal-status", statusLabels[state.goal.status]);
  }

  function renderContractSummary(active) {
    const summary = $("contract-summary");
    summary.hidden = !active;
    if (!active) return;
    setText("contract-summary-activity", active.activity);
    setText("contract-summary-evidence", active.evidence);
    setText("contract-summary-due", active.dueDate);
    setText("contract-summary-time", `${active.timeboxMinutes} 分钟`);
    setText("contract-summary-mode", modeLabels[active.contactMode]);
    setText(
      "contract-summary-metrics",
      active.metrics.map((metric) => (
        metric.unit ? `${metric.name}（${metric.unit}）` : metric.name
      )).join("；"),
    );
    setText("contract-summary-rule", active.decisionRule);
  }

  function contractChangeLabels(previous, current) {
    if (!previous) return ["初始版本"];
    const fields = [
      ["活动", previous.activity, current.activity],
      ["完成证据", previous.evidence, current.evidence],
      ["截止日期", previous.dueDate, current.dueDate],
      ["时间盒", previous.timeboxMinutes, current.timeboxMinutes],
      ["接触方式", previous.contactMode, current.contactMode],
      ["观察指标", JSON.stringify(previous.metrics.map(({ name, unit }) => ({ name, unit }))), JSON.stringify(current.metrics.map(({ name, unit }) => ({ name, unit })))],
      ["决策规则", previous.decisionRule, current.decisionRule],
    ];
    return fields.filter(([, before, after]) => before !== after).map(([label]) => label);
  }

  function revisionReason(previous) {
    if (!previous) return "初始版本";
    const observation = state.observations
      .slice()
      .reverse()
      .find((item) => item.contractId === previous.id && item.decision === "revise");
    return observation && observation.note ? observation.note : "未记录修订依据";
  }

  function renderContractHistory() {
    const block = $("contract-history-block");
    const list = $("contract-history");
    list.replaceChildren();
    block.hidden = state.contracts.length === 0;
    const byVersion = new Map(state.contracts.map((contract) => [contract.version, contract]));
    state.contracts
      .slice()
      .sort((a, b) => b.version - a.version)
      .forEach((contract) => {
        const previous = byVersion.get(contract.version - 1);
        const changes = contractChangeLabels(previous, contract);
        const item = document.createElement("li");
        const heading = document.createElement("strong");
        const activity = document.createElement("span");
        const detail = document.createElement("small");
        heading.textContent = `v${contract.version} · ${statusLabels[contract.status]}`;
        activity.textContent = contract.activity;
        detail.textContent = previous
          ? `变更：${changes.join("、") || "无字段差异"}；依据：${revisionReason(previous)}`
          : "初始版本";
        item.append(heading, activity, detail);
        list.append(item);
      });
  }

  function applyRiskBoundary() {
    if (!state.goal) return;
    const requiresBoundary = logic.requiresSafetyBoundary(state.goal.riskLevel);
    $("safety-boundary").hidden = !requiresBoundary;
  }

  function renderContract() {
    const goalActive = state.goal && state.goal.status === "active";
    $("contract-section").hidden = !goalActive;
    if (!goalActive) return;

    const active = logic.getActiveContract(state);
    renderContractSummary(active);
    renderContractHistory();
    $("contract-form").hidden = Boolean(active) && !revisionOpen;
    $("cancel-revision-button").hidden = !revisionOpen;
    $("revise-contract-button").hidden = revisionOpen;
    const latest = latestObservationFor(active);
    const pendingRevision = Boolean(active && latest && latest.decision === "revise");
    $("revision-state-note").hidden = !pendingRevision && !revisionOpen;
    if (pendingRevision || revisionOpen) {
      $("revision-state-note").textContent = revisionOpen
        ? "正在起草新版本；旧合同仍保持锁定，直到新版本提交成功。"
        : "上次决定是修订，但新版本尚未锁定。";
    }
    $("revise-contract-button").textContent = pendingRevision ? "继续修订" : "修订合同";

    const nextVersion = state.contracts.reduce(
      (max, contract) => Math.max(max, contract.version),
      0,
    ) + 1;
    setText("contract-version", active && !revisionOpen ? `v${active.version} 已锁定` : `待锁定 v${nextVersion}`);
    $("lock-contract-button").textContent = `锁定 v${nextVersion}`;
    if (!$("contract-due").value) $("contract-due").value = localDate(1);
    applyRiskBoundary();
    renderContractPreview();
    renderContractStage();
  }

  function renderContractPreview() {
    const activity = $("contract-activity").value.trim();
    const evidence = $("contract-evidence").value.trim();
    if (!activity && !evidence) {
      setText("contract-preview-text", "填写活动与完成证据后，这里会生成可复述的合同。");
      return;
    }
    const dueDate = $("contract-due").value || "待定日期";
    const minutes = $("contract-timebox").value || "待定";
    const mode = modeLabels[$("contact-mode").value] || "待定接触方式";
    setText(
      "contract-preview-text",
      `在 ${dueDate} 前，以${mode}完成“${activity || "待填写活动"}”，最多 ${minutes} 分钟；完成证据是“${evidence || "待填写证据"}”。`,
    );
  }

  function renderMetricInputs(active) {
    const container = $("metric-value-fields");
    container.replaceChildren();
    if (!active) return;
    active.metrics.forEach((metric) => {
      const label = document.createElement("label");
      label.className = "field";
      const span = document.createElement("span");
      span.textContent = metric.unit ? `${metric.name}（${metric.unit}）` : metric.name;
      const input = document.createElement("input");
      input.maxLength = 80;
      input.dataset.metricId = metric.id;
      input.autocomplete = "off";
      label.append(span, input);
      container.append(label);
    });
  }

  function renderObservation() {
    const active = logic.getActiveContract(state);
    const canObserve = Boolean(active && state.goal && state.goal.status === "active");
    $("observation-section").hidden = !canObserve;
    if (!canObserve) return;
    if (!$("observation-date").value) $("observation-date").value = localDate();
    renderMetricInputs(active);
    toggleOpportunityFields();
    updateDecisionHelp();
  }

  function appendCell(row, text) {
    const cell = document.createElement("td");
    cell.textContent = text;
    row.append(cell);
  }

  function observationFacts(observation, contract) {
    const metricById = new Map(contract.metrics.map((metric) => [metric.id, metric]));
    const metricText = Object.entries(observation.metricValues || {})
      .map(([id, value]) => {
        const metric = metricById.get(id);
        return metric ? `${metric.name}: ${value}${metric.unit ? ` ${metric.unit}` : ""}` : "";
      })
      .filter(Boolean)
      .join("；");
    return [metricText, observation.note].filter(Boolean).join(" | ") || "-";
  }

  function renderLedger() {
    const hasData = Boolean(state.goal || state.contracts.length || state.observations.length);
    if (!hasData) return;

    const active = logic.getActiveContract(state);
    const referenceContract = ui.referenceContract(state);
    const ecr = referenceContract
      ? logic.computeEcr(state, referenceContract.id)
      : logic.computeEcr(state);
    setText("ecr-count", `${ecr.completed} / ${ecr.opportunities}`);
    setText(
      "ecr-note",
      ecr.opportunities === 0
        ? "还没有有机会记录，不代表失败。"
        : "只计算真实出现的机会；无机会记录不进入分母。",
    );
    setText(
      "no-opportunity-count",
      String(state.observations.filter((item) => (
        item.opportunity === "noOpportunity"
        && (!referenceContract || item.contractId === referenceContract.id)
      )).length),
    );
    setText(
      "active-version-count",
      referenceContract
        ? `v${referenceContract.version}${active ? "" : "（已关闭）"}`
        : "-",
    );

    const records = ui.ledgerRecords(state, ledgerScope);
    const body = $("observation-table-body");
    body.replaceChildren();
    const list = $("observation-list");
    list.replaceChildren();
    const contractById = new Map(state.contracts.map((contract) => [contract.id, contract]));
    records.forEach((observation) => {
      const contract = contractById.get(observation.contractId);
      const opportunity = observation.opportunity === "available" ? "有机会" : "无机会";
      const evidence = observation.opportunity === "noOpportunity"
        ? "—"
        : (observation.evidenceObserved ? "已留痕" : "未留痕");
      const facts = observationFacts(observation, contract);
      const row = document.createElement("tr");
      appendCell(row, observation.date);
      appendCell(row, `v${observation.contractVersion}`);
      appendCell(row, opportunity);
      appendCell(row, evidence);
      appendCell(row, decisionLabels[observation.decision]);
      appendCell(row, String(observation.minutes));
      appendCell(row, facts);
      body.append(row);

      const item = document.createElement("li");
      item.className = "ledger-item";
      const heading = document.createElement("div");
      heading.className = "ledger-item-heading";
      const date = document.createElement("strong");
      date.textContent = observation.date;
      const version = document.createElement("span");
      version.textContent = `v${observation.contractVersion}`;
      heading.append(date, version);
      const details = document.createElement("dl");
      [
        ["机会", opportunity],
        ["证据", evidence],
        ["决定", decisionLabels[observation.decision]],
        ["分钟", String(observation.minutes)],
        ["事实", facts],
      ].forEach(([label, value]) => {
        const dt = document.createElement("dt");
        const dd = document.createElement("dd");
        dt.textContent = label;
        dd.textContent = value;
        details.append(dt, dd);
      });
      item.append(heading, details);
      list.append(item);
    });
    $("empty-ledger").hidden = records.length > 0;
    $("table-wrap").hidden = records.length === 0;
    list.hidden = records.length === 0;
    $("ledger-current-button").classList.toggle("is-selected", ledgerScope === "current");
    $("ledger-current-button").setAttribute("aria-pressed", String(ledgerScope === "current"));
    $("ledger-all-button").classList.toggle("is-selected", ledgerScope === "all");
    $("ledger-all-button").setAttribute("aria-pressed", String(ledgerScope === "all"));
  }

  function render() {
    renderRecovery();
    renderGoal();
    renderContract();
    renderObservation();
    renderLedger();
    renderWorkflow();
    renderWorkspace();
  }

  function fillContractForm(contract) {
    $("contract-activity").value = contract.activity;
    $("contract-evidence").value = contract.evidence;
    $("contract-due").value = contract.dueDate;
    $("contract-timebox").value = String(contract.timeboxMinutes);
    $("contact-mode").value = contract.contactMode;
    $("contract-rule").value = contract.decisionRule;
    $("metric-one-name").value = contract.metrics[0] ? contract.metrics[0].name : "";
    $("metric-one-unit").value = contract.metrics[0] ? contract.metrics[0].unit : "";
    $("metric-two-name").value = contract.metrics[1] ? contract.metrics[1].name : "";
    $("metric-two-unit").value = contract.metrics[1] ? contract.metrics[1].unit : "";
    applyRiskBoundary();
    renderContractPreview();
  }

  function resetContractForm() {
    $("contract-form").reset();
    contractStage = 1;
    clearFieldErrors($("contract-form"));
    $("contract-timebox").value = "15";
    $("contract-due").value = localDate(1);
    applyRiskBoundary();
    renderContractPreview();
    renderContractStage();
  }

  function toggleOpportunityFields() {
    const selected = document.querySelector('input[name="opportunity"]:checked');
    const noOpportunity = selected && selected.value === "noOpportunity";
    $("evidence-fields").hidden = noOpportunity;
    $("evidence-observed").disabled = noOpportunity;
    $("observation-minutes").disabled = noOpportunity;
    $("observation-note").required = Boolean(noOpportunity);
    $("metric-value-fields").querySelectorAll("input").forEach((input) => {
      input.disabled = noOpportunity;
    });
    $("opportunity-note").textContent = noOpportunity
      ? "无机会不进入分母；只用于约定场景没有出现，或资源、权限实际阻断。"
      : "有机会表示约定场景实际出现；没有行动仍应选择“有机会”。";
    $("opportunity-note").classList.toggle("is-warning", noOpportunity);
    if (noOpportunity) {
      $("observation-note").placeholder = "记录无机会的客观原因，例如权限、资源或约定场景未出现。";
    } else {
      updateDecisionHelp();
    }
  }

  function updateDecisionHelp() {
    const decision = $("observation-decision").value || "keep";
    const guidance = decisionGuidance[decision] || decisionGuidance.keep;
    setText("decision-help", guidance.help);
    const noOpportunity = document.querySelector('input[name="opportunity"]:checked')?.value === "noOpportunity";
    if (!noOpportunity) $("observation-note").placeholder = guidance.placeholder;
  }

  function initializeDecisionOptions() {
    const select = $("observation-decision");
    select.replaceChildren();
    logic.DECISIONS.forEach((decision) => {
      const option = document.createElement("option");
      option.value = decision.id;
      option.textContent = decision.label;
      select.append(option);
    });
    updateDecisionHelp();
  }

  $("goal-form").addEventListener("submit", (event) => {
    event.preventDefault();
    clearMessage();
    clearFieldErrors($("goal-form"));
    if (!$("goal-title").value.trim()) {
      showFieldError("goal-title", "请先填写一个具体目标。");
      return;
    }
    try {
      const next = logic.createGoal(state, {
        title: $("goal-title").value,
        why: $("goal-why").value,
        riskLevel: $("goal-risk").value,
      });
      commit(next, "目标已确认。下一步锁定一个活动证据合同。");
      moveTo("contract-section", "contract-activity");
    } catch (error) {
      showFieldError("goal-title", error.message);
    }
  });

  $("contract-next-button").addEventListener("click", () => {
    if (!validateContractStage(contractStage)) return;
    contractStage = Math.min(3, contractStage + 1);
    renderContractStage(true);
  });

  $("contract-back-button").addEventListener("click", () => {
    contractStage = Math.max(1, contractStage - 1);
    clearFieldErrors($("contract-form"));
    renderContractStage(true);
  });

  $("contract-form").addEventListener("submit", (event) => {
    event.preventDefault();
    clearMessage();
    if (contractStage < 3) {
      if (validateContractStage(contractStage)) {
        contractStage += 1;
        renderContractStage(true);
      }
      return;
    }
    if (!validateContractStage(3)) return;
    const metrics = [{
      name: $("metric-one-name").value,
      unit: $("metric-one-unit").value,
    }];
    if ($("metric-two-name").value.trim()) {
      metrics.push({
        name: $("metric-two-name").value,
        unit: $("metric-two-unit").value,
      });
    }
    try {
      const next = logic.lockContractVersion(state, {
        activity: $("contract-activity").value,
        evidence: $("contract-evidence").value,
        dueDate: $("contract-due").value,
        timeboxMinutes: Number($("contract-timebox").value),
        contactMode: $("contact-mode").value,
        metrics,
        decisionRule: $("contract-rule").value,
      });
      revisionOpen = false;
      commit(next, `合同 v${logic.getActiveContract(next).version} 已锁定。`);
      resetContractForm();
      moveTo("observation-section", "observation-date");
    } catch (error) {
      const field = fieldForContractError(error.message);
      const stageByField = {
        "contract-activity": 1,
        "contract-evidence": 1,
        "contract-due": 2,
        "contract-timebox": 2,
        "contact-mode": 2,
        "metric-one-name": 2,
        "contract-rule": 3,
      };
      contractStage = stageByField[field] || 3;
      renderContractStage();
      showFieldError(field, error.message);
    }
  });

  $("revise-contract-button").addEventListener("click", () => {
    const active = logic.getActiveContract(state);
    if (!active) return;
    revisionOpen = true;
    contractStage = 1;
    render();
    fillContractForm(active);
    moveTo("contract-section", "contract-activity");
  });

  $("cancel-revision-button").addEventListener("click", () => {
    revisionOpen = false;
    resetContractForm();
    render();
    openWorkspace("observation", "observation-date");
  });

  $("contract-form").addEventListener("input", renderContractPreview);
  $("contract-form").addEventListener("change", renderContractPreview);

  document.querySelectorAll('input[name="opportunity"]').forEach((input) => {
    input.addEventListener("change", toggleOpportunityFields);
  });
  $("observation-decision").addEventListener("change", updateDecisionHelp);

  $("observation-form").addEventListener("submit", (event) => {
    event.preventDefault();
    clearMessage();
    clearFieldErrors($("observation-form"));
    const active = logic.getActiveContract(state);
    if (!active) return;
    const opportunity = document.querySelector('input[name="opportunity"]:checked').value;
    const metricValues = Object.fromEntries(
      Array.from($("metric-value-fields").querySelectorAll("input"))
        .map((input) => [input.dataset.metricId, input.value]),
    );
    const decision = $("observation-decision").value;
    if (decision === "exit"
      && !window.confirm("退出将关闭当前目标和活动合同。历史记录会保留，继续吗？")) {
      return;
    }
    try {
      const next = logic.recordObservation(state, {
        contractId: active.id,
        date: $("observation-date").value,
        opportunity,
        evidenceObserved: $("evidence-observed").checked,
        minutes: Number($("observation-minutes").value),
        metricValues,
        decision,
        note: $("observation-note").value,
      });
      commit(next, decision === "exit" ? "退出已记录，目标与合同已关闭。" : "观察已保存。");
      $("observation-form").reset();
      $("observation-date").value = localDate();
      $("observation-minutes").value = "10";
      toggleOpportunityFields();
      if (decision === "revise" && logic.getActiveContract(state)) {
        revisionOpen = true;
        render();
        fillContractForm(logic.getActiveContract(state));
        moveTo("contract-section", "contract-activity");
      } else {
        moveTo("ledger-section", "ledger-heading");
      }
    } catch (error) {
      if (/无机会|客观原因/.test(error.message)) {
        showFieldError("observation-note", error.message);
      } else {
        showMessage(error.message, true);
        $("observation-minutes").focus();
      }
    }
  });

  function showImportMessage(text, isError = false) {
    const element = $("import-message");
    element.textContent = text;
    element.classList.toggle("error", isError);
    element.setAttribute("role", isError ? "alert" : "status");
    element.setAttribute("aria-live", isError ? "assertive" : "polite");
    element.hidden = false;
    $("import-text").setAttribute("aria-invalid", String(isError));
  }

  function resetStagedImport() {
    pendingImport = null;
    $("import-preview").hidden = true;
    $("import-preview-text").textContent = "";
    $("confirm-import-button").textContent = "验证并预览";
    $("import-message").hidden = true;
    $("import-message").textContent = "";
    $("import-message").classList.remove("error");
    $("import-text").removeAttribute("aria-invalid");
  }

  function stageImport(raw, result) {
    if (result.kind === "diagnostic") {
      $("import-preview-text").textContent = `将目标“${result.suggestion.title}”以${riskLabels[result.suggestion.riskLevel]}预填到目标表单；不会直接保存。`;
      $("confirm-import-button").textContent = "载入目标表单";
    } else {
      const goal = result.state.goal;
      const title = goal ? goal.title : "空数据";
      const risk = goal ? riskLabels[goal.riskLevel] : "无";
      $("import-preview-text").textContent = `备份目标：${title}；风险：${risk}；合同 ${result.state.contracts.length} 份；观察 ${result.state.observations.length} 条。确认后将替换当前本地数据。`;
      $("confirm-import-button").textContent = "确认替换本地数据";
    }
    $("import-preview").hidden = false;
    pendingImport = { raw, result };
    showImportMessage("校验通过。请核对预览后再次确认。", false);
  }

  function applyPendingImport() {
    if (!pendingImport) return;
    const { result } = pendingImport;
    if (recoveryRaw !== null) {
      showImportMessage("请先下载或明确弃用未通过校验的本地数据，再执行导入。", true);
      return;
    }
    if (result.kind === "diagnostic") {
      if (state.goal) {
        showImportMessage("当前已有目标，诊断建议不会覆盖现有数据。", true);
        return;
      }
      $("goal-title").value = result.suggestion.title;
      $("goal-why").value = result.suggestion.why;
      $("goal-risk").value = result.suggestion.riskLevel;
      $("import-dialog").close();
      showMessage("诊断建议已载入目标表单，确认后才会保存。");
      moveTo("goal-section", "goal-title");
      return;
    }
    try {
      revisionOpen = false;
      commit(result.state, "备份已导入。");
      $("import-dialog").close();
      moveTo("next-action-button", "next-action-button");
    } catch (error) {
      showImportMessage(`导入失败：${error.message}。现有数据未改变。`, true);
    }
  }

  $("export-button").addEventListener("click", () => {
    clearMessage();
    try {
      if (recoveryRaw !== null) {
        throw new Error("当前存在待处理的恢复数据，请使用“下载原始数据”。");
      }
      downloadText(logic.exportState(state), `next-evidence-${localDate()}.json`);
      showMessage("JSON 已导出。");
    } catch (error) {
      showMessage(error.message, true);
    }
  });

  $("download-recovery-button").addEventListener("click", () => {
    if (recoveryRaw === null) return;
    downloadText(recoveryRaw, `next-evidence-recovery-${localDate()}.txt`, "text/plain");
    showMessage("原始恢复数据已下载。本地内容仍保持不变。");
  });

  $("discard-recovery-button").addEventListener("click", () => {
    if (recoveryRaw === null) return;
    if (!window.confirm("确认弃用未通过校验的原始数据？建议先下载留档。")) return;
    if (readStoredState() !== persistedSnapshot) {
      showMessage("另一标签页已经改变本地数据。请刷新本页后重新判断是否弃用。", true);
      return;
    }
    try {
      removeStoredState();
      persistedSnapshot = null;
      recoveryRaw = null;
      state = logic.clearState(state);
      revisionOpen = false;
      render();
      showMessage("恢复数据已弃用，现在可以创建新记录。");
      moveTo("goal-section", "goal-title");
    } catch (error) {
      showMessage(error.message, true);
    }
  });

  $("import-button").addEventListener("click", () => {
    clearMessage();
    $("import-text").value = "";
    $("import-file").value = "";
    resetStagedImport();
    $("import-dialog").showModal();
    $("import-text").focus();
  });

  $("import-text").addEventListener("input", resetStagedImport);

  $("import-file").addEventListener("change", async (event) => {
    const file = event.target.files && event.target.files[0];
    if (!file) return;
    if (file.size > 1_000_000) {
      showImportMessage("文件超过 1 MB，未读取。请先缩小备份文件。", true);
      return;
    }
    resetStagedImport();
    try {
      $("import-text").value = await file.text();
      showImportMessage("文件已读取。下一步验证并预览。", false);
    } catch (error) {
      showImportMessage(`无法读取文件：${error.message}`, true);
    }
  });

  $("confirm-import-button").addEventListener("click", () => {
    const raw = $("import-text").value;
    if (raw.length > 1_000_000) {
      showImportMessage("粘贴内容超过 1 MB，未解析。", true);
      $("import-text").focus();
      return;
    }
    if (pendingImport && pendingImport.raw === raw) {
      applyPendingImport();
      return;
    }
    resetStagedImport();
    const result = logic.importJsonSafely(state, raw);
    if (!result.ok) {
      const prefix = result.kind === "support" ? "未载入目标" : "导入被拒绝";
      showImportMessage(`${prefix}：${result.error}。现有数据未改变。`, true);
      return;
    }
    if (result.kind === "diagnostic" && state.goal) {
      $("import-preview-text").textContent = `诊断建议目标：${result.suggestion.title}。`;
      $("import-preview").hidden = false;
      showImportMessage("当前已有目标，诊断建议不会覆盖现有数据。", true);
      return;
    }
    stageImport(raw, result);
  });

  $("import-dialog").addEventListener("close", () => {
    resetStagedImport();
    $("import-button").focus();
  });

  document.querySelectorAll(".step-tab").forEach((button) => {
    button.addEventListener("click", () => openWorkspace(button.dataset.workspace));
  });

  $("ledger-current-button").addEventListener("click", () => {
    ledgerScope = "current";
    renderLedger();
  });
  $("ledger-all-button").addEventListener("click", () => {
    ledgerScope = "all";
    renderLedger();
  });

  $("next-action-button").addEventListener("click", () => {
    moveTo($("next-action-button").dataset.target, $("next-action-button").dataset.focus);
  });

  $("clear-button").addEventListener("click", () => {
    if (recoveryRaw !== null) {
      showMessage("恢复数据只能通过恢复面板明确弃用；建议先下载原始数据。", true);
      moveTo("recovery-panel", "download-recovery-button");
      return;
    }
    if (!window.confirm("清空目标、合同版本和全部观察？此操作不可撤销。")) return;
    if (readStoredState() !== persistedSnapshot) {
      showMessage("另一标签页已经更新本地数据。请刷新本页后再清空。", true);
      return;
    }
    try {
      removeStoredState();
      persistedSnapshot = null;
      recoveryRaw = null;
      state = logic.clearState(state);
      revisionOpen = false;
      pendingImport = null;
      ledgerScope = "current";
      $("goal-form").reset();
      resetContractForm();
      $("observation-form").reset();
      render();
      showMessage("本地数据已清空。");
      moveTo("goal-section", "goal-title");
    } catch (error) {
      showMessage(error.message, true);
    }
  });
  $("data-menu").addEventListener("keydown", (event) => {
    if (event.key !== "Escape" || !$("data-menu").open) return;
    event.preventDefault();
    $("data-menu").open = false;
    $("data-menu-button").focus();
  });
  window.addEventListener("storage", (event) => {
    if (event.key === logic.STORAGE_KEY && event.newValue !== persistedSnapshot) {
      showMessage("另一标签页已经更新本地数据。本页在刷新前不会覆盖该变化。", true);
    }
  });

  initializeDecisionOptions();
  render();
}());
