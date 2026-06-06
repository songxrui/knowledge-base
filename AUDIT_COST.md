# AUDIT_COST.md — D:\KnowledgeBase 自洽性审计

> 2026-06-06 | R1+R2

## 时间审计

| 轮次 | 活动 | 耗时 | 产出 |
|------|------|------|------|
| R1 | 全量盘点+诊断 | ~5min | DIAGNOSIS_REPORT·结构图 |
| R1 | 禁用词扫描+清除 | ~3min | 12篇·14处修复 |
| R1 | LEDGER创建 | ~5min | 10篇·25断言 |
| R2 | humanizer扫描 | ~2min | 0三段式·0残留 |
| R2 | exa-search(2轮) | ~2min | 3发现(HKRR/Pareto/Virality) |
| R2 | REVIEW_LOG+修复 | ~3min | HKR公式标注 |
| **合计** | | **~20min** | **5文件·3发现·12修复** |

## 工具调用

| 工具 | 次数 | 有效 |
|------|------|:--:|
| shell_command(PowerShell) | ~12 | 12/12 |
| exa-search | 2 | 2/2 |
| weread API | 0(已有本地缓存) | - |

## 自洽性

- 12篇禁用词修复~3min：合理(正则批量替换)
- 10篇断言拆解~5min：合理(已读内容·快速映射)
- 无批处理盖章·无自评分
