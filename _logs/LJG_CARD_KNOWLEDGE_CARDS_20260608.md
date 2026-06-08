# ljg-card 知识卡片集 | AI Skill 生态审计

> 使用skill: ljg-card (Content Caster, v2.3.0)
> 卡型: -l (长阅读卡, 1080xauto)
> 源材料: crosspost-wechat.md + skill-ecosystem-audit-article.md
> 时间: 2026-06-08

---

## 卡片1: 核心观点卡

**标题**: 审计了846个AI Skill后，99%都不配叫"产品"

**正文**:
我扫了本地四个skill目录，846个实例。去重后358个唯一名称。147个活跃skill中，只有7个达到了GA级产品标准。

74%的skill在Agent面前是隐身的——不是因为质量差，是Agent根本不知道它们存在。

3.3%的skill有版本控制。没有git，你无法追溯任何一个改动。

**金句**: "这不是优化问题，是信任问题。"

**数据条**:
- 846个实例 → 358个唯一 → 147个活跃 → 7个GA级
- 74%隐身率
- 3.3%版本控制覆盖率

---

## 卡片2: 行动指南卡

**标题**: 三件事，让你的Skill不隐身

**行动1 — 补齐触发词 (P0)**: 
每个skill的description加4-8个精准触发词 + 不适用场景 + 正反例。
投入: 5min/skill。效果: 匹配率47%→81%。

**行动2 — 建立编排层 (P1)**:
为每个skill系列建路由中枢。用户只跟orchestrator对话。
投入: 3h。效果: 用户不需要记住147个skill名称。

**行动3 — 强制Beta级门禁 (P2)**:
verify-delivery.ps1自动检查。没有references+examples+EVIDENCE不进主仓库。
投入: 5s/skill。效果: 杜绝"只有一个SKILL.md"的草稿。

---

## 卡片3: 反常识卡

**标题**: 选错一个skill，比不用更差。

**正文**:
OpenSkillEval论文的发现：在某些领域（如Data），6个skill中没有一个能超越不用的基线。选错skill = -0.28的净拖累。

SkillRouter论文的发现：如果只给skill名称和描述而隐藏body，路由精度暴跌31-44个百分点。

**推论**: 不是skill越多越好。精选10个GA级skill > 100个Draft级skill。

**来源**: OpenSkillEval + SkillRouter (arXiv 2603.22455v4)

---

## 卡片4: 定义卡

**标题**: 什么是GA级Skill？

**7种必需文件**:
1. SKILL.md — 核心指令 (>1KB)
2. references/ — 原始素材，可追溯
3. examples/ — 真实案例，可验证 (≥2个)
4. EVIDENCE.md — git commit关联，可审计
5. CHANGELOG.md — 版本历史，可演进
6. tests/ — 测试用例，可复现 (≥3条)
7. git history — 真实commit序列 (≥3条)

**Draft级**: 只有SKILL.md
**Alpha级**: SKILL.md + references
**Beta级**: Alpha + examples + tests
**GA级**: 全部7种

---

## 卡片5: 数据冲击卡

**标题**: 一个数字看懂Skill生态现状

| 指标 | 数字 | 含义 |
|------|------|------|
| 总实例 | 846 | 四个目录扫出来的 |
| 唯一名称 | 358 | 去重后 |
| 有意义 | 147 | 去掉冗余目录后 |
| 有触发词 | 38 (25.9%) | Agent能匹配到的 |
| 有git | 8/245 (3.3%) | .codex目录，可追溯 |
| GA级 | 7 | 可对外交付 |

**一句话**: 从846到7，淘汰率99.2%。

---

## 卡片6: 连接卡

**标题**: Skill生态审计 → 内容创作管线

```mermaid
graph LR
    A[weread-skills 信源] --> B[dbs-content-system 结构化]
    B --> C[khazix-writer 创作]
    C --> D[humanizer-zh 去AI味]
    D --> E[brand-voice 声音一致性]
    E --> F[content-auditor 5关审计]
    F --> G[crosspost 三平台适配]
```

每个环节有对应skill，不需要大模型自主编写正文。
