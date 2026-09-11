# 阅读伴侣 — Anthropic "Equipping Agents with Agent Skills"

> 产出方法: ljg-read (阅读陪伴Agent) × exa-search 原文抓取
> 原文: https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
> 发布日期: 2025-12-18 (Agent Skills开放标准)

---

## 陪你读: 这篇文章在说什么

**一句话**: Anthropic正式发布Agent Skills开放标准，定义了skill的文件结构(目录+SKILL.md+资源文件)和渐进式加载机制(metadata→body→references三层)，目标是让skill在Claude、Claude Code、Agent SDK和第三方平台之间互通。

**为什么重要**: 这是skill生态的"HTTP协议时刻"——就像HTTP让所有浏览器能访问所有网站，Agent Skills标准让一个skill能在不同AI平台上运行。

---

## 陪你拆: 5个关键洞察

### 1. Skill不是对话, 是文件系统

> "A skill is a directory containing a SKILL.md file"

Anthropic把skill定义为**文件系统实体**, 不是对话中的一段prompt。这意味着skill有持久性、可版本化、可共享。

→ **对你的启示**: 如果你把skill当prompt写，它会在对话结束后消失。把它当文件写，它可以跨会话复用。

### 2. "无限上下文"的秘诀

> "the amount of context that can be bundled into a skill is effectively unbounded"

因为Agent通过文件系统按需读取skill内容（像你翻书一样翻到需要的章节），而不是一次性全塞进上下文窗口。所以skill可以包含海量资料而不消耗token。

→ **对你的启示**: 别怕skill太大。怕的是没有按"需要时再加载"的结构组织。

### 3. 代码 > 文字说明

> "Code can serve as both executable tools and as documentation"

Anthropic鼓励把流程写成可执行脚本，而不是文字指令。因为脚本运行时只占输出token，不占上下文。

→ **对你的启示**: skill里能写脚本的地方绝不用文字说明。一条bash命令=一段文字说明的效率。

### 4. 让Agent自己写skill

> "Ask Claude to capture its successful approaches and common mistakes into reusable context and code within a skill"

这是自举(bootstrapping)方向——Agent在工作中发现自己做得好的模式，自动沉淀为skill。

→ **对你的启示**: 下次Agent帮你完成了一个复杂任务，直接说"把你刚才的做法写成一个skill"。

### 5. 从评估开始

> "Start with evaluation: Identify specific gaps in your agents' capabilities by running them on representative tasks"

先跑baseline，找出Agent的短板，再建skill针对性补强。

→ **对你的启示**: 不要凭感觉建skill。跑10个任务，看Agent哪里卡住了，再建skill解决那个具体问题。

---

## 陪你连: 连接你已经知道的东西

| Anthropic说的 | 你已经有的 | 连接 |
|-------------|----------|------|
| "Start with evaluation" | skill-review-master评测 | 先评测再升级是正确路径 |
| "Progressive disclosure" | dbs-orchestrator路由 | 编排层是progressive disclosure的应用 |
| "Code > instructions" | verify-delivery.ps1等脚本 | 你的GA级skill已经有脚本组件 |
| "Agent自建skill" | 还未实践 | 下一步方向 |
| "Open standard" | GitHub开源skill | 你的skill已经符合开放标准 |

---

## 陪你问: 3个读后问题

1. 如果你的147个skill全部按Anthropic标准重构，哪些应该保留？哪些应该删除？（OpenSkillEval数据: 选错skill < 不用skill）

2. "Agent自建skill"方向——你的dbs-content-system和khazix-writer已经在自动产出内容，是否可以让它们自动生成对应的skill？

3. Anthropic强调"code > instructions"，你的skill中有多少是纯文字指令可以改写为可执行脚本的？

---

> ljg-read方法: 不替你读，陪你读 → 拆关键洞察 → 连接已有知识 → 生成可讨论的问题
