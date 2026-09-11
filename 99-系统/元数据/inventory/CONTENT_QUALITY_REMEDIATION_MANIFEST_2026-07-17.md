# 内容质量修复范围清单

> 建立日期：2026-07-17  
> 对应计划：`99-系统/元数据/planning/KNOWLEDGE_CONTENT_P0_P1_REMEDIATION_PLAN_2026-07-17.md`  
> 基线清单：`CONTENT_QUALITY_REMEDIATION_BASELINE_2026-07-17.csv`

## 目的

本清单锁定 P0/P1 内容质量修复的文件边界、操作顺序、保护路径和回滚证据。任何未登记文件不得被批量修改、移动或删除。

## Preflight 审查

### Phase 1：计划审查

- 改动范围：41 份受审大文档、计划明确的新台账、归档映射、README 和质量检查脚本。
- 风险等级：WARNING。
- 主要风险：当前顶层迁移仍有大量未跟踪新路径与旧路径删除；凭据可能已经扩散；部分计划任务包含归档移动和大文档重构。
- 放行条件：先建立本清单与哈希映射；不得使用 `git add -A`；不得在没有映射的情况下删除或移动；不得把计划数字写成完成事实。

### Phase 2：命令审查

- 任务 0 命令：只读盘点、写入临时 Git 状态快照、新建两个 inventory 文件。
- 需外部批准：服务端凭据轮换、远端 Git 历史改写、远端发布或同步。
- 破坏性操作：任务 0 无。后续归档移动必须在对应 manifest 完成后执行。
- 最终判定：任务 0 放行；任务 1 的本地脱敏放行，服务端轮换必须单独确认完成证据。

## Git 基线

- 仓库根目录：`D:/KnowledgeBase`
- Git 目录：`.git`
- 临时快照：`$env:TEMP/kb-content-remediation-before.txt`
- 状态总数：6,550
- 删除状态：3,111
- 修改状态：34
- 未跟踪状态：3,405

该基线只用于识别本计划新增 Delta，不代表这些既有状态应被恢复、暂存或提交。

## 允许修改

允许修改的现有文件以基线 CSV 的 41 行和实施计划任务 1 至任务 10 的显式路径为准，此外包括：

- `SOURCE_OF_TRUTH.md`
- `05-内容生产/内容体系/03-处理状态/内容生产事实与实验参数.md`
- `05-内容生产/选题管理/00-选题记录.md`
- `05-内容生产/运营与发布/发布队列.md`
- `08-媒体与产品/媒体/flagship/book-of-life-answers/FINAL_DELIVERY_STATUS.md`
- `01-项目/game-opportunity-lab/README.md`
- `01-项目/game-opportunity-lab/package.json`
- `01-项目/game-opportunity-lab/tests/simulation.test.mjs`
- `99-系统/元数据/planning/KNOWLEDGE_BASE_UPGRADE_PLAN_2026-07-15.md`
- `04-知识/卡片/C4-4_注意力是第一资产.md`
- `08-媒体与产品/媒体/wechat_2026-06-07/PUBLISH_PLAN_9H.md`

## 允许新建

- `05-内容生产/内容体系/03-处理状态/199社群验证台账.md`
- `05-内容生产/选题管理/选题真实性准入表.md`
- `01-项目/meta-abilities/README.md`
- `01-项目/宇宙底层机制-守恒/README.md`
- `01-项目/宇宙底层机制-守恒/claim-source-ledger.md`
- `99-系统/元数据/prompts/CONTENT_QUALITY_SURGEON.md`
- `99-系统/元数据/inventory/CONTENT_QUALITY_REMEDIATION_BASELINE_2026-07-17.csv`
- `99-系统/元数据/inventory/CONTENT_QUALITY_REMEDIATION_MANIFEST_2026-07-17.md`
- `99-系统/元数据/inventory/CREDENTIAL_ROTATION_RECORD_2026-07-17.md`
- `99-系统/元数据/inventory/TOPIC_POOL_ARCHIVE_MAP_2026-07-17.md`
- `99-系统/元数据/inventory/THEME_MAP_REBUILD_REPORT_2026-07-17.md`
- `99-系统/元数据/inventory/META_ABILITIES_CLAIM_LEDGER_2026-07-17.csv`
- `99-系统/元数据/inventory/BOOK_OF_LIFE_ANSWERS_CLAIM_LEDGER_2026-07-17.csv`
- `99-系统/元数据/inventory/CONTENT_QUALITY_GATE_RULES.md`
- `99-系统/元数据/inventory/CONTENT_QUALITY_REMEDIATION_FINAL_2026-07-17.md`
- `99-系统/脚本/audit_content_quality.ps1`

## 条件归档

以下对象只有在相应映射记录了原路径、目标路径、字节数和 SHA-256 后才允许移动：

- 第1至4期 30 天选题池和 90 天规划。第1期虽低于 20KB，但因活跃 NUL 和未确认故事作为完整性例外纳入。
- `宇宙底层机制-守恒/全文合并.md`。
- `meta-abilities/元能力--崭新之日理论篇.md`。
- `book-of-life-answers` 两份旧章节及状态文件。
- 旧内容质量提示词和技能学习笔记。

## 受保护来源中的凭据发现

以下文件属于冻结来源或原始导出，本批次不直接改写。对应凭据必须在服务端轮换并确认旧值失效：

- `08-媒体与产品/媒体/flagship/book-v7/platforms/zhihu.md`
- `99-系统/集成/notion-archive/hui2737/ExportBlock-9d4e5a7f-95e8-4fea-b65b-d46ccd8db7f4-Part-1/私人与共享/迁移/人生OS v2 0/用户画像背景 10703c54805d82349b358171b5bb6044.md`

轮换完成前，任何同步、推送或分享操作保持阻断状态。

归档目标必须位于 `90-归档/历史版本/` 的对应主题目录。归档不是删除，活跃链接必须在移动前修复。

## 只读保护

- `03-资源/`：原始资料和创作者语料。
- `08-媒体与产品/媒体/flagship/book-v7/`：冻结来源版。
- `90-归档/` 既有文件：默认只读，仅允许新建本计划的归档子目录。
- `.git/`、`.codex/`、`.agents/`、`.dbs/`、`.obsidian/`、`.reasonix/`：运行环境与配置，除计划显式路径外不得修改。
- 用户既有 34 个修改和其他未跟踪文件：不得恢复、覆盖或清理。

## 执行偏差说明

`executing-plans` 默认要求建立 Git worktree。当前迁移后的权威文件大量处于未跟踪状态，基于现有提交创建的 worktree 不包含真实当前结构，因此无法作为权威执行环境。本计划在当前工作树执行，并使用以下替代隔离：

1. 每批次显式文件清单。
2. 编辑前大小、哈希和内容指标基线。
3. 编辑后 Delta、抽样 diff 和关键词门禁。
4. 禁止批量暂存和提交。
5. 发现范围外 Delta 立即停止。

## 回滚证据

- 新建文件可按 manifest 单独删除，但在目标完成前不执行清理。
- 现有文件修改前记录 SHA-256、字节数、段落数、引用数和案例数。
- 归档文件使用映射表恢复，不使用 `git checkout` 覆盖用户现有改动。
- 同类批量修复最多三轮，超过三轮改为逐文件手工处理。

## 任务顺序

`基线与凭据 → 权威状态 → 内容真实性 → 主题地图 → 元能力 → 宇宙理论 → 旧媒体与系统 → 游戏状态 → 自动门禁 → 终验`

未通过前一阶段完成门槛，不进入下一阶段的批量正文修改。
