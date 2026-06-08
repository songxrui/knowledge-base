# ljg-paper 论文解读 | SkillRouter + SoK 两篇核心论文

> 使用skill: ljg-paper (非学术人群的论文阅读器)
> 论文1: SkillRouter (arXiv 2603.22455v4)
> 论文2: SoK: Agentic Skills (arXiv 2602.20867v1)
> 时间: 2026-06-08

---

## 论文1: SkillRouter

### 一句话
如果只给Agent看skill名字和描述、不给看完整指令，Agent正确匹配skill的能力暴跌31-44个百分点。

### 为什么重要
这就是"74%隐身"问题的学术证据。不是我们猜的——是实验测出来的。

### 方法论(简化)
把skill的body隐藏 → 只暴露name+description → 测量Agent的路由精度 → 对比完整暴露的精度 → 差距31-44pp

### 边界
- 实验用的是特定模型(需查论文确认), 不同模型的路由能力不同
- "31-44pp"是范围, 取决于skill的复杂度和语义重叠程度
- 论文是2026年3月的, 模型在之后可能有改进

### 对实践的启示
如果你的skill description写不好, Agent匹配它的概率不到60%。这就是为什么"补触发词"是第一优先级的操作。

---

## 论文2: SoK: Agentic Skills

### 一句话
"A skill carries its own applicability conditions, termination criteria, and callable interface" — skill自带路由信号、终止条件、可调用接口。

### 为什么重要
这个定义给了我们skill设计的三个标准:
1. **适用条件**: 什么情况下该用这个skill (→ description)
2. **终止条件**: 什么情况下这个skill算完成了 (→ DoD)
3. **可调用接口**: 怎么触发这个skill (→ 触发词)

### 对实践的启示
好的skill不只告诉Agent"怎么做"，还告诉Agent"什么时候做""什么时候算做完""怎么触发我"。

当前大多数skill只做了"怎么做"(body)，缺了"什么时候做"(description/适用条件)和"什么时候算做完"(DoD)。

---

## 两篇论文的交叉连接

**SkillRouter说**: description不好 → Agent匹配率暴跌31-44pp
**SoK说**: skill应该自带适用条件/终止条件/可调用接口

**所以**: description = skill的"适用条件" + "可调用接口"的声明。写好description不是"优化"，是skill设计的**基本要求**。没有适用条件的skill，Agent无法正确调用——SkillRouter论文用实验数据证明了这一点。

---

## 需要独立核实的声明

- SkillRouter的31-44pp具体实验条件和模型版本 → 标注"以原论文为准"
- SoK的3个条件(definitions)是否在论文中明确提出 → 标注"以原论文为准"
