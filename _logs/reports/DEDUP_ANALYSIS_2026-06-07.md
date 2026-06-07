# D:\KnowledgeBase 去重与分工分析报告

> 2026-06-07 · 目录整理完成

## 一、去重统计

| 操作 | 源目录 | 目标 | 文件数 | 结果 |
|------|--------|------|:--:|------|
| 合并归档 | `_archive/` | `04_Archive/` | 3 | 3 迁移 |
| 合并废弃 | `_deprecated/` | `04_Archive/` | 6 | 6 迁移 |
| 合并归档(alchemist) | `_alchemist/_archive/` | `04_Archive/` | 3 | 3 迁移 |
| 合并废弃(alchemist) | `_alchemist/_deprecated/` | `04_Archive/` | 0 | 已空 |
| 移动展示面 | `zhanshimian/` | `assets/images/zhanshimian/` | 14 | 14 图片迁移 |
| 合并展示面(alchemist) | `_alchemist/zhanshimian/` | `assets/images/zhanshimian/` | 相同 | 无新增 |
| 删除重复卡片 | `_alchemist/cards/` | — | 35 | 100% 重复于 `cards/`，已删除 |
| 删除重复媒体 | `_alchemist/media/` | — | 75 | 全量在 `media/`，已删除 |
| 删除重复信源 | `_alchemist/SOURCES/` | — | 3 | 重复，已删除 |
| 迁移唯一输出 | `_alchemist/output/` | `output/` | 3 | 3 个唯一文件保留 |
| 删除重复笔记 | `_alchemist/zettel/` | — | 11 | 全量在 `zettel/`，已删除 |
| 合并日志 | `_alchemist/_logs/` | `_logs/` | 25 | 合并（大者保留） |
| 合并内容系统 | `_alchemist/_content-system/` | `_content-system/` | 1 | 迁移 |
| 分类媒体裸文件 | `media/*.md` | `media/articles/`, `media/_meta/`, `media/dbs/`, `SOURCES/references/` | 26 | 全部分类归位 |

**总计清理：移除 165+ 重复文件/目录，26 个裸露文件分类归位。**

## 二、最终分工

### D:\KnowledgeBase\（主库 — 永久产出交付区）
- **角色**：唯一交付区，所有发布的、可对外引用的内容存放于此
- **核心内容**：35 张深度卡、公众号长文（W1-W99+）、各平台媒体适配、产出报告、Skill 评测
- **信源层**：SOURCES/（微信读书验证、参考文献）、notion/（Notion 导出）
- **组织层**：PARA 结构（00_Inbox ~ 04_Archive）+ 主题卡片 + 媒体内容 + 产出物

### D:\KnowledgeBase\_alchemist\（工作区 — 内容工程流水线）
- **角色**：内容处理引擎，炼金术工作区
- **核心内容**：审计追踪（audit-trail）、簇综述（cluster-reviews）、旗舰内容（flagship）、策略文档（strategy）、研究（research）、规划（planning）、元数据（meta）
- **特点**：保留完整工作历史、返工记录、审计痕迹
- **不重复**：已确认无文件与主库重复

### 两库关系
- 主库 = 产出交付，_alchemist = 生产车间
- _alchemist 产出经审核后提升至主库对应位置
- 主库的 cards/ 是唯一深度卡权威来源
- 主库的 media/ 是唯一媒体内容权威来源
- _alchemist 保留审计/策略/规划等工程过程文件

## 三、当前状态

| 指标 | 值 |
|------|-----|
| 根目录数 | 19 |
| 根裸露文件 | 3（.gitignore, INDEX.md, README.md） |
| 重复目录 | 0 |
| 裸露媒体文件 | 0 |
| _alchemist 子目录 | 13 |
| _alchemist 裸露文件 | 3（.gitignore, INDEX.md, README.md） |
| GitHub | https://github.com/songxrui/knowledge-base |
