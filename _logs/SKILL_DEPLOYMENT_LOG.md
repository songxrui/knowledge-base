# SKILL_DEPLOYMENT_LOG.md — Skill 落地记录（硬标准修正版）

> 修正时间：2026-06-06 | 修正原因：原版所有 skill标注"✅ 已落地"但TOOL_LEDGER显示多数仅0-2次调用
> 硬标准：≥3次真实调用 + 产出有可见痕迹 + 痕迹可定位到具体文件行

---

## 重判标准

| 状态 | 条件 |
|------|------|
| **已落地** | TOOL_LEDGER ≥3次调用 + 产出痕迹可定位 |
| **未达标** | 有调用但 <3次或痕迹薄弱 |
| **未使用** | TOOL_LEDGER 零调用或仅读SKILL.md |

## 逐个重判

| # | Skill | TOOL_LEDGER调用 | 判定 | 证据/说明 |
|---|-------|----------------|------|----------|
| 1 | weread-skills | 3 | **已落地** | notebooks+bookmarklist调用·VERIFICATION_LEDGER L2w 28条 |
| 2 | exa-search | 2→实际6+ | **已落地** | 验证L5断言3条 + 信源扩展12条(本轮) |
| 3 | compile-and-verify | 3 | **已落地** | DoD验收·QA_REPORT修复记录 |
| 4 | skill-review | 2 | **未达标** | 方法论阅读·输出评分表但未独立盲评 |
| 5 | article-writing | 2 | **未达标** | 读SKILL.md·实际文章由大模型直接写 |
| 6 | content-engine | 2 | **未达标** | 同上·框架了解·未执行生成 |
| 7 | deep-research | 2 | **未达标** | 佐证补充但产出痕迹弱 |
| 8 | humanizer | 0→本轮补 | **未达标** | 链声明21次·TOOL_LEDGER 0次·仅27处表面编辑 |
| 9 | brand-voice | 0 | **未使用** | 链声明21次·无独立执行·无可见痕迹 |
| 10 | verification-loop | 0 | **未使用** | 零调用 |
| 11 | crosspost | 2 | **未达标** | 平台策略文档·无实质分发执行 |
| 12 | strategic-compact | 2 | **未达标** | 密度压缩·痕迹弱 |
| 13 | market-research | 2 | **未达标** | 赛道分析·产出可定位 |
| 14 | fal-ai-media | 2 | **未达标** | 视觉方案·无实际生成 |
| 15 | frontend-slides | 0 | **未使用** | 演示大纲·未部署 |
| 16 | investor-materials | 0 | **未使用** | 战略备忘录·内容浅 |
| 17 | x-api | 0 | **未使用** | X_API_THREADS产出·未API调用 |
| 18 | seo | 0 | **未使用** | SEO_DEPLOYMENT·无执行 |
| 19 | stop-slop | 0 | **未使用** | 禁用词由shell批量替换替代 |
| 20 | eval-harness | 0 | **未使用** | EVAL_BENCHMARK框架·未执行评估 |
| 21 | tdd-workflow | 0 | **未使用** | 非开发项目 |
| 22 | security-review | 0 | **未使用** | 内容项目非代码 |
| 23 | coding-standards | 0 | **未使用** | 非代码项目 |
| 24 | frontend-patterns | 0 | **未使用** | 非前端项目 |
| 25 | e2e-testing | 0 | **未使用** | 非开发项目 |
| 26 | api-design | 0 | **未使用** | 非API项目 |

## 修正后统计

| 状态 | 数量 | 占比 |
|------|------|------|
| 已落地 | 3 | 11.5% |
| 未达标 | 9 | 34.6% |
| 未使用 | 14 | 53.8% |
| **真实利用率** | **3/26** | **11.5%** |

> 对比原版声称 26/26 (100%) → 实际 3/26 (11.5%)
> 差距来源：原版将"读SKILL.md了解方法论"、"在产出链头部声明skill名"算作"已使用"

## 下步：将未达标Skill升级为已落地

优先级最高的 3 个未达标 skill：
1. humanizer: 补充≥3次独立执行·每篇≥5处实质去味·留diff
2. article-writing: 至少1篇由skill生成正文·大模型仅编排
3. verification-loop: 实际运行1次全库扫描