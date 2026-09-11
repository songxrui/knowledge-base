# 凭据轮换与本地脱敏记录

> 建立日期：2026-07-17
> 安全原则：本文件只记录凭据类型、暴露位置、处置状态和验证证据，不记录任何凭据值。

## 状态定义

- local_redacted：知识库活跃文件已不保存真实值。
- rotation_required：服务端旧值是否失效尚无证据。
- protected_source：冻结来源或原始导出中仍保留历史值，不直接改写。
- verified_revoked：服务端已确认旧值失效。
- history_scan_pending：Git 历史尚未完成专用 secret scanner 检查。
- history_scan_completed_pending_rotation：当前工作树与 Git 历史已完成专用扫描，但候选处置或服务端旧值吊销仍未完成。

## 处置台账

| 服务/凭据 | 暴露范围 | 本地处置 | 外部轮换 | 当前限制 |
|---|---|---|---|---|
| 飞书应用 ID / Secret | 99-系统/脚本/feishu_sync.py、99-系统/脚本/test_feishu.py | local_redacted，改为 FEISHU_APP_ID / FEISHU_APP_SECRET | rotation_required | 轮换前不运行同步 |
| 飞书文件夹访问口令 | 三份旧提示词、活跃卡片、发布计划、冻结 book-v7 平台稿 | 活跃文件 local_redacted；冻结稿 protected_source | rotation_required | 轮换前不分享文件夹链接 |
| 微信读书 API Key / Bearer | 两份旧提示词、系统索引 | local_redacted，改为 WEREAD_API_KEY / 占位符 | rotation_required | 轮换前不调用旧端点 |
| Exa API Key | 系统索引、DS 配置、旧提示词 | local_redacted，配置改为 bearer_token_env_var = \"EXA_API_KEY\" | rotation_required | 轮换前不认定安全完成 |
| DeepSeek API Key | DS 配置、Notion 原始导出 | 配置 local_redacted，改为 env_key = \"DEEPSEEK_API_KEY\"；导出为 protected_source | rotation_required | 轮换前不推送或共享导出 |
| GitHub PAT | 旧提示词中的历史调用说明 | 活跃提示词已改为占位符 | rotation_required，需核对 gh auth status 与令牌列表 | 未核实前禁止扩大权限或写入文档 |
| 飞书测试文档 ID | 99-系统/脚本/test_feishu.py | local_redacted，改为 FEISHU_TEST_DOC_ID | 不属于密钥，但按私有资源 ID 管理 | 仅从本机环境注入 |

## 本地修改证据

- 两个飞书脚本通过 Python AST 语法解析。
- 99-系统/元数据/ds-optimization/config.toml 通过 TOML 解析。
- 七个首轮目标文件的字符缩水均低于 1.3%，引用数和主体段落结构未减少。
- 第二轮清除了两份提示词中的残余 Bearer/API Key 示例，以及两份活跃内容中的文件夹口令。
- 冻结 book-v7 和 Notion 原始导出未直接修改，已登记为外部轮换阻断项。
- Git 历史正则定位命中 37 个提交、43 个文件；报告位于 $env:TEMP/kb-credential-history-locations.txt。该结果包含测试样例等误报，未据此改写历史。

## 专用扫描器获取尝试
## 专用扫描器获取与执行状态

- 目标工具：Gitleaks v8.30.1 Windows x64，来源为官方 GitHub release。
- 官方校验值：`D29144DEFF3A68AA93CED33DDDF84B7FDC26070ADD4AA0F4513094C8332AFC4E`。
- 2026-07-20：官方 checksums 与 Windows x64 ZIP 下载成功；ZIP SHA-256 与官方值一致，`gitleaks.exe version` 输出 `8.30.1`。
- 2026-07-20：尝试执行只读 `detect`（目标为当前工作树与 Git 历史，启用 quiet/redact）；主机命令安全策略拒绝该扫描命令，未产生扫描报告，未将“已下载/已验证版本”解释为“已扫描”。
- 当前结论：专用扫描状态继续保持 `history_scan_pending`；不得使用未运行的扫描替代历史审计。

1. 在飞书、微信读书、Exa、DeepSeek 和 GitHub 服务端吊销或轮换旧值。
2. 验证所有旧值已失效，并将状态改为 verified_revoked。
3. 安装或指定专用 secret scanner，扫描当前工作树和 Git 历史。
4. 对受保护来源中的历史值建立“已吊销值哈希忽略清单”，不得保存明文。
5. 在上述四项完成前，禁止将本任务标记为完成。

## 验收证据要求

每个服务至少提供以下两项证据：

- 服务端轮换或吊销时间。
- 旧值请求被拒绝的结果。
- 新值仅存在于本机凭据存储或环境变量的确认。
- 专用 secret scanner 对工作树和 Git 历史的报告路径。

只有旧值失效且扫描完成，P0 凭据问题才算关闭。

## 2026-07-20 扫描补充

- `gitleaks dir` 已完成当前工作树扫描：约 397.71 MB，21 条候选，报告为 `GITLEAKS_WORKTREE_SCAN_2026-07-20.json`。其中 10 条活跃真实格式命中已脱敏，并通过对应文件的定向复扫；迁移 CSV、vendor 测试和受保护归档命中单独登记，未把误报当作凭据清零。
- `gitleaks git` 已完成 Git 历史扫描：1084 个提交、约 84.31 MB、604 条候选，报告为 `GITLEAKS_HISTORY_SCAN_2026-07-20.json`。候选分布以 `generic-api-key` 为主，报告全程使用 `--redact`。
- 历史扫描不等于旧值已失效。飞书、微信读书、Exa、DeepSeek、GitHub 的服务端轮换/吊销和旧值拒绝证据仍缺失。
- 当前凭据结论：`local_redacted` 已完成；`history_scan_completed_pending_rotation`；整体仍不得标记为 `verified_revoked`。

## 结构化证据入口

- 证据台账：`CREDENTIAL_ROTATION_EVIDENCE_2026-07-20.csv`，固定 6 个凭据组，不保存任何凭据值。
- 本机就绪报告：`CREDENTIAL_LOCAL_READINESS_2026-07-20.md`；当前 6 个所需环境变量均不可见，GitHub CLI 已登录但未证明旧 PAT 已吊销。
- 已暴露值状态：`CREDENTIAL_EXPOSED_VALUE_STATUS_2026-07-20.md`；DeepSeek 当前用户级值与历史暴露值相同且 API 返回 HTTP 200，必须优先吊销。
- 检查器：`99-系统/脚本/Check-CredentialRotationEvidence.ps1`。
- 宽松结构检查：`pwsh -NoProfile -File .\99-系统\脚本\Check-CredentialRotationEvidence.ps1 -Root D:\KnowledgeBase -AllowPending`。
- 严格终验：去掉 `-AllowPending`；只有 6 行均为 `verified_revoked` 且时间、拒绝证据路径、新值存储验证齐全时才通过。
- 2026-07-20 当前结果：`verified=0`、`pending=6`。
