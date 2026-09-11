---
id: meta-abilities-project-index
status: canonical
version: "1.0"
canonical: true
updated_at: 2026-07-18
evidence_level: A-governance
---

# 元能力项目

> 当前结构已经收敛，但正文主张尚未完成证据审计。15份章节源统一为 blocked-claim-audit；在主张台账闭环前，不得作为医学、心理或统计权威稿发布。

## 权威结构

- 章节源：15份 source_role: chapter 文件，是唯一可编辑正文。
- 生成总稿：元能力个人操作系统.md，由 build-compendium.ps1 生成，不手工编辑。
- 旧理论篇、复合章节稿和旧手工总稿：见归档映射。
- 元能力个人操作系统.html 与 PDF：旧生成物，当前 stale，不代表最新章节源。

## 章节清单

| 章 | 文件 | 当前状态 | 负责人 |
|---:|---|---|---|
| 1 | 自学.md | blocked-claim-audit | 董辉 |
| 2 | 写作.md | blocked-claim-audit | 董辉 |
| 3 | 说服.md | blocked-claim-audit | 董辉 |
| 4 | 健康.md | blocked-claim-audit | 董辉 |
| 5 | 决策.md | blocked-claim-audit | 董辉 |
| 6 | 专注.md | blocked-claim-audit | 董辉 |
| 7 | 元认知.md | blocked-claim-audit | 董辉 |
| 8 | 系统思维.md | blocked-claim-audit | 董辉 |
| 9 | 创造力.md | blocked-claim-audit | 董辉 |
| 10 | 情绪调节.md | blocked-claim-audit | 董辉 |
| 11 | 执行.md | blocked-claim-audit | 董辉 |
| 12 | 戒断.md | blocked-claim-audit | 董辉 |
| 13 | 自我精神分析.md | blocked-claim-audit | 董辉 |
| 14 | 统计.md | blocked-claim-audit | 董辉 |
| 15 | 逻辑.md | blocked-claim-audit | 董辉 |

## 构建

运行：pwsh -NoProfile -File 01-项目/meta-abilities/build-compendium.ps1

构建脚本会按章节号读取15份源文件、剥离各章 frontmatter，并覆盖生成总稿。

## 编辑规则

1. 只修改章节源，不直接修改总稿。
2. 精确数字、医学心理机制、统计结果和案例先进入主张台账。
3. 案例必须标记为作者经历、可追溯公开案例、合成案例或寓言。
4. 无来源主张只能删除、软化或保持 blocked。
5. 每次修改章节后重建总稿并运行重复、标题和来源门禁。
