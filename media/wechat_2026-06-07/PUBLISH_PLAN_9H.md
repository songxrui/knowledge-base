# 9h 公众号深度长文产出计划

> Session: 2026-06-07 15:31 → 2026-06-08 00:31（9h硬停止）
> 每30min心跳: dbs调用日志 + 工时累计 + 内容质量

## 选题矩阵（5篇公众号长文，每篇3000+字）

| # | 标题 | 取材卡号 | 母题簇 | dbs skill链 | 预计工时 |
|---|------|---------|--------|-------------|---------|
| W1 | 注意力战争：22岁最值钱的资产不是代码，而是每天清醒的16小时 | C4-4+C4-5+C6-5+C2-2 | 簇4+簇6 | dbs-content-system→dbs-content→khazix-writer→dbs-ai-check→humanizer-zh→compile-and-verify | 1.5h |
| W2 | 反共识生存手册：从游戏10年到AI时代独一无二的认知武器 | C2-5+C7-4+C4-1+C5-5 | 簇7+簇2+簇4 | dbs-content-system→dbs-deconstruct→article-writing→dbs-ai-check→humanizer-zh | 1.5h |
| W3 | 完美主义在杀死你：为什么"写完就发"是唯一破局策略 | C4-5+C6-4+C4-3+C6-3 | 簇4+簇6 | dbs-content→dbs-hook→khazix-writer→dbs-ai-check→humanizer-zh | 1.5h |
| W4 | 多巴胺不是快乐分子：熬夜10年的人如何用晨光10分钟重建人生 | C1-1+C1-3+C1-4+C1-5 | 簇1 | dbs-content-system→dbs-diagnosis→article-writing→dbs-ai-check→humanizer-zh | 1.5h |
| W5 | 杠铃策略×反脆弱：22岁中国版财富与人生最优配置 | C3-2+C7-3+C2-1+C3-4 | 簇3+簇7 | dbs-content-system→dbs-content→khazix-writer→dbs-ai-check→humanizer-zh | 1.5h |
| W6 | 系统>目标：为什么"每天写300字"比"我要成为大作家"更有力量 | C7-5+C6-4+C6-2+C2-4 | 簇7+簇6 | dbs-content→dbs-hook→article-writing→dbs-ai-check→humanizer-zh | 1.5h |

## 每篇标准流水线

```
Phase A: dbs-content-system 结构化拆解
  └── 输入：选题卡组(3-5张) → 输出：QST+CON+OPI+CAS+SOL 内容单元

Phase B: dbs-content 五维诊断
  └── 五维全绿检查 → 不达标回 Phase A

Phase C: article-writing/khazix-writer 正文写作(3000+字)
  └── 全量 skill 产出，大模型只编排不写正文

Phase D: dbs-ai-check 22指纹检测
  └── 指纹 <3 处方可放行

Phase E: humanizer-zh 去AI味
  └── 五维均分 >=3.5 方可放行

Phase F: compile-and-verify 质检闸门
  └── TODO残留/接口/边界全绿

Phase G: git commit + 飞书同步
```

## 固定信源

| 信源 | 路径/方式 | 状态 |
|------|----------|------|
| 微信读书 | weread-skills API (wrk-yC...) + 已有缓存272KB | ✅ |
| dontbesilent社群 | 飞书加密夹(密码9P28882) | ✅ |
| Notion笔记 | D:\KnowledgeBase\notion\hui2737 (155 MD) | ✅ |
| Exa搜索 | MCP (书籍优先) | ✅ |
| 飞书知识库 | jcn1crrvstv9 | ✅ |

## 完成定义 (DoD)

- [ ] 产出 >=6 篇公众号长文，每篇 >=3000 字
- [ ] 每篇经过 dbs-content-system + dbs-content + dbs-ai-check + humanizer-zh + compile-and-verify
- [ ] TOOL_LEDGER 每篇 >=5 次 dbs skill 调用记录
- [ ] 全库零禁用词、零22指纹超标
- [ ] 9h 工时累计达标（心跳日志完整）
- [ ] 三端同步: 本地 commit + GitHub push + 飞书
