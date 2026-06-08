# 好问题生成器 — 从Skill生态审计内容提炼

> 产出方法: dbs-good-question (把模糊现象改写成Agent可推理、批评、验证的问题)  
> 来源: 全量17篇内容产出

---

## 5个好问题

### Q1: "如果OpenSkillEval证明选错skill比不用skill更差，你的147个skill中有多少是'选错'的？如何在不删除的情况下避免Agent选到它们？"

**可验证性**: 跑10个任务×2轮(随机skill选择 vs 仅GA级skill)，对比通过率。如果仅GA级的通过率更高 → 删除非GA skill。

**为什么这是好问题**: 从"skill数量多=好"的假设，转向可量化验证的"skill质量>数量"。

---

### Q2: "SkillsBench证明自生成skill平均退化-1.3pp。但你的dbs-content-system已经在自动生成内容单元——如果让它自动生成skill，退化风险如何控制？"

**可验证性**: 用dbs-content-system生成的5个内容单元打包为skill，跑SkillsBench同类验证(对比人工写的skill vs 系统生成的skill)。

**为什么这是好问题**: 直面"Agent自建skill"方向的工程风险和验证需求。

---

### Q3: "Anthropic说code>instructions。你的GA级skill中有多少是纯文字指令？改成可执行脚本后，token消耗能降多少？"

**可验证性**: 选3个GA级skill，统计纯文字指令行数 vs 可脚本化行数。改写后对比单次调用的token消耗。

**为什么这是好问题**: 从定性原则到定量验证——不是"应该这样做"，是"做了后能省X tokens"。

---

### Q4: "如果24.1%的skill可以有负面效果(OpenSkillEval最差-0.28)，你的Draft级skill中哪些最可能是'有害'的？优先级：先杀坏的 > 先建好的？"

**可验证性**: 对Draft级skill逐个跑baseline对比(有skill vs 无skill)，标记出Δ<0的skill，优先删除/隔离。

**为什么这是好问题**: 反转常规思维——大多数人只想着"加更多skill"，但证据表明"删坏的skill"ROI更高。

---

### Q5: "Focused > Comprehensive (SkillsBench): 你的平均SKILL.md长度是多少？如果砍到2-3个核心模块(≤2000字)，质量是升还是降？"

**可验证性**: 选10个超过2000字的SKILL.md，砍到≤2000字(仅保留2-3核心模块)。跑A/B测试(完整版 vs 精简版)对比效果。

**为什么这是好问题**: 用SkillsBench的实证发现挑战"skill越详细越好"的默认假设。

---

> 好问题标准: 有可验证的量化方法 × 有反直觉的方向 × 答案能直接指导行动
