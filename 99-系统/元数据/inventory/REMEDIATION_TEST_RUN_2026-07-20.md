# 修复计划回归测试记录

> 日期：2026-07-20；补充复跑：2026-07-21、2026-07-22
> 目的：记录本轮可重复的本地验证，不替代服务端轮换、真实用户验证或真人试玩。

## 运行结果

| 测试 | 命令 | 结果 |
|---|---|---|
| 内容质量门禁基线 | `pwsh -NoProfile -File .\99-系统\脚本\tests\Test-ContentQualityGate.ps1 -Root D:\KnowledgeBase` | PASS；1260 files，P0=0，P1=1，P2=0 |
| 凭据脱敏回归 | `pwsh -NoProfile -File .\99-系统\脚本\tests\Test-CredentialRemediation.ps1 -Root D:\KnowledgeBase` | PASS；提示词、缓冲报告、6 个目标脚本及 legacy 目录 Gitleaks clean |
| 游戏自动化回归 | `npm test`（`01-项目/game-opportunity-lab/`） | 37 passed / 0 failed |

## 2026-07-21 补充复跑

- 内容质量门禁：PASS；当前扫描 1260 个文件，`P0=0`、`P1=1`、`P2=0`；唯一 P1 仍为 `199社群` 的 `status: blocked` 假设。
- 凭据脱敏回归：PASS；当前工作树目标文件和脱敏扫描报告通过。
- 凭据轮换台账：`-AllowPending` 结构检查 PASS，`verified=0 / pending=6`；严格检查按预期失败，不能证明服务端旧值已吊销。

## 2026-07-22 补充复跑

- 内容质量门禁：PASS；03:12 最终快照扫描 1403 个文件，`P0=0`、`P1=1`、`P2=0`；canonical 稳定 ID 索引由 73 增至 74，新增项为 `04-知识/方法论/最佳实践行动指南.md`，无缺失或重复 ID。
- `proofline` 的 `solo-ai-opportunity-reset-v2.md` 已标记为可追溯的重写前证据，`v3` 保持单一最终报告；34 条有意重复段落告警归零。
- Quarry 的 Playwright 原始证据保留 ANSI 着色字节；门禁只在控制字符扫描副本中移除标准 ANSI CSI 序列。14 组成功/失败输出与 `run.json` 的 `outputSha256` 全部匹配。
- 凭据脱敏回归：PASS；轮换台账仍为 `verified=0 / pending=6`，用户豁免风险没有被改写为已关闭。

## 当前未决项

- 唯一内容 P1 仍为 `05-内容生产/进行中/199社群产品设计文档_v2.md` 的阻断产品假设。
- 服务端旧凭据吊销、旧值拒绝证据和历史候选最终处置未完成。
- `199社群` 没有真实付款/访谈/交付记录。
- 游戏没有当前修复版本的真人试玩记录；已按用户指示跳过，不作为本轮完成条件，也不产生玩家价值声明依据。
