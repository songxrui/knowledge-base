# 脚本生命周期审计

> 审计日期：2026-07-15。清单覆盖 `99-系统/脚本/` 下 105 个脚本；当前分类是保守治理状态，不是删除授权。

## 分类结果

| 状态 | 数量 | 含义 |
|---|---:|---|
| `active` | 2 | 被当前权威维护文档明确调用 |
| `blocked-sensitive` | 8 | 涉及凭据风险，处置前禁止运行和暂存；其中 6 个已隔离在 legacy |
| `blocked-frozen-writer` | 16 | 会写入冻结 `book-v7` 或编排该写入链，已隔离 |
| `legacy-existing` | 55 | 已位于 `legacy-meta/`，其中 45 个本轮按零引用证据迁入普通 legacy |
| `legacy-stale-paths` | 2 | 检测到旧顶层目录引用 |
| `legacy-candidate` | 2 | 仍存在脚本间调用证据，暂不移动 |
| `review-required` | 20 | 无权威引用，但不能仅凭名称判断去留 |

完整明细见 `script-lifecycle-manifest.csv`。本轮没有删除脚本；51 个零引用一次性候选已移入 `legacy-meta/one-off-2026-07-15/`。敏感扫描随后将其中 6 个微信读书脚本重新分类为 `blocked-sensitive`；未读取或记录 token 值。

## 调用审计与迁移

- `script-usage-audit.csv`：91 个候选脚本的外部引用和脚本间调用证据。
- `moved-one-off-scripts-manifest.csv`：51 个移动文件的旧路径、新路径、SHA-256 和理由。
- `review-required-behavior-audit.csv`：35 个脚本的读写操作、领域归属和冻结路径检查。
- `moved-frozen-book-writers-manifest.csv`：16 个冻结书稿写入链脚本的隔离路径和 SHA-256。

调用审计初筛曾因引用关系保留以下三个 legacy 候选：

- `analyze_vault_v3.ps1`：被 `generate_report.ps1` 调用。
- `rebuild_home.ps1`：被 `generate_report.ps1` 调用。
- `pre_repair_snapshot.py`：被月度汇总和冻结书稿发布检查清单引用。

复核后，`pre_repair_snapshot.py` 与它调用的 `evidence_audit.py` 都会写入冻结 `book-v7`。月度汇总中的旧运行建议已替换为 Git diff、来源台账和 content-guard 基线；该工具链连同其余 14 个 book-v7 写入脚本已整体隔离。因此当前根目录只剩两个 legacy 候选：`analyze_vault_v3.ps1` 和 `rebuild_home.ps1`，二者均被 `generate_report.ps1` 调用。

根目录另有三个脚本同时出现 `book-v7` 和写操作关键词，但逐个检查后不是冻结写入：`feishu_sync.py` 只向日志追加、`monthly_log_summary.py` 只读书稿并向日志报告目录写入、`rebuild_mocs.ps1` 只在 MOC 文本中说明 book-v7。月度汇总的读取路径已修正为当前目录。

隔离目录中的 `weread_batch2.py`、`weread_batch3.py`、`weread_extract_top.py`、`weread_extract_v2.py`、`weread_highlights.py`、`weread_test.py` 命中 token 赋值模式。它们已加入敏感排除清单，在凭据轮换和环境变量改造前不得运行、暂存或提交。

## 下一步复核

1. 对两个 active 脚本执行语法与最小行为验证。
2. 修复或退役两个包含旧路径的脚本。
3. 对剩余 20 个 `review-required` 继续核实输入输出和运行依赖。
4. 复核两个仍有调用关系的 legacy 候选，决定保留调用链还是整体退役。
5. 最终只在根脚本目录保留稳定入口，历史工具不参与日常导航。
