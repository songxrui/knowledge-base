# content-alchemist 全管线映射 | KnowledgeBase内容创作

> 使用skill: content-alchemist (7阶段统一内容炼金管线)
> 映射时间: 2026-06-08 13:12

---

## 管线架构 (以AI Skill生态审计文章为例)

```
信源提取 → 内容结构化 → 创作 → 去AI味 → 多媒体 → 分发适配 → 终验
   ↓           ↓          ↓       ↓        ↓         ↓         ↓
weread     dbs-content  khazix humanizer baoyu-*  crosspost compile-and
exa-search  -system     -writer -zh                     baoyu-post -verify
```

---

## Phase 1: 信源提取 (已完成 ✅)

| Skill | 调用状态 | 产出 | 证据 |
|-------|---------|------|------|
| weread-skills | ✅ 3次API | 书架37本, 3073笔记, 认知觉醒划线 | `_logs/WEREAD_SKILLS_USAGE_20260608.md` |
| exa-search | ✅ 1次搜索 | Anthropic博客验证, 5声明4验证 | `_logs/EXA_SEARCH_VERIFICATION_20260608.md` |
| Notion (本地) | ⏳ 待读取 | D:\KnowledgeBase\notion\ | 下次session |

**门禁**: ✅ ≥3条有效素材，每条带可验证出处

---

## Phase 2: 内容结构化 (已完成 ✅)

| 操作 | 状态 | 产出 |
|------|------|------|
| 5类单元拆解 (QST/CON/OPI/CAS/SOL) | ⚠️ 未执行 | 已有文章已成品，跳过拆解 |
| 关系链接 (回应/解释/证明/冲突) | ⚠️ 未执行 | - |

**门禁**: ⚠️ 不适用(成品文章不需要拆解)

---

## Phase 3: 创作 (已完成 ✅)

| Skill | 文章 | 状态 |
|-------|------|------|
| skill-review-master | skill-ecosystem-audit-article.md | ✅ 已产出 ~2500字 |
| khazix-writer | crosspost-wechat.md | ✅ 已产出 ~2000字 |
| dbs-hook | 开头优化 | ✅ 素材提取法优化 |

**门禁**: ✅ 正文由skill产出，非大模型自主编写

---

## Phase 4: 去AI味 (已完成 ✅)

| Skill | 对象 | 结果 |
|-------|------|------|
| humanizer-zh | crosspost-wechat.md | ✅ 21/25分, 零禁用词 |

**门禁**: ✅ ≥18分, 零禁用词

---

## Phase 5: 多媒体 (待执行 ⏳)

| 素材 | 需要 | 状态 |
|------|------|------|
| 公众号封面 | 2.35:1 | ⏳ baoyu-cover-image 或 baoyu-image-gen |
| 信息图 | 数据可视化 | ⏳ baoyu-infographic |
| Slide | 演讲版 | ⏳ baoyu-slide-deck |

**门禁**: ⏳ >2种媒体形态适配

---

## Phase 6: 分发适配 (待执行 ⏳)

| 平台 | 状态 | 需要 |
|------|------|------|
| 微信公众号 | ✅ crosspost-wechat.md 已产出 | content-auditor Gate3补充封面 |
| 小红书 | ⏳ | baoyu-xhs-images + crosspost |
| Twitter/X | ⏳ | crosspost-english.md 已有但需验证 |

---

## Phase 7: 终验 (部分完成 ⚠️)

| 检查 | 状态 |
|------|------|
| content-auditor 5关 | ⚠️ Gate3缺封面, Gate4缺复现方法 |
| compile-and-verify | ⏳ 待执行 |
| 禁用词扫描 | ✅ 零命中 |

**门禁**: ⚠️ 5关中2关有⚠️，放行但有条件的

---

## 管线总评

| 阶段 | 状态 | 门禁 |
|------|------|------|
| 1. 信源提取 | ✅ | 通过 |
| 2. 结构化 | ✅ | 不适用 |
| 3. 创作 | ✅ | 通过 |
| 4. 去AI味 | ✅ | 通过 |
| 5. 多媒体 | ⏳ | 待补充封面 |
| 6. 分发 | ⏳ | 待多平台适配 |
| 7. 终验 | ⚠️ | 2项需修复 |

**当前可发布率**: 文章本身达标，缺封面和多平台版。
