# _logs/ 日志管理策略

> 最后更新: 2026-06-20 | 替代旧的 7 天 TTL

## TTL 规则

| 日志类型 | TTL | 说明 |
|----------|-----|------|
| `heartbeat/` | 30 天 | 会话心跳记录，用于追踪工作节奏 |
| `reports/` | 永久 | 分析报告，历史质量趋势数据 |
| `skill-reports/` | 永久 | 技能评估报告，技能演进历史 |
| `verification/` | 30 天 | 验证记录，月度汇总后清理 |
| `ledger/` | 30 天 | 工具调用台账 |
| `deep-think/` | 永久 | 深度思考记录，知识资产 |

## 月度汇总

每月 1 日自动运行 `python scripts/monthly_log_summary.py`，生成 `_logs/reports/monthly-summary-YYYY-MM.md`。

汇总指标：
- 本月会话数
- 本月内容质量分趋势（STRONG/WEAK/NOT_FOUND 变化）
- 本月发布量
- 本月返工次数（evidence regression 检测次数）
- 本月技能调用 TOP 5

## 旧规则（已废弃）

~~7 天 TTL 全部日志 → 丢失操作历史，无法做质量趋势分析~~
