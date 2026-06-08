# knowledge-forge 知识管线锻造 | weread→结构化→创作→去味→终验

> 使用skill: knowledge-forge (5 Phase: 信源提取→内容结构化→创作→去AI味→终验)
> weread token: wrk-yC_PeQeCQBWIBD7_uFhTwwAA
> 锻造时间: 2026-06-08

---

## Phase 1: 信源提取 (weread-skills)

### 已有信源 (来自3次API调用)
| 来源 | 数据类型 | 数量 | 与KB连接 |
|------|---------|------|---------|
| 流量的本质与暴力_Stanley | 划线+笔记 | 27条笔记, 76%进度 | 流量skill核心素材 |
| 认知觉醒 (周岭) | 热门划线 | 961条划线, 68%进度 | 元认知/注意力主题 |
| 少有人走的路 | 笔记 | 165条笔记, 88%进度 | 自律/成长主题 |
| 穷查理宝典 | 笔记 | 26条笔记, 46%进度 | D87芒格格栅 |

### 待提取信源 (未使用，后续可执行)
| 书籍 | 原因 |
|------|------|
| 认知驱动 (周岭) | 与认知觉醒配套，待拉取划线 |
| 复利效应 (达伦·哈迪) | 56条笔记，与D44复利暗面对立视角 |
| 每周工作4小时 | 110条笔记，与效率主题连接 |
| 思考快与慢 | 行为经济学，与决策主题连接 |
| 有限与无限的游戏 | 哲学框架，与系统思维连接 |

---

## Phase 2: 内容结构化 (dbs-content-system)

### 从weread信源中拆解5类单元

#### QST (问题)
1. 流量到底是什么？ — 流量的本质与暴力
2. 如何让AI Agent正确调用skill？ — SkillRouter论文
3. 为什么耐心比毅力更重要？ — 认知觉醒
4. 什么是真正的"产品"？ — skill-overseer GA标准

#### CON (概念)
1. GA级 (7种文件标准)
2. 隐身率 (description缺触发词导致Agent无法匹配)
3. 元认知 (认知觉醒核心概念)
4. Progressive Disclosure (Anthropic三层skill架构)
5. 编排层 (orchestrator路由中枢)

#### OPI (观点)
1. "这不是优化问题，是信任问题" — crosspost-wechat.md
2. "草稿不能叫产品" — skill-ecosystem-audit-article.md
3. "选错skill比不用更差" — OpenSkillEval论文
4. "文字洁癖是底线" — dbs-content核心哲学

#### CAS (案例)
1. dbs-orchestrator从47%→81%匹配率提升
2. .codex/skills 245个中仅8个有git (3.3%)
3. .agents/skills 127个中100%有git (流程强制)
4. skill-overseer从0搭建到GA级 (2天)

#### SOL (方案)
1. 补齐触发词: 5min/skill, 4-8个词+正反例
2. 建编排层: dbs-orchestrator模式
3. 强制门禁: verify-delivery.ps1
4. 创建流程: git init + 初始commit
5. 版本控制: 每个skill独立git repo

---

## Phase 3: 创作产出

### 主产出 (已完成)
| 文章 | 创作skill | 状态 |
|------|----------|------|
| crosspost-wechat.md | khazix-writer | ✅ GA-ready |
| skill-ecosystem-audit-article.md | khazix-writer | ✅ GA-ready |

### 可衍生产出 (基于信源)
| 选题 | 所需信源 | 推荐skill链 |
|------|---------|------------|
| "流量不是搞技术，是搞人性" | 流量的本质与暴力 | dbs-content-system → khazix-writer |
| "认知觉醒5条反常识" | 认知觉醒划线 | ljg-plain (白话改写) → viral-writer |
| "复利的暗面：为什么滚雪球之前要先防雪崩" | 复利效应 (对立视角) | dbs-deconstruct → ljg-writes |
| "少有人走的路：心智成熟的165条笔记提炼" | 少有人走的路 | dbs-content-system → khazix-writer |

---

## Phase 4: 去AI味

### humanizer-zh 扫描 (crosspost-wechat.md)
| 维度 | 分 |
|------|-----|
| 句式 | 4/5 |
| 用词 | 5/5 |
| 结构 | 4/5 |
| 情感 | 4/5 |
| 细节 | 4/5 |
| **总分** | **21/25** |

---

## Phase 5: 终验

### compile-and-verify 检查项
- [x] 产出数量: ≥2篇文章 ✅
- [x] Skill调用: ≥10次 ✅ (14次)
- [x] 外部信源: ≥3个 ✅ (weread + exa + Anthropic博客)
- [x] Git版本控制: 每产出独立commit ✅ (11 commits)
- [x] AI写作特征: 零禁用词 ✅
- [ ] 封面: 待补充 ⚠️
- [ ] 多平台: 待crosspost适配 ⚠️

**管线健康度**: 5/7通过，2项待补充。

---

## 管线复用价值

knowledge-forge 此管线可复用于:
1. 任何有weread信源支持的选题
2. 任何需要外部证据的深度文章
3. 从"读书划线"到"可发布文章"的完整转化
