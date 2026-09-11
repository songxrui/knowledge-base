(function attachRouterLogic(root, factory) {
  const api = factory();

  if (typeof module === "object" && module.exports) {
    module.exports = api;
  }

  if (root) {
    root.RouterLogic = api;
  }
})(typeof globalThis !== "undefined" ? globalThis : this, function createRouterLogic() {
  "use strict";

  const SCHEMA_VERSION = "1.0";
  const ALLOWED_ANSWERS = Object.freeze([
    "yes",
    "no",
    "unknown",
    "na",
    "prefer_not",
  ]);
  const SENSITIVE_ANSWER_IDS = Object.freeze(["U0", "S1", "S2", "S3"]);

  const CAUSE_META = Object.freeze({
    knowledge: {
      title: "真正缺知识",
      lane: "结构瓶颈",
    },
    action_definition: {
      title: "缺行动定义",
      lane: "结构瓶颈",
    },
    environment_permission: {
      title: "缺环境或权限",
      lane: "结构瓶颈",
    },
    feedback: {
      title: "缺反馈",
      lane: "结构瓶颈",
    },
    emotional_avoidance: {
      title: "情绪回避",
      lane: "候选摩擦",
    },
    perfectionism_concern: {
      title: "完美主义担忧",
      lane: "候选摩擦",
    },
    maintenance_overhead: {
      title: "系统维护成本过高",
      lane: "活动模式",
    },
    goal_not_important: {
      title: "目标本身不重要",
      lane: "目标价值",
    },
    professional_support_route: {
      title: "可能需要专业支持参与",
      lane: "支持路由",
    },
  });

  const CAUSE_ORDER = Object.freeze([
    "knowledge",
    "action_definition",
    "environment_permission",
    "feedback",
    "emotional_avoidance",
    "perfectionism_concern",
    "maintenance_overhead",
    "goal_not_important",
    "professional_support_route",
  ]);

  const QUESTION_SECTIONS = Object.freeze([
    {
      id: "safety",
      eyebrow: "先确认安全",
      title: "基本安全",
      description: "无法确认基本安全时，本工具不会继续给出行动建议。",
      questions: [
        {
          id: "U0",
          prompt: "你现在是否无法保证自己或他人的基本安全？",
          sensitive: true,
        },
      ],
    },
    {
      id: "goal",
      eyebrow: "第一道门",
      title: "目标价值",
      description: "先判断目标是否值得承担成本。退出一个不重要的目标不是失败。",
      questions: [
        { id: "G1", prompt: "没有观众、打卡或身份标签时，你仍愿意承担这个目标的成本？" },
        { id: "G2", prompt: "你能说出这个目标对自己的一项具体价值？" },
        { id: "G3", prompt: "不做它会损害你认可的重要后果或承诺？" },
        { id: "G4", prompt: "把它从清单删除时，你更接近只感到松一口气，而不是失去有价值的东西？" },
      ],
    },
    {
      id: "resources-risk",
      eyebrow: "第二、三道门",
      title: "环境、权限与风险",
      description: "资源缺口要协商或获取；高风险任务要改走监督、模拟或专家复核。",
      questions: [
        { id: "P1", prompt: "未来 7 天存在一次真实机会和可用时间窗？" },
        { id: "P2", prompt: "必需的资金、工具、场地和信息都可获得？" },
        { id: "P3", prompt: "你拥有必要的决策权、批准或信息路由？" },
        { id: "P4", prompt: "照护责任、工时或现实环境正在事实上阻断这一步？" },
        { id: "R1", prompt: "这一步的最大可逆损失是你可以接受的？" },
        { id: "R2", prompt: "这一步可能伤害第三方、违法或违反职业伦理？" },
        { id: "R3", prompt: "这一步需要资质、监督、专家审查或受保护环境？" },
      ],
    },
    {
      id: "knowledge",
      eyebrow: "第四道门",
      title: "知识与能力",
      description: "用任务特定表现判断准备度，不用“感觉懂了”判断。",
      questions: [
        { id: "K1", prompt: "不看资料时，你能说明关键步骤与主要风险？" },
        { id: "K2", prompt: "你已在代表性样例、迁移题或监督模拟中达到最低标准？" },
        { id: "K3", prompt: "目前缺少的具体知识会改变下一步做法或安全边界？" },
        { id: "K4", prompt: "若需要先学，你已经设置测试日期和退出条件？" },
      ],
    },
    {
      id: "action",
      eyebrow: "动作接口",
      title: "行动定义",
      description: "下一步需要同时具备触发情境、可观察动作和完成证据。",
      questions: [
        { id: "A1", prompt: "下一步有明确的触发情境或时间窗口？" },
        { id: "A2", prompt: "下一步是一个可观察的动作，而不是“继续研究”之类的方向？" },
        { id: "A3", prompt: "第三方也能根据证据判断这一步是否完成？" },
        { id: "A4", prompt: "开始前不需要再做一次选择或重写计划？" },
      ],
    },
    {
      id: "feedback",
      eyebrow: "第五道门",
      title: "反馈有效性",
      description: "反馈出现不等于反馈可信，反馈可信也不等于应该立刻改变。",
      questions: [
        { id: "F1", prompt: "这一步会在有用窗口内产生可观察结果？" },
        { id: "F2", prompt: "这个结果与当前要做的决定直接相关？" },
        { id: "F3", prompt: "测量足够有效、可归因，或能按预声明次数重复？" },
        { id: "F4", prompt: "你已经声明什么结果会让自己保持、修改或退出？" },
      ],
    },
    {
      id: "friction",
      eyebrow: "候选摩擦",
      title: "情绪与质量门槛",
      description: "只有结构条件足够时，这两类候选摩擦才会得到直接支持。",
      questions: [
        { id: "EA1", prompt: "想象确切测试动作时，不适明显高于继续准备？" },
        { id: "EA2", prompt: "你能指出这次测试会暴露的具体结果或否定？" },
        { id: "EA3", prompt: "改成私下、匿名、可逆或低赌注测试时，你会明显更愿意做？" },
        { id: "W1", prompt: "当前版本已经达到任务或外部要求的最低可接受标准？" },
        { id: "W2", prompt: "达标后，你仍因“还不够好”拒绝一次安全小测试？" },
        { id: "W3", prompt: "质量门槛曾在你接近后再次上移？" },
        { id: "W4", prompt: "即使是私下的 v0 测试，你仍只因自设质量门槛而拒绝？" },
      ],
    },
    {
      id: "maintenance",
      eyebrow: "活动模式",
      title: "系统维护",
      description: "改善测量的基础设施与挤掉真实机会的重构不是一回事。",
      questions: [
        { id: "M1", prompt: "工具、模板、标签或整理曾挤掉至少一次真实目标机会？" },
        { id: "M2", prompt: "维护前，你声明了它要改善的表现或测量，以及验证时间？" },
        { id: "M3", prompt: "已经观察到它降低摩擦或提高反馈质量？" },
      ],
    },
    {
      id: "support",
      eyebrow: "边界检查",
      title: "支持路由",
      description: "这组回答只决定是否建议把合适的支持加入计划，不推断任何疾病。",
      questions: [
        { id: "S1", prompt: "困难持续数周，并明显影响工作、学习、睡眠、进食或基本自理？", sensitive: true },
        { id: "S2", prompt: "你怀疑身体、药物、疼痛、睡眠、成瘾、心理或神经发育因素参与，或已有专业人士建议求助？", sensitive: true },
        { id: "S3", prompt: "即使任务很小、安全、明确且资源足够，仍跨多个生活领域反复无法启动或维持，并感到显著痛苦？", sensitive: true },
      ],
    },
  ]);

  const QUESTION_IDS = Object.freeze(
    QUESTION_SECTIONS.flatMap(function collectQuestionIds(section) {
      return section.questions.map(function getQuestionId(question) {
        return question.id;
      });
    }),
  );

  const ROUTE_COPY = Object.freeze({
    urgent_support: {
      title: "先确认基本安全",
      instruction: "停止使用本工具和任何行为实验。现在联系当地紧急服务、可信赖的人或你已有的专业支持。",
    },
    professional_support: {
      title: "把合适的支持加入路线",
      instruction: "自助工具可能不足。联系合适的专业人士、机构支持或可信赖的人，同时保留其他现实瓶颈。",
    },
    exploration: {
      title: "把这次活动保留为探索",
      instruction: "探索、审美与好奇有独立价值。不要在复盘时把它冒充为承诺目标的行为改变。",
    },
    exit_goal: {
      title: "允许修改或退出目标",
      instruction: "先删除、重写或重新协商这个目标。退出不重要的目标是一次有效决定，不是失败。",
    },
    stop_or_redesign: {
      title: "停止直接测试并重新设计",
      instruction: "当前损失或第三方风险不可接受。不要直接暴露，改用停止、专家复核或受保护方案。",
    },
    get_resources: {
      title: "先争取资源或权限",
      instruction: "用一次申请、协商、资源请求、集体行动或目标调整替代自我责备。",
    },
    supervised_or_expert: {
      title: "改走监督、模拟或专家复核",
      instruction: "在资质、风险或安全边界明确前，不创建直接现实暴露。",
    },
    bounded_learning: {
      title: "进入有界学习",
      instruction: "只补足会改变做法或安全边界的缺口，同时锁定测试日期与退出条件。",
    },
    improve_feedback: {
      title: "先改善反馈",
      instruction: "声明结果空间、有效测量与更新门槛。弱信号需要多次可逆探针，不能因一次结果改策略。",
    },
    define_action: {
      title: "先定义一个可观察动作",
      instruction: "写成：当 X 出现，我做 Y；看到 Z 算完成。不要再扩写整个计划。",
    },
    freeze_maintenance: {
      title: "冻结系统维护 48 小时",
      instruction: "把下一次真实机会还给目标活动。只有能改善表现或测量的维护才重新开放。",
    },
    constraint_test: {
      title: "可以设计一次小规模约束测试",
      instruction: "预先声明结果空间、风险上限和更新门槛，再让判断接受一次可读的现实约束。",
    },
    clarify_unknown: {
      title: "先核实一个不确定项",
      instruction: "不确定不等于没有问题。选择一个会改变路线的问题，用最小测试获得答案。",
    },
  });

  function sanitizeText(value, maxLength) {
    const limit = Number.isInteger(maxLength) && maxLength > 0 ? maxLength : 240;
    return String(value == null ? "" : value)
      .normalize("NFKC")
      .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, " ")
      .replace(/[<>]/g, "")
      .replace(/\s+/g, " ")
      .trim()
      .slice(0, limit);
  }

  function normalizeAnswer(value) {
    return ALLOWED_ANSWERS.includes(value) ? value : "unknown";
  }

  function normalizeAnswers(rawAnswers) {
    const source = rawAnswers && typeof rawAnswers === "object" ? rawAnswers : {};
    const normalized = Object.create(null);

    QUESTION_IDS.forEach(function normalizeKnownQuestion(id) {
      normalized[id] = normalizeAnswer(source[id]);
    });

    return normalized;
  }

  function isYes(answers, id) {
    return answers[id] === "yes";
  }

  function isNo(answers, id) {
    return answers[id] === "no";
  }

  function isUnclearValue(value) {
    return value === "unknown" || value === "na" || value === "prefer_not";
  }

  function allValues(answers, ids, expected) {
    return ids.every(function matches(id) {
      return answers[id] === expected;
    });
  }

  function anyValues(answers, ids, expected) {
    return ids.some(function matches(id) {
      return answers[id] === expected;
    });
  }

  function unclearIds(answers, ids) {
    return ids.filter(function isUnclear(id) {
      return isUnclearValue(answers[id]);
    });
  }

  function finding(cause, state, evidenceItemIds, rationale, nextMove, disconfirmingTest) {
    return {
      cause: cause,
      title: CAUSE_META[cause].title,
      lane: CAUSE_META[cause].lane,
      state: state,
      evidenceItemIds: Array.from(new Set(evidenceItemIds)),
      rationale: rationale,
      nextMove: nextMove,
      disconfirmingTest: disconfirmingTest,
    };
  }

  function stoppedFindings(isUrgent) {
    return CAUSE_ORDER.map(function createStoppedFinding(cause) {
      if (cause === "professional_support_route" && isUrgent) {
        return finding(
          cause,
          "safety_route",
          ["U0"],
          "基本安全优先于任何生产力解释。",
          "联系当地紧急服务、可信赖的人或已有专业支持。",
          "只有在基本安全得到确认后，才重新使用本工具。",
        );
      }
      return finding(
        cause,
        "not_supported",
        [],
        "安全确认前不评估这一项。",
        "先确认基本安全。",
        "完成安全确认后重新评估。",
      );
    });
  }

  function evaluateRisk(answers) {
    if (isYes(answers, "R2") || isNo(answers, "R1")) {
      const stopEvidence = [];
      if (isNo(answers, "R1")) {
        stopEvidence.push("R1");
      }
      if (isYes(answers, "R2")) {
        stopEvidence.push("R2");
      }
      return {
        state: "stop",
        evidenceItemIds: stopEvidence,
        message: "当前损失或第三方风险不可接受，停止直接测试并重新设计。",
      };
    }

    if (isYes(answers, "R3") || unclearIds(answers, ["R1", "R2", "R3"]).length > 0) {
      return {
        state: "supervised_only",
        evidenceItemIds: ["R3"].concat(unclearIds(answers, ["R1", "R2", "R3"])),
        message: "风险或资质边界尚未允许直接测试，只使用监督、模拟或专家复核。",
      };
    }

    return {
      state: "direct_ok",
      evidenceItemIds: ["R1", "R2", "R3"],
      message: "当前回答允许继续设计低风险测试；实际执行前仍需写明停止条件。",
    };
  }

  function evaluateGoal(answers) {
    const supported = isNo(answers, "G1") && isNo(answers, "G2") && isNo(answers, "G3") && isYes(answers, "G4");
    const recognizedValue = isYes(answers, "G3") || (isYes(answers, "G1") && isYes(answers, "G2"));

    if (supported) {
      return finding(
        "goal_not_important",
        "supported",
        ["G1", "G2", "G3", "G4"],
        "目标缺少本人认可的价值或承诺，删除时主要带来释放。",
        "删除、改写或重新协商目标；退出本身是合法路线。",
        "间隔 24 小时复问后，若出现本人认可的价值或重要承诺，就推翻这一结果。",
      );
    }

    if (recognizedValue) {
      return finding(
        "goal_not_important",
        "not_supported",
        ["G1", "G2", "G3"].filter(function isValueEvidence(id) {
          return isYes(answers, id);
        }),
        "当前回答显示目标具有本人认可的价值或重要承诺。",
        "继续检查资源、风险、能力和反馈。",
        "若没有观众时不再愿意承担成本，且目标不再承载认可的价值或承诺，应重新评估。",
      );
    }

    return finding(
      "goal_not_important",
      "test_needed",
      unclearIds(answers, ["G1", "G2", "G3", "G4"]).concat(
        ["G1", "G2"].filter(function isNegative(id) {
          return isNo(answers, id);
        }),
      ),
      "目标价值的证据混合或尚不清楚。",
      "隔 24 小时，在不看打卡和身份标签的情况下重新回答目标价值问题。",
      "若能稳定说出本人认可的价值或承诺，就不再支持目标不重要。",
    );
  }

  function evaluateKnowledge(answers) {
    if (isNo(answers, "K2") && isYes(answers, "K3")) {
      return finding(
        "knowledge",
        "supported",
        ["K2", "K3"],
        "任务特定测试未达到最低标准，且缺口会改变做法或安全边界。",
        "进行不超过 20 分钟的有界学习，并锁定下一次样例、迁移题或监督模拟。",
        "若代表性测试已达到最低标准，或新增信息不改变做法与安全边界，就推翻这一结果。",
      );
    }

    if (isYes(answers, "K2")) {
      return finding(
        "knowledge",
        "not_supported",
        ["K2"],
        "代表性表现已达到当前最低标准。",
        "停止追加泛化阅读，继续检查行动定义与反馈。",
        "若后续反馈暴露出新的任务特定能力缺口，应重新进入有界学习。",
      );
    }

    return finding(
      "knowledge",
      "test_needed",
      unclearIds(answers, ["K1", "K2", "K3"]).concat(isNo(answers, "K1") ? ["K1"] : []),
      "目前只有自我感觉或未完成任务特定测试，不能判断知识是否足够。",
      "做一次 15 分钟闭卷提取、代表性样例、迁移题或安全测验。",
      "测试达到最低标准时，不再支持真正缺知识。",
    );
  }

  function evaluateAction(answers) {
    const ids = ["A1", "A2", "A3", "A4"];
    const missing = ids.filter(function isMissing(id) {
      return isNo(answers, id);
    });

    if (missing.length > 0) {
      return finding(
        "action_definition",
        "supported",
        missing,
        "下一步缺少触发情境、可观察动作、完成证据或无须再选择的入口。",
        "写成：当 X 出现，我做 Y；看到 Z 算完成。",
        "两位独立观察者都能根据同一证据判断完成时，就推翻这一结果。",
      );
    }

    if (allValues(answers, ids, "yes")) {
      return finding(
        "action_definition",
        "not_supported",
        ids,
        "当前下一步具备触发情境、可观察动作和完成证据。",
        "继续检查现实机会、风险与反馈。",
        "若开始前仍需要重新选择或解释完成标准，应重新评估。",
      );
    }

    return finding(
      "action_definition",
      "test_needed",
      unclearIds(answers, ids),
      "行动接口仍有未确认部分。",
      "让另一人只看你的动作描述，并复述何时开始、做什么、什么算完成。",
      "若对方能无歧义复述，行动定义就不再是当前瓶颈。",
    );
  }

  function evaluateEnvironment(answers) {
    const blocking = ["P1", "P2", "P3"].filter(function lacksRequirement(id) {
      return isNo(answers, id);
    });
    if (isYes(answers, "P4")) {
      blocking.push("P4");
    }

    if (blocking.length > 0) {
      return finding(
        "environment_permission",
        "supported",
        blocking,
        "真实机会、资源、权限或现实负担正在阻断动作。",
        "发出一次具体的资源或权限请求，或协商、改目标、集体行动、退出。",
        "所需资源与权限实际到位，并出现一次真实机会时，就推翻这一结果。",
      );
    }

    if (allValues(answers, ["P1", "P2", "P3"], "yes") && isNo(answers, "P4")) {
      return finding(
        "environment_permission",
        "not_supported",
        ["P1", "P2", "P3", "P4"],
        "当前回答显示真实机会、资源和权限都存在。",
        "继续检查风险、能力、行动定义和反馈。",
        "若执行窗口到来时仍缺少关键资源、批准或可用时间，应重新评估。",
      );
    }

    return finding(
      "environment_permission",
      "test_needed",
      unclearIds(answers, ["P1", "P2", "P3", "P4"]),
      "现实机会或权限尚未确认，不能把它当成个人回避。",
      "在 20 分钟内确认一次时间窗、必要资源或批准路径。",
      "当机会、资源和权限都得到具体确认时，就不再支持这一结果。",
    );
  }

  function evaluateFeedback(answers) {
    const ids = ["F1", "F2", "F3", "F4"];
    const missing = ids.filter(function isMissing(id) {
      return isNo(answers, id);
    });

    if (missing.length > 0) {
      return finding(
        "feedback",
        "supported",
        missing,
        "当前动作缺少及时、决策相关、有效或预先声明更新规则的反馈接口。",
        "声明可能结果、有效测量、必要重复和每种结果对应的决定。",
        "当结果可读、有效、可归因并达到预设更新门槛时，就推翻这一结果。",
      );
    }

    if (allValues(answers, ids, "yes")) {
      return finding(
        "feedback",
        "not_supported",
        ids,
        "当前回答显示反馈接口与更新规则都存在。",
        "按预先声明的结果空间执行；不要在结果出现后移动门槛。",
        "若结果无法归因、与决定无关或需要更多重复，应重新评估。",
      );
    }

    return finding(
      "feedback",
      "test_needed",
      unclearIds(answers, ids),
      "反馈的可读性、有效性或更新门槛尚未确认。",
      "用一句话写出什么结果会改变哪个决定，并检查测量是否真的能回答它。",
      "若没有任何可用结果能改变决定，应确认缺反馈。",
    );
  }

  function evaluateMaintenance(answers) {
    if (isYes(answers, "M1") && isNo(answers, "M2") && isNo(answers, "M3")) {
      return finding(
        "maintenance_overhead",
        "supported",
        ["M1", "M2", "M3"],
        "系统维护挤掉了真实机会，且没有预声明或观察到测量与表现收益。",
        "冻结工具、模板和标签重构 48 小时，把下一次机会交还给目标活动。",
        "若受限维护能稳定降低摩擦或提高反馈质量，就应改归基础设施。",
      );
    }

    if (isNo(answers, "M1") || isYes(answers, "M3")) {
      return finding(
        "maintenance_overhead",
        "not_supported",
        ["M1", "M3"].filter(function isMaintenanceEvidence(id) {
          return isNo(answers, id) || isYes(answers, id);
        }),
        "维护没有挤掉真实机会，或已经观察到测量与表现收益。",
        "保留成本受限的基础设施，并继续观察滞后表现。",
        "若维护开始挤掉机会且收益消失，应重新评估。",
      );
    }

    return finding(
      "maintenance_overhead",
      "test_needed",
      unclearIds(answers, ["M1", "M2", "M3"]).concat(isYes(answers, "M1") ? ["M1"] : []),
      "维护是否产生真实收益仍不清楚。",
      "冻结维护 48 小时，比较下一次目标机会与测量质量。",
      "若维护未挤掉机会或可观察地改善表现与测量，就不再支持维护过高。",
    );
  }

  function evaluateSupport(answers) {
    const ids = ["S1", "S2", "S3"];
    const matched = ids.filter(function needsSupport(id) {
      return isYes(answers, id);
    });

    if (matched.length > 0) {
      return finding(
        "professional_support_route",
        "safety_route",
        matched,
        "回答提示仅靠自助工具可能不足，适合把合适的支持加入路线。",
        "联系合适的专业人士、机构支持或可信赖的人；不要依据本结果自行命名疾病或改变治疗。",
        "这一结果不是病因判断；由合适的专业评估与后续功能变化决定是否继续该路线。",
      );
    }

    if (allValues(answers, ids, "no")) {
      return finding(
        "professional_support_route",
        "not_supported",
        ids,
        "当前回答没有触发优先支持路由。",
        "继续处理当前目标的结构瓶颈；需要时仍可主动寻求支持。",
        "若困难持续、跨领域显著影响生活或已有专业建议，应重新评估。",
      );
    }

    return finding(
      "professional_support_route",
      "test_needed",
      unclearIds(answers, ids),
      "你选择保留或尚未确认部分支持边界，工具不会据此推断。",
      "若你担心自助不足，可以不填写细节，直接联系合适的支持。",
      "获得更合适的人工评估后，以人工判断替代本项。",
    );
  }

  function evaluateEmotionalAvoidance(answers, structuralAdequate) {
    const ids = ["EA1", "EA2", "EA3"];
    const pattern = allValues(answers, ids, "yes");

    if (pattern && structuralAdequate) {
      return finding(
        "emotional_avoidance",
        "supported",
        ids,
        "结构条件已足够，且降低暴露赌注会明显改变行动意愿。这里描述的是行为功能，不是临床标签。",
        "保留真实信息，但把测试缩成私下、匿名、可逆或低赌注版本。",
        "若降低暴露赌注不改变选择，或结构瓶颈更能解释行为，就推翻这一结果。",
      );
    }

    if (pattern) {
      return finding(
        "emotional_avoidance",
        "test_needed",
        ids,
        "情绪模式可能存在，但结构瓶颈尚未过关，不能把它当成当前直接原因。",
        "先处理目标价值、资源、风险、知识、行动定义或反馈，再做低赌注对照。",
        "结构瓶颈解决后，若降低赌注仍不改变意愿，就不再支持这一结果。",
      );
    }

    if (isNo(answers, "EA1") || isNo(answers, "EA3")) {
      return finding(
        "emotional_avoidance",
        "not_supported",
        ["EA1", "EA3"].filter(function isNegative(id) {
          return isNo(answers, id);
        }),
        "当前回答没有显示测试特有不适或低赌注条件下的意愿变化。",
        "优先检查结构瓶颈。",
        "若私下、匿名或可逆条件稳定提高行动意愿，应重新评估。",
      );
    }

    return finding(
      "emotional_avoidance",
      "test_needed",
      unclearIds(answers, ids),
      "候选情绪路径尚无足够行为证据。",
      "在结构条件足够后，比较同一任务的普通版本与低赌注版本。",
      "若两种条件下选择相同，就不再支持这一结果。",
    );
  }

  function evaluatePerfectionism(answers, structuralAdequate) {
    const concernIds = ["W2", "W3", "W4"];
    const concernPattern = isYes(answers, "W1") && anyValues(answers, concernIds, "yes");

    if (concernPattern && structuralAdequate) {
      return finding(
        "perfectionism_concern",
        "supported",
        ["W1"].concat(
          concernIds.filter(function isConcern(id) {
            return isYes(answers, id);
          }),
        ),
        "外部最低标准已达到，但自设门槛继续阻止安全小测试。这里不判断人格。",
        "锁定外部最低线，只向一个安全受众提交一次 v0 测试。",
        "若尚未达到外部质量或安全标准，或结构瓶颈更能解释延迟，就推翻这一结果。",
      );
    }

    if (concernPattern) {
      return finding(
        "perfectionism_concern",
        "test_needed",
        ["W1"].concat(
          concernIds.filter(function isConcern(id) {
            return isYes(answers, id);
          }),
        ),
        "质量门槛模式可能存在，但结构瓶颈尚未过关，不能升级为直接解释。",
        "先处理结构瓶颈，再用锁定最低线的 v0 测试核实。",
        "若满足结构条件后不再移动门槛，就不再支持这一结果。",
      );
    }

    if (isNo(answers, "W1") || allValues(answers, concernIds, "no")) {
      return finding(
        "perfectionism_concern",
        "not_supported",
        ["W1"].concat(concernIds).filter(function isQualityEvidence(id) {
          return isNo(answers, id);
        }),
        "当前版本尚未达到必要最低线，或没有出现达标后继续上移门槛的行为。",
        "未达最低线时回到有界学习或行动定义；已达标时继续检查其他瓶颈。",
        "若达到外部最低线后仍反复移动门槛，应重新评估。",
      );
    }

    return finding(
      "perfectionism_concern",
      "test_needed",
      unclearIds(answers, ["W1", "W2", "W3", "W4"]),
      "最低标准或门槛移动尚未确认。",
      "先写下外部最低标准，再观察达到后是否仍拒绝安全小测试。",
      "若达标后愿意按原标准测试，就不再支持这一结果。",
    );
  }

  function selectRoute(findings, risk) {
    const byCause = Object.create(null);
    findings.forEach(function indexFinding(item) {
      byCause[item.cause] = item;
    });

    if (byCause.professional_support_route.state === "safety_route") {
      return "professional_support";
    }
    if (byCause.goal_not_important.state === "supported") {
      return "exit_goal";
    }
    if (risk.state === "stop") {
      return "stop_or_redesign";
    }
    if (byCause.environment_permission.state === "supported") {
      return "get_resources";
    }
    if (risk.state === "supervised_only") {
      return "supervised_or_expert";
    }
    if (byCause.knowledge.state === "supported") {
      return "bounded_learning";
    }
    if (byCause.feedback.state === "supported") {
      return "improve_feedback";
    }
    if (byCause.action_definition.state === "supported") {
      return "define_action";
    }
    if (byCause.maintenance_overhead.state === "supported") {
      return "freeze_maintenance";
    }
    if (
      byCause.perfectionism_concern.state === "supported" ||
      byCause.emotional_avoidance.state === "supported"
    ) {
      return "constraint_test";
    }

    const unresolvedPriority = [
      "goal_not_important",
      "environment_permission",
      "knowledge",
      "feedback",
      "action_definition",
      "maintenance_overhead",
      "professional_support_route",
    ];
    if (
      unresolvedPriority.some(function needsTest(cause) {
        return byCause[cause].state === "test_needed";
      })
    ) {
      return "clarify_unknown";
    }

    return "constraint_test";
  }

  function evaluateAssessment(input) {
    const source = input && typeof input === "object" ? input : {};
    const answers = normalizeAnswers(source.answers);
    const goal = sanitizeText(source.goal, 160);
    const context = sanitizeText(source.context, 240);
    const purpose = source.purpose === "exploration" ? "exploration" : "committed_goal";
    const safetyAnswer = answers.U0;
    const safetyConfirmed = safetyAnswer === "no";

    if (!safetyConfirmed) {
      const urgentStop = safetyAnswer === "yes";
      const route = "urgent_support";
      return {
        schemaVersion: SCHEMA_VERSION,
        goal: goal,
        context: context,
        purpose: purpose,
        safety: {
          confirmed: false,
          urgentStop: urgentStop,
          sensitiveAnswersPersisted: false,
        },
        risk: {
          state: "stop",
          evidenceItemIds: ["U0"],
          message: urgentStop
            ? "基本安全优先于任何生产力解释。"
            : "基本安全尚未得到明确确认，本工具暂停继续。",
        },
        findings: stoppedFindings(urgentStop),
        currentRoute: route,
        routeCopy: ROUTE_COPY[route],
        canContinue: false,
      };
    }

    if (purpose === "exploration") {
      const route = "exploration";
      return {
        schemaVersion: SCHEMA_VERSION,
        goal: goal,
        context: context,
        purpose: purpose,
        safety: {
          confirmed: true,
          urgentStop: false,
          sensitiveAnswersPersisted: false,
        },
        risk: {
          state: "not_applicable",
          evidenceItemIds: [],
          message: "本次活动被声明为探索，不冒充承诺目标的行为改变。",
        },
        findings: CAUSE_ORDER.map(function createExplorationFinding(cause) {
          return finding(
            cause,
            "not_supported",
            [],
            "本次活动被声明为探索，未进入目标瓶颈判断。",
            "保留探索价值，并与承诺目标进展分开记录。",
            "若以后把它用于一个承诺目标，再以该目标重新评估。",
          );
        }),
        currentRoute: route,
        routeCopy: ROUTE_COPY[route],
        canContinue: true,
      };
    }

    const risk = evaluateRisk(answers);
    const goalFinding = evaluateGoal(answers);
    const knowledgeFinding = evaluateKnowledge(answers);
    const actionFinding = evaluateAction(answers);
    const environmentFinding = evaluateEnvironment(answers);
    const feedbackFinding = evaluateFeedback(answers);
    const maintenanceFinding = evaluateMaintenance(answers);
    const supportFinding = evaluateSupport(answers);

    const structuralAdequate =
      risk.state === "direct_ok" &&
      goalFinding.state === "not_supported" &&
      knowledgeFinding.state === "not_supported" &&
      actionFinding.state === "not_supported" &&
      environmentFinding.state === "not_supported" &&
      feedbackFinding.state === "not_supported" &&
      supportFinding.state !== "safety_route";

    const emotionalFinding = evaluateEmotionalAvoidance(answers, structuralAdequate);
    const perfectionismFinding = evaluatePerfectionism(answers, structuralAdequate);

    const findingByCause = {
      knowledge: knowledgeFinding,
      action_definition: actionFinding,
      environment_permission: environmentFinding,
      feedback: feedbackFinding,
      emotional_avoidance: emotionalFinding,
      perfectionism_concern: perfectionismFinding,
      maintenance_overhead: maintenanceFinding,
      goal_not_important: goalFinding,
      professional_support_route: supportFinding,
    };
    const findings = CAUSE_ORDER.map(function orderedFinding(cause) {
      return findingByCause[cause];
    });
    const currentRoute = selectRoute(findings, risk);

    return {
      schemaVersion: SCHEMA_VERSION,
      goal: goal,
      context: context,
      purpose: purpose,
      safety: {
        confirmed: true,
        urgentStop: false,
        sensitiveAnswersPersisted: false,
      },
      risk: risk,
      findings: findings,
      currentRoute: currentRoute,
      routeCopy: ROUTE_COPY[currentRoute],
      canContinue: risk.state === "direct_ok" && supportFinding.state !== "safety_route",
    };
  }

  function buildPersistableDraft(draft) {
    const source = draft && typeof draft === "object" ? draft : {};
    const rawAnswers = source.answers && typeof source.answers === "object" ? source.answers : {};
    const answers = Object.create(null);

    Object.keys(rawAnswers).forEach(function keepNonSensitiveAnswer(id) {
      if (!QUESTION_IDS.includes(id) || SENSITIVE_ANSWER_IDS.includes(id)) {
        return;
      }
      answers[id] = normalizeAnswer(rawAnswers[id]);
    });

    return {
      schemaVersion: SCHEMA_VERSION,
      goal: sanitizeText(source.goal, 160),
      context: sanitizeText(source.context, 240),
      purpose: source.purpose === "exploration" ? "exploration" : "committed_goal",
      answers: answers,
    };
  }

  return Object.freeze({
    SCHEMA_VERSION: SCHEMA_VERSION,
    ALLOWED_ANSWERS: ALLOWED_ANSWERS,
    SENSITIVE_ANSWER_IDS: SENSITIVE_ANSWER_IDS,
    CAUSE_META: CAUSE_META,
    CAUSE_ORDER: CAUSE_ORDER,
    QUESTION_SECTIONS: QUESTION_SECTIONS,
    QUESTION_IDS: QUESTION_IDS,
    ROUTE_COPY: ROUTE_COPY,
    sanitizeText: sanitizeText,
    normalizeAnswer: normalizeAnswer,
    normalizeAnswers: normalizeAnswers,
    evaluateAssessment: evaluateAssessment,
    buildPersistableDraft: buildPersistableDraft,
  });
});
