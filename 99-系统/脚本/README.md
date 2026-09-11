# 维护脚本

本目录包含知识库维护脚本和历史一次性工具。脚本是否可运行、是否仍被采用，以 [[../元数据/inventory/scripts-2026-07-15/README|生命周期清单]] 为准，不能根据文件名或修改时间推断。

## 当前权威入口

| 脚本 | 用途 | 调用入口 |
|---|---|---|
| `rebuild_mocs.ps1` | 重建三个根 MOC | `HOME.md` 每周维护 |
| `monthly_log_summary.py` | 汇总月度运行日志 | `99-系统/日志/LOG_POLICY.md` |

## 安全规则

1. `feishu_sync.py`、`test_feishu.py` 及生命周期清单中的六个 `weread_*` 敏感脚本，在凭据轮换及环境变量改造前禁止运行、暂存和提交。
2. 标记为 `legacy-stale-paths` 的脚本包含旧目录引用，禁止直接运行。
3. 标记为 `blocked-frozen-writer` 的脚本会写入冻结 `book-v7`，禁止从 legacy 隔离目录运行。
4. 标记为 `legacy-candidate` 或 `review-required` 的脚本没有获得删除授权，也不视为当前稳定入口。
5. 批量修复脚本执行前必须有输入范围、基线快照和可回滚输出。
6. 新增脚本必须同步生命周期清单，写明用途、输入、输出和最近验证日期。

## 当前整理状态

2026-07-15 已将 51 个没有外部引用和脚本间调用的一次性工具移入 `legacy-meta/one-off-2026-07-15/`。其中 6 个因命中 token 赋值模式被标记为 `blocked-sensitive`，其余 45 个归为普通 legacy。另有 16 个会写入冻结书稿的脚本移入 `legacy-meta/blocked-frozen-book-writers/`。根目录现保留 28 个可执行脚本，其中只有上表两个脚本被认定为权威入口。
