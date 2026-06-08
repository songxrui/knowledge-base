# ljg-qa 信息提问机 | Skill生态审计

> 使用skill: ljg-qa (把核心观点抽成可独立回答的问题)
> 源: 本轮全部产出
> 时间: 2026-06-08

---

## 主张类 (4题)

**Q1: 为什么说"选错skill比不用更差"？**
A: OpenSkillEval实验发现，某些领域的6个skill中没有一个能超越不用skill的基线。选错skill会产生-0.28的净拖累。也就是说，你花了token加载一个skill，结果它帮你把事情做坏了。→ 见 OpenSkillEval论文

**Q2: "74%的skill在Agent面前是隐身的"这个数字怎么来的？**
A: 147个活跃skill中，只有25.9%(38个)的description包含明确的触发词。其余74%靠Agent的语义猜测来匹配——猜对就用，猜错就跳过。→ 见 content-truth-lock验证

**Q3: "产品"的定义到底是什么？**
A: ljg-think深钻后的修正定义: "能独立完成一项可验证的工作"需要3步核心(被发现→被正确使用→被验证有效)，而非7种文件。7种文件解决的是信任问题，不是功能问题。→ 见 ljg-think + dbs-deconstruct

**Q4: 为什么.agents目录127个skill全部有git，而.codex只有3.3%？**
A: .agents的创建流程强制了"git init + 初始commit"——一条5秒的规则。这说明规范靠流程保证，不靠自律保证。→ 见 原文 + 本地复现

---

## 方法类 (3题)

**Q5: 怎么写一个好的skill description？**
A: 三要素: 4-8个触发词(从用户语言出发) + 明确的不适用场景 + 2条正例2条反例。关键不是在description里写"这个skill做什么"，而是写"用户在什么情况下会需要这个skill"。→ 见 dbs-learning 第2课

**Q6: SkillOpt方法论的核心循环是什么？**
A: Rollout(跑10个任务记录失败) → Reflection(分析失败模式) → Edit(每轮≤4条改动) → Validation(留出任务验证,没涨就回滚) → Rejected Buffer(记被否改动) → Slow Update(每几轮纵向回顾)。→ 见 dbs-learning 第3课

**Q7: 快方法和慢方法怎么选？**
A: 快方法(0初始投入,高维护成本) vs 慢方法(3h初始投入,每月省8h)。关键决策: 这个skill会持续用超过3个月吗？会 → 慢方法。不会 → 快方法。→ 见 dbs-slowisfast

---

## 实用类 (2题)

**Q8: 我今天可以做的第一件事是什么？**
A: 打开你最常用的3个skill → 看description → 如果5秒内说不清它是干什么的，花5分钟补4-8个触发词 + 不适用场景 + 正反例。投入: 15分钟。回报: 这3个skill的Agent匹配率大幅提升。

**Q9: 我的内容管线应该怎么搭建？**
A: 5步: weread拉信源 → dbs-content-system结构化 → khazix-writer创作 → humanizer-zh去AI味 → content-auditor终审。首次搭建30min, 之后每篇10min。→ 见 knowledge-forge + content-alchemist

---

## 前瞻类 (1题)

**Q10: Skill生态的下一个阶段是什么？**
A: 从"中央计划"(作者手动选核心skill)走向"自发秩序"(调用数据驱动优胜劣汰)。但前提是消灭"隐身税"——先确保所有skill有公平的被发现机会。→ 见 dbs-chatroom-austrian
