(function startRouterApp() {
  "use strict";

  const logic = window.RouterLogic;
  if (!logic) {
    throw new Error("RouterLogic failed to load.");
  }

  const STORAGE_KEY = "next-step-router-draft-v1";
  const ANSWER_LABELS = Object.freeze({
    yes: "是",
    no: "否",
    unknown: "不确定",
    na: "不适用",
    prefer_not: "不愿回答",
  });
  const STATE_LABELS = Object.freeze({
    supported: "有直接证据",
    test_needed: "待小测试核实",
    not_supported: "当前证据不支持",
    safety_route: "优先支持路由",
  });

  const form = document.getElementById("router-form");
  const questionnaire = document.getElementById("questionnaire");
  const goalInput = document.getElementById("goal");
  const contextInput = document.getElementById("context");
  const purposeInput = document.getElementById("purpose");
  const goalCount = document.getElementById("goal-count");
  const contextCount = document.getElementById("context-count");
  const storageStatus = document.getElementById("storage-status");
  const results = document.getElementById("results");
  const routeResult = document.getElementById("route-result");
  const riskResult = document.getElementById("risk-result");
  const findingSummary = document.getElementById("finding-summary");
  const findingGrid = document.getElementById("finding-grid");
  const editAnswersButton = document.getElementById("edit-answers");
  const exportButton = document.getElementById("export-result");
  const clearDataButton = document.getElementById("clear-data");

  let latestAssessment = null;

  function element(tagName, className, textValue) {
    const node = document.createElement(tagName);
    if (className) {
      node.className = className;
    }
    if (typeof textValue === "string") {
      node.textContent = textValue;
    }
    return node;
  }

  function renderQuestionnaire() {
    const fragment = document.createDocumentFragment();

    logic.QUESTION_SECTIONS.forEach(function renderSection(section) {
      const sectionNode = element("section", "question-section");
      sectionNode.setAttribute("aria-labelledby", "section-" + section.id);
      const inner = element("div", "page-shell question-section__inner");
      const heading = element("div", "question-section__heading");
      heading.append(
        element("p", "eyebrow", section.eyebrow),
        element("h2", "", section.title),
        element("p", "question-section__description", section.description),
      );
      heading.querySelector("h2").id = "section-" + section.id;

      const list = element("div", "question-list");
      section.questions.forEach(function renderQuestion(question, questionIndex) {
        const fieldset = element("fieldset", "question");
        fieldset.dataset.questionId = question.id;
        const legend = document.createElement("legend");
        legend.append(element("span", "question__id", question.id), document.createTextNode(question.prompt));
        if (question.sensitive) {
          legend.append(element("span", "question__sensitive", "不自动保存"));
        }
        fieldset.append(legend);

        const choices = element("div", "choices");
        logic.ALLOWED_ANSWERS.forEach(function renderChoice(answerValue, answerIndex) {
          const choice = element("label", "choice");
          const input = document.createElement("input");
          input.type = "radio";
          input.name = "answer-" + question.id;
          input.value = answerValue;
          input.id = "answer-" + question.id + "-" + answerValue;
          if (question.id === "U0" && questionIndex === 0 && answerIndex === 0) {
            input.required = true;
          }
          choice.append(input, document.createTextNode(ANSWER_LABELS[answerValue]));
          choices.append(choice);
        });
        fieldset.append(choices);
        list.append(fieldset);
      });

      inner.append(heading, list);
      sectionNode.append(inner);
      fragment.append(sectionNode);
    });

    questionnaire.replaceChildren(fragment);
  }

  function collectDraft() {
    const formData = new FormData(form);
    const answers = Object.create(null);
    logic.QUESTION_IDS.forEach(function collectAnswer(id) {
      const value = formData.get("answer-" + id);
      if (typeof value === "string") {
        answers[id] = logic.normalizeAnswer(value);
      }
    });

    return {
      schemaVersion: logic.SCHEMA_VERSION,
      goal: logic.sanitizeText(goalInput.value, 160),
      context: logic.sanitizeText(contextInput.value, 240),
      purpose: purposeInput.value,
      answers: answers,
    };
  }

  function saveDraft() {
    const persistable = logic.buildPersistableDraft(collectDraft());
    try {
      window.localStorage.setItem(STORAGE_KEY, JSON.stringify(persistable));
      storageStatus.textContent = "普通回答已保存；基本安全和支持路由回答未写入本地草稿。";
    } catch (error) {
      storageStatus.textContent = "当前浏览器未开放本地存储；本次填写仍可使用和导出。";
    }
  }

  function restoreDraft() {
    let parsed;
    try {
      const raw = window.localStorage.getItem(STORAGE_KEY);
      parsed = raw ? JSON.parse(raw) : null;
    } catch (error) {
      parsed = null;
    }

    if (!parsed || parsed.schemaVersion !== logic.SCHEMA_VERSION) {
      return;
    }

    goalInput.value = logic.sanitizeText(parsed.goal, 160);
    contextInput.value = logic.sanitizeText(parsed.context, 240);
    purposeInput.value = parsed.purpose === "exploration" ? "exploration" : "committed_goal";

    const answers = parsed.answers && typeof parsed.answers === "object" ? parsed.answers : {};
    Object.keys(answers).forEach(function restoreAnswer(id) {
      if (logic.SENSITIVE_ANSWER_IDS.includes(id)) {
        return;
      }
      const selector = 'input[name="answer-' + id + '"][value="' + logic.normalizeAnswer(answers[id]) + '"]';
      const input = form.querySelector(selector);
      if (input) {
        input.checked = true;
      }
    });
    updateCounts();
  }

  function updateCounts() {
    goalCount.textContent = String(goalInput.value.length);
    contextCount.textContent = String(contextInput.value.length);
  }

  function renderRoute(assessment) {
    routeResult.replaceChildren();
    const danger = !assessment.safety.confirmed || assessment.currentRoute === "stop_or_redesign";
    const panel = element("article", "route-panel" + (danger ? " route-panel--danger" : ""));
    panel.append(
      element("p", "route-panel__label", assessment.safety.confirmed ? "建议起点" : "停止分支"),
      element("h3", "", assessment.routeCopy.title),
      element("p", "", assessment.routeCopy.instruction),
    );
    routeResult.append(panel);
  }

  function renderRisk(assessment) {
    riskResult.replaceChildren();
    if (assessment.risk.state === "direct_ok" || assessment.risk.state === "not_applicable") {
      return;
    }
    const panel = element("div", "risk-panel");
    panel.append(element("strong", "", "风险与资质边界："), document.createTextNode(assessment.risk.message));
    riskResult.append(panel);
  }

  function renderFindingCard(item) {
    const card = element("article", "finding-card");
    const top = element("div", "finding-card__top");
    const titleGroup = element("div", "");
    titleGroup.append(element("p", "finding-card__lane", item.lane), element("h3", "", item.title));
    top.append(titleGroup, element("span", "status status--" + item.state, STATE_LABELS[item.state]));

    const details = document.createElement("dl");
    const nextTitle = element("dt", "", "下一步");
    const nextValue = element("dd", "", item.nextMove);
    const disconfirmTitle = element("dt", "", "什么会推翻它");
    const disconfirmValue = element("dd", "", item.disconfirmingTest);
    details.append(nextTitle, nextValue, disconfirmTitle, disconfirmValue);

    card.append(top, element("p", "finding-card__rationale", item.rationale), details);
    return card;
  }

  function renderFindings(assessment) {
    findingSummary.replaceChildren();
    findingGrid.replaceChildren();

    if (!assessment.safety.confirmed) {
      return;
    }

    const summary = element("div", "summary-line");
    summary.append(
      element("strong", "", "九类分别判断，可同时出现。"),
      document.createTextNode("状态只决定下一条合法路线，不合成单一评价。"),
    );
    findingSummary.append(summary);

    assessment.findings.forEach(function appendFinding(item) {
      findingGrid.append(renderFindingCard(item));
    });
  }

  function renderAssessment(assessment) {
    latestAssessment = assessment;
    renderRoute(assessment);
    renderRisk(assessment);
    renderFindings(assessment);
    results.hidden = false;
    results.scrollIntoView({ behavior: "smooth", block: "start" });
  }

  function exportAssessment() {
    if (!latestAssessment) {
      return;
    }

    const record = {
      schemaVersion: logic.SCHEMA_VERSION,
      exportedAt: new Date().toISOString(),
      draft: logic.buildPersistableDraft(collectDraft()),
      assessment: latestAssessment,
      privacy: "基本安全和支持路由原始回答未写入默认草稿。此文件由用户主动导出。",
    };
    const blob = new Blob([JSON.stringify(record, null, 2)], { type: "application/json;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const anchor = document.createElement("a");
    anchor.href = url;
    anchor.download = "next-step-router-result.json";
    document.body.append(anchor);
    anchor.click();
    anchor.remove();
    URL.revokeObjectURL(url);
  }

  function clearLocalData() {
    const confirmed = window.confirm("清除本工具保存在当前浏览器中的普通回答？");
    if (!confirmed) {
      return;
    }
    try {
      window.localStorage.removeItem(STORAGE_KEY);
    } catch (error) {
      // The in-memory form can still be cleared when storage is unavailable.
    }
    form.reset();
    latestAssessment = null;
    results.hidden = true;
    routeResult.replaceChildren();
    riskResult.replaceChildren();
    findingSummary.replaceChildren();
    findingGrid.replaceChildren();
    updateCounts();
    storageStatus.textContent = "本地草稿已清除。";
    goalInput.focus();
  }

  renderQuestionnaire();
  restoreDraft();
  updateCounts();

  form.addEventListener("input", function handleInput() {
    goalInput.setCustomValidity("");
    updateCounts();
    saveDraft();
  });

  form.addEventListener("submit", function handleSubmit(event) {
    event.preventDefault();
    if (!form.reportValidity()) {
      return;
    }
    const draft = collectDraft();
    if (!draft.goal) {
      goalInput.setCustomValidity("请输入一个纯文本目标。");
      goalInput.reportValidity();
      return;
    }
    goalInput.value = draft.goal;
    contextInput.value = draft.context;
    updateCounts();
    renderAssessment(logic.evaluateAssessment(draft));
  });

  editAnswersButton.addEventListener("click", function editAnswers() {
    form.scrollIntoView({ behavior: "smooth", block: "start" });
    goalInput.focus();
  });
  exportButton.addEventListener("click", exportAssessment);
  clearDataButton.addEventListener("click", clearLocalData);
})();
