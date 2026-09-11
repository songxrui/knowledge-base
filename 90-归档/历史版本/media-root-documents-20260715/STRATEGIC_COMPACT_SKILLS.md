# 上下文管理指南 — Skill生态的token预算优化

> 产出方法: strategic-compact (上下文管理策略)  
> 适用场景: 当你装了100+个skill时, 如何防止上下文被污染

---

## 问题: Skill越多, Agent越慢

**根本原因**: 每个skill的metadata(~50 tokens)在启动时全部注入系统提示词。

**量化**: 100个skill × 50 tokens = 5,000 tokens 在每次对话开始时就被占用。这还不算被触发的skill加载的正文(500-2000 tokens)。

**Anthropic的解决方案**: Progressive disclosure — metadata只占50 tokens，正文只在匹配时加载。但这不能解决"metadata太多"的问题。

---

## 策略1: 分批激活 (推荐)

不要把全部skill同时激活。按任务类型分组:
- **内容创作模式**: 只激活 dbs-content-system + khazix-writer + brand-voice + humanizer-zh + crosspost
- **代码开发模式**: 只激活 tdd-workflow + security-review + coding-standards + verification-loop
- **深度研究模式**: 只激活 deep-research + exa-search + weread-skills

**效果**: 从100个skill(5000 tokens) → 5-8个skill(250-400 tokens)。节省4600+ tokens。

---

## 策略2: 编排层聚合

用dbs-orchestrator代替直接暴露15个dbs skill:
- 原始: 15个skill × 50 tokens = 750 tokens metadata
- 编排后: 1个orchestrator(50 tokens) + 按需加载(500 tokens/次)

**效果**: 在不需要dbs skill的对话中节省700 tokens。在需要时，只加载被调用的1-2个skill的正文。

---

## 策略3: 删除有害/无用skill

OpenSkillEval数据: 最差skill拖累0.28分。你的Draft级skill不只是浪费metadata token——它在主动伤害输出质量。

**操作**:
1. 列出30天未触发的skill → 候选删除
2. 对候选跑A/B测试(有vs无) → 标记Δ<0的
3. 删除Δ<0的 + 30天未触发的

**效果**: 从147个 → 约30-50个核心skill。节省~5000 tokens metadata。

---

## 策略4: 用git管理skill版本, 不用时归档

不是删除——是归档。保留.git历史，移动到.archived/目录。

**操作**: `git mv skill-name .archived/skill-name && git commit`

**效果**: skill还在版本历史中，但不再占用启动token。需要时随时恢复。

---

## Token预算计算器

| 场景 | 激活skill数 | metadata token | 预计每次对话加载 | 
|------|:---:|:---:|------|
| 全量加载 | 147 | 7,350 | ~10,000-20,000 |
| 分批模式 | 5-8 | 250-400 | ~1,500-3,000 |
| 编排层 | 1+按需 | 50+按需 | ~800-2,000 |
| 优化后(删+归+排) | 30-50 | 1,500-2,500 | ~3,000-5,000 |

**建议目标**: metadata < 2,000 tokens (40个skill以内)。

---

> 方法论: strategic-compact (上下文管理); 数据: 本地审计+Anthropic progressive disclosure架构
