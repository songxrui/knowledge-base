# D:\KnowledgeBase — 知识库索引 INDEX

> 最后更新：2026-06-07 · 去重分工完成 · 189 重复文件清理 · 零裸露文件

## 目录结构总览

| 目录 | 用途 | 文件数 |
|------|------|:--:|
| `00_Inbox/` | 收集箱——待处理新素材 | - |
| `01_Projects/` | 项目区——18 个内容创作子项目 | 147 |
| `02_Areas/` | 责任区——持续管理领域 | 1 |
| `03_Resources/` | 资源区——微信读书、流量工程 | 29 |
| `04_Archive/` | 归档区——已完成/废弃内容 | 129 |
| `assets/` | 静态资产——图片、视觉资源 | 28 |
| `cards/` | **深度卡片**——35 张核心知识卡片（C1-C7） | 35 |
| `media/` | **媒体内容**——14 平台/格式子目录 | ~220 |
| `notion/` | **Notion 导出**——规范副本（hui2737） | 162 |
| `output/` | **产出交付**——reports, skill-reports, prompts | 92 |
| `scripts/` | 脚本工具——自动化与爬虫 | - |
| `SOURCES/` | 原始信源——微信读书验证、参考文献 | 30 |
| `zettel/` | 卡片笔记——领域笔记（认知/健康/财富等） | 11 |
| `_alchemist/` | **炼金术工作区**——创作过程材料与规划 | ~35 |
| `_content-system/` | **DBS 内容系统**——结构化系统工程 | 结构化 |
| `_logs/` | **统一日志**——全部工作日志、心跳、审计 | 62 |
| `选题管理/` | 选题策划——选题记录 | 1 |
| `.codex/` | Codex 配置——CLI 与 skills | - |
| `.dbs/` | DBS 会话——dbs-content-system 会话 | - |

## _alchemist 工作区内部结构

| 子目录 | 用途 | 文件数 |
|------|------|:--:|
| `01_Projects/content-creation/` | 内容创作项目 | ~147 |
| `feishu-config/` | 飞书协作与门面配置 | 2 |
| `cluster-reviews/` | 7 大母题簇综述 | 7 |
| `flagship/` | X 系列旗舰初稿（工作版） | 3 |
| `meta/` | 连接矩阵、原始清单、主题 | 3 |
| `planning/` | 媒体计划、进度追踪 | 2 |
| `reports/` | 交付报告、项目复盘 | 5 |
| `research/` | 内容机会、市场调研 | 2 |
| `strategy/` | 品牌声音、内容战略、跨平台适配 | 6 |
| `03_Resources/traffic-engineering/` | 流量工程参考资料 | - |
| `03_Resources/weread/` | 微信读书原始数据 | - |

## 核心产出物位置

| 类型 | 路径 | 数量 |
|------|------|:--:|
| 深度卡片 | `cards/` | 35 张（C1-C7） |
| 公众号长文 | `media/wechat_2026-06-07/` | W1-W99+ |
| 旗舰发布版 | `media/flagship/` | F1-F3 |
| 旗舰工作稿 | `_alchemist/flagship/` | X01-X03 |
| 簇综述 | `_alchemist/cluster-reviews/` | 7 篇 |
| 跨平台适配 | `media/jike/`, `xiaohongshu/`, `zhihu/`, `twitter/` | 各平台 |
| 产出报告 | `output/reports/` | 20+ 份 |
| Skill 评测 | `output/skill-reports/` | 15+ 份 |
| 工作日志 | `_logs/` | 62 份 |

## 七大母题簇

| 簇 | 主题 | 卡片 | 核心张力 |
|:--:|------|:--:|------|
| C1 | 健康底盘 | 5 | 身体化学决定一切认知输出 |
| C2 | 认知操作系统 | 5 | 先避毁灭再求收益 |
| C3 | 财富认知 | 5 | 22 岁起步的复利路径 |
| C4 | 创作输出 | 5 | 三位一体 + 平台即产品 |
| C5 | 关系动力学 | 5 | 代际错位：从负担到 IP 引擎 |
| C6 | 执行系统 | 5 | 14 天实验替代完美规划 |
| C7 | 底层思维 | 5 | 芒格格栅跨领域可迁移 |

## 两库分工（详见 `_logs/DEDUP_DIVISION_REPORT.md`）

| 系统 | 定位 |
|------|------|
| **D:\KnowledgeBase**（主库） | 永久产出交付区——已发布/可发布内容 + 日志 |
| **\_alchemist**（工作区） | 内容炼金工坊——创作过程、初稿、规划、策略研究 |

## Git 与同步

- **GitHub**: https://github.com/songxrui/knowledge-base
- **飞书空间**: jcn1crrvstv9 / 密码: 9P28882
- **微信读书 Token**: wrk-yC_PeQeCQBWIBD7_uFhTwwAA
- **Exa Token**: c2549c02-e87f-40d3-a7d0-100bed139eb5

## 整理变更记录（2026-06-07）

### 本轮（去重分工）
- `_alchemist/audit-trail/` → 删除（25 重复 + 2 唯一合并至 `_logs/`）
- `_alchemist/notion/` → 删除（162 文件全量在主库 `notion/`）
- `_alchemist/飞书配置` → 归位至 `feishu-config/`
- 产出 `_logs/DEDUP_DIVISION_REPORT.md`
- **189 个重复文件总清理**

### 上轮（目录归并）
- `_archive/` + `_deprecated/` → `04_Archive/`
- `zhanshimian/` → `assets/images/zhanshimian/`
- `_alchemist/cards/`, `media/`, `output/`, `_logs/`, `_content-system/` → 去重删除
- 根目录零裸露文件
