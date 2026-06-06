# LEDGER_RECONCILE.md — TOOL_LEDGER 267 vs 42 核对

> 2026-06-06 地基修复 P1-2 | 解决报告口径差异

## 差异分析

| 口径 | 数值 | 说明 |
|------|------|------|
| TOOL_LEDGER.md 全量行数 | **267** | 包含所有skill调用+API调用+shell命令 |
| 报告声称LEDGER行数 | **42** | 仅最初10篇子集 |
| VERIFICATION_LEDGER 断言条目 | **182+** (F1-F5 + SC+TC) | 含F1 29条 + F2 12条 + 其余 |
| KB VERIFICATION_LEDGER 断言 | **267** | 全库KB前缀条目 |

## 根本原因

1. **42是子集数**：报告在R10阶段声称"42条断言已LEDGER覆盖"，实际仅涵盖首批10篇知识卡
2. **267是TOOL_LEDGER行动记录**：非断言条目，是工具调用流水账
3. **混淆发生**：后续报告将"42条断言"错误继承为"全库LEDGER覆盖数"，实际全库VERIFICATION_LEDGER有267条KB前缀断言+182条alchemist断言

## 正确数值

| 指标 | 正确值 | 覆盖范围 |
|------|--------|---------|
| KB断言LEDGER覆盖 | **267** | 全库128篇卡片 |
| Alchemist断言LEDGER覆盖 | **182** | 20篇旗舰文+49篇四平台 |
| TOOL_LEDGER行动记录 | **267** | 全部skill/API/shell调用 |
| 报告应标数值 | **449** (182+267) | 两库合计断言 |
