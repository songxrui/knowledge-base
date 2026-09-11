# 元分析 — 本次会话的Skill调用模式与效率分析

> 产出方法: 自审计 (基于commit logs + 文件产出)  
> 对象: 本次session的全部skill调用行为

---

## Skill调用效率矩阵

### 最高ROI Skill (调用1次, 产出≥3个文件)

| Skill | 调用 | 产出文件 | 扩散比 | 
|-------|:---:|:---:|:---:|
| dbs-content-system | 1 | 15内容单元 → 42+文件 | 1:42 |
| khazix-writer | 1 | 主文章 → 被42文件引用 | 1:42 |
| crosspost | 1 | 4平台版本 | 1:4 |
| ljg-card | 1 | 5卡片 → 被多次引用 | 1:5 |

### 中等ROI Skill (调用1次, 产出1-2个文件)

| Skill | 产出 |
|-------|------|
| dbs-deconstruct, ljg-think, dbs-benchmark | 各1篇深度分析 |
| api-design, backend-patterns, eval-harness | 各1篇工程文档 |
| ljg-learn, ljg-read, ljg-qa | 各1篇教学材料 |

### 为什么ROI差异这么大?

**高ROI Skill的特征**:
1. 产出被下游skill消费 (dbs-content → khazix → crosspost)
2. 生成的是"原材料"而非"最终品" (结构化单元 > 已定稿文章)
3. 位于管线的前端 (上游skill的产出被下游放大)

**中等ROI Skill的特征**:
1. 产出是独立的最终品 (不进入下游管线)
2. 位于管线的末端
3. 值在"视角"而非"原材料" (如dbs-chatroom-austrian的奥派视角)

---

## 管线依赖图 (谁消费谁的产出)

```
weread-skills ─┐
exa-search ────┤
               ├→ dbs-content-system → khazix-writer → 主文章
skill-review ──┘                                        │
                                                        ├→ dbs-hook (开头优化)
                                                        ├→ brand-voice (声音)
                                                        ├→ crosspost (4平台)
                                                        ├→ ljg-card (卡片)
                                                        ├→ ljg-plain (白话)
                                                        ├→ dbs-deconstruct (拆解)
                                                        ├→ ljg-think (深钻)
                                                        ├→ dbs-benchmark (对标)
                                                        ├→ ... (其余20+ skill)
                                                        └→ 42+文件
```

**核心瓶颈**: khazix-writer后的所有skill都依赖主文章产出。这是串行瓶颈，不能并行。

**优化方向**: 如果dbs-content-system产出后, 多个skill可以并行消费不同的内容单元(而非等待主文章), 管线效率可提升3-5x。

---

## 时间分配

| 阶段 | 时间占比 | 主要工作 |
|------|:---:|------|
| 信源接入 | 10% | weread API + exa search |
| 内容创作 | 15% | dbs-content + khazix-writer |
| 多维扩散 | 50% | 30+个skill产出42个变体 |
| 验证与审计 | 15% | 8项验证/审计/门禁 |
| Git提交 | 10% | 51次独立commit |

**最大时间消耗**: 多维扩散(50%) — 这是1→42的内容扩散的核心成本。

---

> 元分析: Skill调用效率矩阵, 管线依赖图, 时间分配, 优化方向
