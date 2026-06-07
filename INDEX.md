# D:\KnowledgeBase — 知识库索引 INDEX

> 最后更新：2026-06-07 · 目录整理完成 · 零裸露文件

## 目录结构总览

| 目录 | 用途 | 说明 |
|------|------|------|
| `00_Inbox/` | 收集箱 | 待处理的新素材 |
| `01_Projects/` | 项目区 | 内容创作项目（book-decons, cognition, concept-anatomy 等） |
| `02_Areas/` | 责任区 | 持续管理领域（含飞书协作配置） |
| `03_Resources/` | 资源区 | 参考资料（含飞书门面配置） |
| `04_Archive/` | 归档区 | 已完成/废弃内容（合并自 _archive, _deprecated） |
| `assets/` | 静态资产 | 图片（含展示面 zhanshimian）、视觉资源 |
| `cards/` | 深度卡片 | 35 张核心知识卡片（C1-C7 七大母题簇） |
| `media/` | 媒体内容 | 公众号长文、即刻、知乎、小红书、Twitter 等多平台内容 |
| `notion/` | Notion 导出 | Notion 笔记原始导出 |
| `output/` | 产出交付 | reports, skill-reports, prompts, plans, inventory |
| `scripts/` | 脚本工具 | 自动化脚本 |
| `SOURCES/` | 原始信源 | 微信读书验证、参考文献、外部素材 |
| `zettel/` | 卡片笔记 | 领域笔记（认知/健康/财富/关系/创作/历史/生产力/心理学） |
| `_alchemist/` | 炼金术工作区 | 媒体工程流水线（audit-trail, cluster-reviews, flagship, strategy 等） |
| `_content-system/` | 内容系统 | dbs 结构化内容系统工程 |
| `_logs/` | 统一日志 | 所有工作日志、心跳、验证记录 |
| `选题管理/` | 选题管理 | 选题策划与记录 |
| `.codex/` | Codex 配置 | CLI 配置与 skills |
| `.dbs/` | DBS 会话 | dbs-content-system 会话存储 |

## 核心产出物位置

| 类型 | 路径 | 数量 |
|------|------|:--:|
| 深度卡片 | `cards/` | 35 张（C1-C7） |
| 簇综述 | `_alchemist/cluster-reviews/` | 7 篇 |
| 公众号长文 | `media/wechat_2026-06-07/` | W1-W99+ |
| 媒体文章 | `media/articles/` | M01-M12 |
| 旗舰内容 | `media/flagship/` / `_alchemist/flagship/` | 多篇 |
| 跨平台适配 | `media/jike/`, `media/xiaohongshu/`, `media/zhihu/`, `media/twitter/` | 各平台 |
| 产出报告 | `output/reports/` | 20+ 份 |
| Skill 评测 | `output/skill-reports/` | 15+ 份 |
| 工作日志 | `_logs/` | 50+ 份 |

## 七大母题簇

| 簇 | 主题 | 卡片数 | 核心问题 |
|:--:|------|:--:|------|
| C1 | 健康底盘 | 5 | 多巴胺、饮食、昼夜节律、成瘾、睡眠 |
| C2 | 认知操作系统 | 5 | 避毁灭、认知负债、复盘、目标函数、游戏 |
| C3 | 财富认知 | 5 | 资产vs负债、杠铃策略、一人企业、复利、交易 |
| C4 | 创作输出 | 5 | 三位一体、平台策略、内容产品化、注意力、发布 |
| C5 | 关系动力学 | 5 | 反依赖、形象管理、代际错位、形象不是虚伪 |
| C6 | 执行系统 | 5 | 负循环、P0主线、14天实验、MV系统、环境 |
| C7 | 底层思维 | 5 | 第一性原理、芒格格栅、反脆弱、反共识、系统 |

## Git 与同步

- **GitHub**: https://github.com/songxrui/knowledge-base
- **飞书**: jcn1crrvstv9 / 加密夹密码 9P28882
- **微信读书 Token**: wrk-yC_PeQeCQBWIBD7_uFhTwwAA
- **Exa Token**: c2549c02-e87f-40d3-a7d0-100bed139eb5

## 整理变更记录（2026-06-07）

- `_archive/` + `_deprecated/` → 合并至 `04_Archive/`
- `zhanshimian/` → 移至 `assets/images/zhanshimian/`
- `_alchemist/cards/` → 去重删除（与根 `cards/` 100% 重复）
- `_alchemist/media/` → 去重删除（75 文件全量在根 `media/`）
- `_alchemist/output/` → 去重后 3 个唯一文件迁移至根 `output/`
- `_alchemist/_logs/` → 合并至根 `_logs/`
- `_alchemist/_content-system/` → 合并至根 `_content-system/`
- `media/` 根目录 26 个裸露文件 → 分类至 `articles/`, `_meta/`, `dbs/`, `SOURCES/references/`
- 根目录零裸露文件（仅保留 .gitignore / INDEX.md / README.md）
