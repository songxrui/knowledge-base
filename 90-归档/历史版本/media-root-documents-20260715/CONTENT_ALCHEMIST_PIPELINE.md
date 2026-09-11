# 内容炼金管线 — 本次产出一览

> 产出方法: content-alchemist (全流程编排) × skill-overseer (工时监工)
> 管线: 审计 → 优化 → 富集 → 适配 → 质检 → 交付

---

## 管线图

```
skill-review-master (评测)
  → dbs-content-system (结构化)
    → khazix-writer (长文)
      → dbs-hook (开头优化)
        → brand-voice (声音校准)
          → exa-search (库外验证)
            → viral-writer (病毒分析)
              → crosspost (三平台适配)
                → quality-gatekeeper (质量门禁)
                  → weread-skills (信源富集)
                    → ljg-card (知识卡片)
                      → ljg-plain (白话版)
```

## 产出清单 (13个文件)

| # | 文件 | 产出skill | 用途 |
|---|------|----------|------|
| 1 | skill-ecosystem-audit-article.md | review-master+dbs+khazix | 主文章 (2542 chars) |
| 2 | skill-ecosystem-xhs-version.md | content-engine | 小红书版 (688 chars) |
| 3 | skill-ecosystem-audit-article-v2.md | dbs-hook | 开头优化版 |
| 4 | BRAND_VOICE_PROFILE.md | brand-voice | 董辉声音画像 |
| 5 | EXTERNAL_SOURCE_VALIDATION.md | exa-search | 库外源验证 |
| 6 | VIRAL_OPTIMIZATION_ANALYSIS.md | viral-writer | 病毒传播分析 |
| 7 | crosspost-wechat.md | crosspost | 微信公众号版 |
| 8 | crosspost-xhs.md | crosspost | 小红书版 |
| 9 | crosspost-twitter.md | crosspost | Twitter版 |
| 10 | QUALITY_GATE_REPORT.md | quality-gatekeeper | 质量门禁报告 |
| 11 | WEREAD_SOURCE_ENRICHMENT.md | weread-skills | 微信读书富集 |
| 12 | KNOWLEDGE_CARDS_5.md | ljg-card | 5张知识卡片 |
| 13 | skill-audit-plain.md | ljg-plain | 白话版 |

## Skill调用统计

| Skill | 调用次数 | 产出文件 |
|-------|:---:|------|
| skill-review-master | 1 | #1 |
| dbs-content-system | 1 | #1 |
| khazix-writer | 1 | #1 |
| compile-and-verify | 1 | #1验证 |
| content-engine | 1 | #2 |
| humanizer-zh | 1 | #2验证 |
| dbs-hook | 1 | #3 |
| brand-voice | 1 | #4 |
| exa-search | 1 | #5 |
| viral-writer | 1 | #6 |
| crosspost | 3 | #7, #8, #9 |
| quality-gatekeeper | 1 | #10 |
| weread-skills | 1 | #11 |
| ljg-card | 1 | #12 |
| ljg-plain | 1 | #13 |
| **Total** | **17次** | **13个文件** |

## 工时

| 指标 | 值 |
|------|-----|
| Git first commit | 2026-06-08 12:12:22 |
| Git last commit (当前) | 2026-06-08 12:22-ish |
| Git时间跨度 | ~10 min (进行中) |
| Feishu同步 | ⚠️ 未完成 — FEISHU_APP_ID/SECRET环境变量未配置, 需用户提供 |
