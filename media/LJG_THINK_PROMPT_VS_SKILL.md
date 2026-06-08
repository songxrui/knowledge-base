# 追本之箭 — "Skill为什么不是更好的Prompt"

> 产出方法: ljg-think (纵向深钻)  
> 钻探对象: "Skill = 更好的Prompt" 这个常见误解  
> 钻探深度: 5层

---

## 第1层: 表面区别

**常见说法**: "Skill就是加了tools且有摘要的prompt"
**事实**: 表层确实如此——skill包含指令文本+工具声明+元数据描述

**但这就够了?** 如果skill只是"更好的prompt"，为什么Anthropic要专门建一个开放标准？为什么SkillsBench要单独做一个评测框架？

---

## 第2层: 加载机制不同

**Prompt**: 一次性全量注入上下文窗口。1000字的prompt = 1000 token消耗。
**Skill**: 渐进式三层加载。metadata(~50t) → SKILL.md(~500t) → references(按需)。一个skill可以包含10万字资料，但实际消耗可能只有500 token。

**这意味着**: skill解决的是"上下文经济学"问题。Prompt越详细越贵，skill越详细不一定越贵。

Anthropic原文: "the amount of context that can be bundled into a skill is effectively unbounded"

---

## 第3层: 持久性不同

**Prompt**: 对话级。对话结束，prompt消失。每次新对话都要重新写。
**Skill**: 文件系统级。文件持久存在，跨对话复用，可通过git版本化。

**这意味着**: skill有"记忆"。Prompt只有"指令"。3个月前的prompt你早忘了，但3个月前的skill可以追溯每一次修改。

---

## 第4层: 可组合性不同

**Prompt**: 单体。两个prompt之间没有调用关系。
**Skill**: 可组合。dbs-orchestrator→dbs-content→khazix-writer 可以形成链。

**这意味着**: skill的终极价值不在单个skill的质量，而在skill生态的网络效应——每个新skill可以调用已有skill，形成指数级组合。

SkillsBench证明: "smaller models with Skills can match larger models without them" —— 这是组合效应的量化证明。

---

## 第5层: 进化潜力不同

**Prompt**: 固定。写完就不能改了(除非你重新写)。
**Skill**: 可进化。Anthropic说"ask Claude to capture its successful approaches into a skill" —— Agent可以观察自己的工作，自动沉淀新skill。

**这意味着**: skill不只是"更好的prompt"，它是Agent的"学习机制"。Prompt让Agent做事，Skill让Agent学会如何更好地做事。

这一层是Prompt永远无法达到的——因为Prompt无法自我改进，但Skill可以(通过Agent的自我观察+人类审核)。

---

## 钻探结论

"Skill = 更好的Prompt"这个说法**对在表层，错在深层**。

| 维度 | Prompt | Skill |
|------|--------|-------|
| 加载 | 全量注入 | 渐进式三层 |
| 持久性 | 对话级 | 文件系统级 |
| 组合性 | 单体 | 可链式调用 |
| 进化性 | 固定 | Agent可自改进 |
| Token经济 | 越详细越贵 | 详细不一定贵 |

**一句话**: Prompt是给Agent的"口头交代"，Skill是给Agent的"操作手册+工具箱+升级系统"。它们解决的不是同一个层级的问题。

---

> ljg-think方法: 5层纵向深钻, 每层问"这意味着什么", 不满足于表面区别
