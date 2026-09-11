# Gitleaks 脱敏修复与扫描处置清单

> 日期：2026-07-20
> 安全边界：本文件不保存任何凭据值，只保存路径、哈希、扫描统计和处置状态。

## 扫描证据

| 范围 | 工具入口 | 结果 | 报告 |
|---|---|---:|---|
| 当前工作树基线 | `gitleaks dir`，约 397.71 MB | 21 条候选，均为 `generic-api-key` | `GITLEAKS_WORKTREE_SCAN_2026-07-20.json` |
| Git 历史 | `gitleaks git`，1084 commits，约 84.31 MB | 604 条候选；`generic-api-key=602`、`curl-auth-header=1`、`jwt=1` | `GITLEAKS_HISTORY_SCAN_2026-07-20.json` |
| 活跃提示词定向复扫 | `gitleaks dir` | `no leaks found` | 命令输出记录于续执行日志 |
| 微信读书缓冲报告定向复扫 | `gitleaks dir` | `no leaks found` | 命令输出记录于续执行日志 |
| legacy 微信读书脚本目录定向复扫 | `gitleaks dir` | `no leaks found` | 命令输出记录于续执行日志 |

## 已脱敏的活跃文件

下列文件中的历史 Token 已替换为环境变量读取或占位符。哈希用于证明修改边界，不用于恢复原值。

| 路径 | 修改范围 | 修改前 SHA-256 | 修改后 SHA-256 | 验证 |
|---|---|---|---|---|
| `03-资源/来源台账/00-缓冲区/WEREAD_VERIFICATION_REPORT.md` | Token 行 | `70CE97ECEB7595E08F67577629B42432F6ACE8E87EDE106CEE29401A501FF97E` | `3344646411587A873FC425C7BEF5AC2DB2F1B2D035BE859960CD8D6712D3B5E6` | Gitleaks clean |
| `99-系统/脚本/legacy-meta/one-off-2026-07-15/weread_batch2.py` | Token 初始化 | `3687B68DD6EFB8B26164259673091A33E49745D13C9046AC463C6664EED59975` | `59B31B33D1D4D32E3547FBE3691E28319B4C55E9C34EFAF5E9EC6101198D5C59` | Gitleaks clean，AST pass |
| `99-系统/脚本/legacy-meta/one-off-2026-07-15/weread_batch3.py` | Token 初始化 | `DD73883994AB7CF0603722AF2CAC9EED94CB55AFB5BD4396F5E3498A7BC89DFC` | `44AD80B92CAA2DBF0F8D4B02563D09A2AC6891C2988E401DE59B0BFB4562E61B` | Gitleaks clean，AST pass |
| `99-系统/脚本/legacy-meta/one-off-2026-07-15/weread_extract_v2.py` | Token 初始化 | `D0EABBD276F92E445D6644694030E36ED339DDEEA0D18019EC94C2844DC7AA45` | `C3ED369511EB15F26E7CE6DB259660FA99B89BD0D5CC91C36999E6FB9D7DB3F3` | Gitleaks clean，AST pass |
| `99-系统/脚本/legacy-meta/one-off-2026-07-15/weread_highlights.py` | Token 初始化 | `F582EFA6479C2F2BE396808C7BDEC231D4814BED70E0FB8DD377CA1828188AA3` | `264271500A89B12919AC2FBAABE3F0EE461D024F5DF5EECDE8795FA2BC122BF1` | Gitleaks clean，AST pass |
| `99-系统/脚本/legacy-meta/one-off-2026-07-15/weread_extract_top.py` | Token 初始化 | `73C901ACB0E481DC346C79EB693E2020765AC3BD4DCBD8ED2FBED07B843B91B7` | `5DED19835978A48B07F1FA514461F9C38C63B394533AC32B18E77360C9DEF94A` | Gitleaks clean，AST pass |
| `99-系统/脚本/legacy-meta/one-off-2026-07-15/weread_test.py` | Token 初始化 | `47FF94B8F2C97BE2E8F7C76EC3ADDA57075AD3A5B7D2AF82DB5A45EC9ED367` | `6047B8C15C3DF40D75A8F7DDDADF877318566D4E3ACD5B87C392CDA4057377F2` | Gitleaks clean，AST pass |
| `99-系统/元数据/知识库外科医生提示词_v2.0_DH定制.md` | 3 个凭据示例行 | 本轮前命中 | 本轮定向复扫 clean | 占位符检查通过 |

## 未修改候选的处置

- 迁移审计 CSV 中的 8 条命中位于 `sha256`、blob、路径和迁移分类字段；属于哈希/路径结构误报，不是凭据字段，保留审计证据。
- `99-系统/vendor/superpowers-zh/.../ws-protocol.test.js` 的命中是测试夹具，保留 vendor 源，不当作生产凭据。
- `90-归档/` 中的 2 条历史命中属于受保护来源；不直接改写，等待服务端旧值吊销后再按归档策略处置。
- 历史报告中的其余候选包含旧路径、代码示例、文档示例和旧值；报告已脱敏，不能据候选总数推断有效凭据数量。

## 未关闭条件

1. 飞书、微信读书、Exa、DeepSeek、GitHub 旧值仍需服务端轮换/吊销。
2. 每个旧值需要“失效请求被拒绝”的证据；新值只能留在本机凭据存储或环境变量中。
3. Git 历史报告已生成，但在外部轮换完成前不能声称凭据风险关闭，也不能改写共享历史。

