# v7 答案之书 — 内容发布路线图

> 基于 content-strategy skill 框架 | 2026-06-11

## 一、内容资产盘点

| 资产 | 数量 | 状态 |
|------|------|------|
| 全书章节 | 8章+序言 | v7定稿 |
| 微信读书证据 | 68条 (10本书) | 8章全覆盖 |
| 深度知识卡 | 77张 | D:\KnowledgeBase\cards\ |
| 公众号文章 | 111篇结构化 | D:\KnowledgeBase\media\wechat\ |
| 飞书同步 | 9/9文档v7 | jcn1crrvstv9 |
| 全书统稿 | FULL_MANUSCRIPT.md (~300KB) | 零黑名单词 |
| 架构图 | ARCHITECTURE_DIAGRAM.md (Mermaid) | 新产出 |
| 配图计划 | 11张插图规划 | 待执行 |

## 二、三平台发布策略

### 公众号（首发平台）
| 阶段 | 内容 | 时间 |
|------|------|------|
| 预热 | 序言+成长路径故事 | D-7 |
| 连载1 | CH01元能力+CH02心理健康 | D-3 |
| 连载2 | CH03身体健康+CH04财富商业 | D-1 |
| 连载3 | CH05人际关系+CH06顶级人类 | D+1 |
| 连载4 | CH07问题解决+CH08第一性模型 | D+3 |
| 合集 | 全书8章统稿+架构图 | D+7 |

### 小红书（图文适配）
- 每章提取1个"反共识观点"+1个"可执行动作" → 图文卡片
- 配合 baoyu-image-cards 生成小红书图文系列
- 发布频率：每周2篇，共4周8篇

### 知乎（深度长文）
- 选取CH04(财富)、CH08(模型) 作为深度回答素材
- 配合 content-research-writer 扩展研究深度

## 三、飞书同步节奏
- 每次公众号发布后24h内 → 飞书文档自动同步
- 飞书空间: https://jcn1crrvstv9.feishu.cn/drive/

## 四、内容Skill调用优先级（剩余未用）
| 优先级 | Skill | 用途 | 预计产出 |
|--------|-------|------|---------|
| P0 | baoyu-cover-image | 答案之书封面 | 1张封面 |
| P1 | baoyu-diagram | SVG架构图 | 可嵌入的矢量图 |
| P1 | frontend-slides | HTML路演文稿 | 演讲用幻灯片 |
| P2 | wewrite | 公众号全流程 | 发布自动化 |
| P2 | content-alchemist | 全链路炼金 | 端到端管线 |
| P3 | video-editing | 短视频制作 | 每章1个60s视频 |

## 五、质量门禁（每次发布前）
1. traffic-engineering 打分 ≥ A级(75+)
2. content-guard 6门禁全PASS
3. humanizer-zh 去AI味 ≥5处改动
4. 微信读书证据 ≥1条/篇
5. 零禁用词黑名单

---

> 生成: baoyu-diagram + brand-voice + content-strategy 三skill联合
