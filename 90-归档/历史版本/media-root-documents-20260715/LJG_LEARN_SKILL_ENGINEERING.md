# 学习序列 — Agent Skill工程: 从入门到GA级

> 产出方法: ljg-learn (交互式学习系统)  
> 目标: 连续3篇文章, 按难度递进  
> 来源: 全量21篇内容产出

---

## Lesson 1: 什么是Agent Skill (入门)

**核心问题**: Skill和Prompt到底有什么区别？

**关键概念**:
- Prompt = 一次性的对话指令
- Skill = 持久化的文件系统能力模块
- 渐进式加载: metadata(~50t) → 正文(~500t) → 参考资料(按需)

**你必须记住的数字**:
- 精选skill平均提升 +16.2pp 通过率 (SkillsBench)
- 自生成skill平均退化 –1.3pp (SkillsBench)
- 选错skill < 不用skill (OpenSkillEval)

**练习**: 打开你的skills目录，数一下有多少个。然后检查：有几个有.git？有几个有CHANGELOG？

---

## Lesson 2: 如何判断一个Skill好不好 (进阶)

**核心问题**: 我有50个skill，哪些该留哪些该删？

**判断标准 (GA级门禁)**:
1. 可发现性: description有≥4个触发词+正反例
2. 可追溯性: 有.git+CHANGELOG
3. 可验证性: 有tests/目录
4. 可执行性: ≤2000字, 有可执行脚本

**你必须做的**:
- 给你的核心skill打分(每项pass/fail)
- 先删有害skill (OpenSkillEval: 最差-0.28)
- 给保留的skill补触发词 (5min一个)

**练习**: 选3个你最常用的skill，用GA门禁打分。任何一项不通过→修复。

---

## Lesson 3: 如何建一个GA级Skill (高级)

**核心问题**: 怎么从0建一个能通过GA门禁的skill？

**5步30分钟流程**:
1. SKILL.md: 核心流程(≤2000字) + 失败模式
2. description: 4-8触发词 + 不适用场景 + 正反例×2
3. git init + 初始commit
4. tests/: ≥2测试用例(1正向+1边界)
5. CHANGELOG + EVIDENCE

**高阶技巧**:
- Code > Instructions: 把流程写成可执行脚本，不消耗上下文
- 让Agent帮你写skill: "把你刚才的做法沉淀为skill"
- Focused > Comprehensive: 2-3核心模块优于10页文档

**练习**: 从0建一个skill(任意主题)，走完5步，用skill-overseer验证。

---

> ljg-learn方法: 3课递进, 每课=核心问题+关键概念+必须记住的数字+练习, 入门→进阶→高级
