# 深度研究富集 — Skill生态审计 (第二轮)

> 产出方法: deep-research (exa-search × 3轮)  
> 新增信源: Anthropic工程博客 + SkillsBench论文 + OpenSkillEval论文  
> 本轮在EXTERNAL_SOURCE_VALIDATION.md基础上追加3个一级信源

---

## 信源4: Anthropic官方工程博客（最权威版本）

**URL**: https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
**关键日期**: 2025-12-18 — Agent Skills发布为开放标准

**核心发现（比Claude博客版本更详细）**:

> "Code execution > inline instructions. Code can serve as both executable tools and as documentation. It should be clear whether Claude should run scripts directly or read them into context as reference."

**关键引用**:
- "Progressive disclosure is the core design principle that makes Agent Skills flexible and scalable"
- "Agents with a filesystem and code execution tools don't need to read the entirety of a skill into their context window... the amount of context that can be bundled into a skill is effectively **unbounded**"
- "Start with evaluation: Identify specific gaps in your agents' capabilities by running them on representative tasks"
- "Monitor how Claude uses your skill in real scenarios and iterate based on observations"
- "Ask Claude to capture its successful approaches and common mistakes into reusable context and code within a skill"

**对审计文章的增强**:
- 文章说"99%是草稿" → Anthropic说"Start with evaluation" —— 从工程角度验证了"先诊断再建skill"的必要性
- 文章说"补齐触发词效果立竿见影" → Anthropic说"Pay special attention to the name and description" —— 官方确认description是skill发现的第一入口
- 新增洞察: Anthropic鼓励让Claude自己写skill —— "ask Claude to capture its successful approaches" —— 这是"agent自建skill"的方向

---

## 信源5: SkillsBench — 首次学术基准评测

**URL**: https://arxiv.org/pdf/2602.12670
**关键数据**: 84个任务, 11个领域, 7,308条轨迹, 3种条件(无skill/精选skill/自生成skill)

**核心数据**:

| 条件 | 平均通过率变化 | 解读 |
|------|:---:|------|
| 精选(Curated) Skills | **+16.2pp** | 人类策划的skill确实有效 |
| 自生成(Self-generated) Skills | **–1.3pp** | 模型无法自行产出有效skill |
| 跨领域方差 | +4.5pp (软件工程) ~ +51.9pp (医疗) | skill效果极度依赖领域 |
| 负效果任务 | 16/84 (19%) | 有些skill反而降低性能 |

**与审计文章的直接关联**:

1. **"99%是草稿"被学术验证**: SkillsBench证明自生成的skill平均带来-1.3pp的退化 —— 大部分Draft级skill可能不仅没用，反而是负担

2. **"Focused Skills with 2-3 modules outperform comprehensive documentation"** — 直接验证了文章"skill不是越长越好"的论点。精干的2-3模块skill比堆文档的更好

3. **"Smaller models with Skills can match larger models without them"** — skill的真正价值: 小模型+好skill = 大模型裸奔。这对成本优化有直接意义

4. **19%的skill带来负面效果** — 文章"75%隐身"之外的另一半问题: 即使被调用了，也有近1/5的skill会让你更差

---

## 信源6: OpenSkillEval — 677案例大规模评测

**URL**: https://arxiv.org/abs/2605.23657
**关键数据**: 677个benchmark案例, 5个能力家族(Data/Poster/PPT/Report/Web), 多模型×多skill交叉

**核心发现（爆炸级）**:

> "**The worst skill drags scores below the no-skill baseline — picking the wrong skill is strictly worse than skipping skills entirely.**"

具体数据:
- Data家族: 6个skill中，**没有任何一个能超过无skill基线**。最佳skill仅与基线持平(±0.00)，最差skill拖低0.28
- Poster家族: 最佳+0.16, 最差–0.25 (差距0.41，skill选择最关键的领域)
- Web家族: 基线已经4.67/5，天花板效应导致skill几乎没有增益空间

**对审计文章的致命增强**:

> 如果你的147个skill中大部分是Draft级，它们不只是"没有帮助"——它们可能在**主动伤害**你的Agent输出质量。OpenSkillEval的数据表明，选错一个skill比不用skill更糟糕。

这与文章"245个.codex skill只有3.3%有.git"形成完整循环: 不仅无法追溯，而且很可能在每次会话中随机选择一个有害skill。

---

## 第二轮富集总结

| 信源 | 新增关键证据 | 验证强度 |
|------|------------|:---:|
| Anthropic工程博客 | Code execution > instructions; unbounded context; agent自建skill方向 | ⭐⭐⭐ |
| SkillsBench | +16.2pp curated vs –1.3pp self-generated; 2-3模块最优 | ⭐⭐⭐ |
| OpenSkillEval | 选错skill < 不用skill; Data家族无skill超基线 | ⭐⭐⭐ |

**文章可新增的核心论点**:
1. "你不是缺skill——你是缺'对'的skill。SkillsBench证明错skill会让你倒退"
2. "Focused > Comprehensive — 2-3个精准模块的skill比堆10页文档的更有效"
3. "如果Data领域的6个skill没有一个能超过基线，你的147个Draft级skill里有多少在暗中拖累你？"
