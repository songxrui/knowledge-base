# 深钻一个词 — "Progressive Disclosure" (渐进式披露)

> 产出方法: ljg-word (英语单词深度掌握)  
> 对象: Progressive Disclosure — Agent Skill的核心设计原则

---

## 词源拆解

**Progressive**: 来自 progress (前进) — 暗示"逐步的、累积的"，不是"一次性的"
**Disclosure**: 来自 disclose (披露/揭露) — 暗示"原本隐藏的信息被主动呈现"

**组合含义**: 不是"一次性全部暴露"，而是"按需逐步展示"。像一个好的导游，不会在门口就把整个博物馆的展品全讲一遍——他会在每件展品前讲你需要知道的。

---

## 技术语境中的精确含义

Anthropic定义: "Progressive disclosure is the core design principle that makes Agent Skills flexible and scalable."

**三层**:
1. **Metadata** (~50 tokens): 启动时加载，告诉Agent"有哪些skill可用"。像目录。
2. **SKILL.md** (~500 tokens): 触发时加载，告诉Agent"这个skill怎么用"。像章节正文。
3. **References** (按需): 需要时加载，提供"更深层的细节"。像附录。

**关键**: 前两层加起来才~550 tokens。一个装了100个skill的Agent，启动时只消耗100×50=5000 tokens的metadata——相当于一篇短文。但可用能力覆盖100个专业领域。

---

## 为什么这个词精确 (而不是"懒加载")

**Lazy loading** (懒加载): 暗示"偷懒、推迟"，是被动的
**Progressive disclosure** (渐进式披露): 暗示"有策略地展示、主动设计"，是主动的

Anthropic选这个词不是偶然的:
- "Progressive" 有"前进、进步"的含义 → 暗示这是架构的进化
- "Disclosure" 有"揭秘"的含义 → 暗示Agent在"发现"知识，不是被动接收

---

## 反例: 当"Progressive Disclosure"被误解时

**常见误解**: "Progressive disclosure = 把内容拆成更小的文件"
**实际含义**: Progressive disclosure ≠ 文件拆分。它是一个**加载策略**，核心是"什么信息在什么时候呈现给Agent"。拆文件只是实现手段。

**另一个误解**: "Progressive disclosure = 减少token消耗"
**实际含义**: 减少token是**效果**，不是**目的**。目的是让Agent在"需要时"才有"正确的信息"。就像你不会在上厕所时读烹饪书——不是烹饪书太长，是时机不对。

---

## 这个词对Skill设计的启示

1. **Metadata是"第一印象"**: Agent只通过50 tokens的description决定是否调用你。这50个词是你唯一的路由信号。
2. **SKILL.md是"使用手册"**: 别写"关于X的一切"，写"当你需要X时，这样做"。Focused > Comprehensive。
3. **References是"按需深挖"**: 放那些80%情况下不需要、但20%情况下救命的信息。不放进SKILL.md拖慢常规调用。

---

## 一个可记住的定义

> "Progressive disclosure不是让你少写点，是让Agent只读它需要的。你写10万字没问题——只要Agent每次只读500字。"

---

> ljg-word方法: 词源→技术语境→精确含义→反例(常见误解)→设计启示→可记住的定义
