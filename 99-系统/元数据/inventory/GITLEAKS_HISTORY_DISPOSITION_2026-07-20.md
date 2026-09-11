# Gitleaks 历史候选处置摘要

> 日期：2026-07-20
> 来源：`GITLEAKS_HISTORY_SCAN_2026-07-20.json`
> 安全边界：只登记数量、路径类别、处置状态和下一步，不保存 `Match`、`Secret` 或任何凭据值。

## 扫描概况

- 扫描提交：1084
- 扫描体积：约 84.31 MB
- 候选条数：604
- 唯一文件：38
- 唯一提交：19
- 规则分布：`generic-api-key=602`、`curl-auth-header=1`、`jwt=1`
- 报告字段：全部使用 `--redact`，当前 `Secret` 字段未发现未脱敏值。

## 互斥分类

| 类别 | 数量 | 路径范围 | 当前处置 | 下一步 |
|---|---:|---|---|---|
| Hyperframes 注册代码片段 | 565 | `.codex/skills/hyperframes/registry/` | `candidate-code-snippet` | 规则级确认；不把 generic-api-key 候选直接当作有效凭据 |
| 测试夹具 | 3 | Hyperframes 与 Superpowers 测试路径 | `candidate-test-fixture` | 确认测试值为非生产值并保留测试语义 |
| 历史提示词与配置 | 9 | `output/prompts/`、`_meta/` | `rotation-required` | 服务端旧值吊销后，按历史来源策略处置 |
| 微信读书来源与相关日志 | 9 | `SOURCES/`、`media/`、`_logs/weread*` | `rotation-required/protected-source` | 先完成旧值失效验证，不改写冻结来源 |
| 非微信读书日志 | 4 | `_logs/` 飞书/流程日志 | `rotation-required/historical-log` | 服务端吊销后再决定归档、脱敏或保留摘要 |
| 媒体来源台账 | 7 | `media/flagship/` 来源台账与历史稿 | `protected-source-review` | 确认候选是来源标识、示例或已吊销历史值 |
| 源码与能力文档 | 4 | telemetry 源码与 capabilities 文档 | `candidate-source-review` | 确认候选是源码或文档示例 |
| 技能文档 | 3 | `.codex/skills/knowledge-base/SKILL.md` | `manual-disposition-required` | 不导出 Match/Secret，按上下文人工处置 |

文件级台账：`GITLEAKS_HISTORY_FILE_DISPOSITION_2026-07-20.csv`，38 行、604 条候选、SHA-256 `A0152CFAB1D585E9F223331FDCE2E45EA2703D23FFA7F518AD82796381EB9FF7`。

## 结论

这份摘要完成了历史候选的分类，不等于凭据风险关闭。只有服务端旧值全部吊销、旧值请求失败证据齐全，并完成上述未决类别的文件级处置，才可把凭据状态改为 `verified_revoked`。
