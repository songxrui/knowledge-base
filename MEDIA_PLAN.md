# MEDIA_PLAN — Skill流水线媒体文稿工厂 · 选题与编排

> 生成时间：2026-06-07 | 编排官：Codex CLI | 工作模式：skill编排+质检，正文由skill产出

---

## 一、输入资产概览

| 资产 | 数量 | 状态 |
|------|------|------|
| 深度卡 | 35张 | 全≥9.5 |
| 簇综述 | 7篇(A01-A07) | 已升级 |
| 发布文 | 3篇(X01-X03) | 已有三平台适配 |
| 跨平台适配文档 | CROSSPOST_ADAPTATION.md | 9版本已有 |

## 二、本轮选题规划（8篇·按发布优先级排列）

### P0级：高传播力·即刻首发·已有基础

| # | 标题 | 目标平台 | Skill链 | 取材卡 | 类型 |
|---|------|---------|---------|--------|------|
| M01 | 《游戏十年不是浪费——一个王者荣耀玩家的能力提取报告》 | 即刻300字×5条 | content-engine + article-writing + brand-voice | C2-5, C1-4, C6-3 | 观点短文 |
| M02 | 《六格复盘：停止问"我是不是废物"》 | 小红书600字+封面 | article-writing + humanizer | C2-3, C2-1, C6-1 | 工具型笔记 |

### P1级：深度长文·公众号首发

| # | 标题 | 目标平台 | Skill链 | 取材卡 | 类型 |
|---|------|---------|---------|--------|------|
| M03 | 《22岁废柴修复手册：从每天崩溃到连续30天稳定运行》 | 公众号2500字 | article-writing + content-engine + weread-skills + humanizer | C1-1, C1-3, C1-4, C6-1, C6-3, C6-4, C2-3, C2-4 | 长文·系统修复 |
| M04 | 《代际错位不是你的人生bug，是你的IP引擎》 | 公众号2000字 | article-writing + deep-research + humanizer | C5-3, C5-5, C5-1, C2-3, C4-1 | 长文·情感共鸣 |
| M05 | 《一人企业100篇内容冷启动：中国版Dan Koe实操手册》 | 公众号2200字 | article-writing + content-engine + crosspost + brand-voice | C3-3, C4-2, C4-4, C4-5, C3-4 | 长文·实操指南 |

### P2级：特定主题·按需发布

| # | 标题 | 目标平台 | Skill链 | 取材卡 | 类型 |
|---|------|---------|---------|--------|------|
| M06 | 《14天实验SOP：把"我想变好"变成可验证的科学》 | 小红书600字 | content-engine + article-writing | C6-3, C2-4, C1-3 | 工具型笔记 |
| M07 | 《注意力是第一资产：AI时代22岁最该做的投资》 | 公众号1800字 | article-writing + market-research + humanizer | C4-4, C4-1, C3-4, C7-5 | 观点长文 |
| M08 | 《先避毁灭再求收益——22岁最该记住的决策母法则》 | 即刻300字×4条 | content-engine + strategic-compact | C2-1, C3-2, C3-5 | 观点短文 |

## 三、Skill调度表

| Skill | 本计划调用 | 用途 | 覆盖稿号 |
|-------|----------|------|---------|
| article-writing | 6次 | 长文框架+正文 | M03-M08 |
| content-engine | 4次 | 短文+平台适配 | M01, M02, M05, M06 |
| brand-voice | 2次 | 语调统一 | M01, M05 |
| humanizer | 4次 | 去AI味 | M02-M04, M07 |
| weread-skills | 1次 | 增源补证 | M03 |
| deep-research | 1次 | 深度佐证 | M04 |
| crosspost | 1次 | 多平台适配 | M05 |
| strategic-compact | 1次 | 压缩密度 | M08 |
| market-research | 1次 | 赛道佐证 | M07 |
| compile-and-verify | 8次 | 格式验证 | 全部 |

## 四、工时预估

| 工时段 | 内容 | 预估 |
|--------|------|------|
| 段1 | 选题编排(MEDIA_PLAN) | ✅ 完成 |
| 段2 | 流水线产稿8篇 | ~1.5h |
| 段3 | 校验适配+三端同步 | ~0.5h |
| **合计** | | **~2h+** |

---

> 编排原则：P0优先（已有素材+高传播力）→P1深度长文→P2补充覆盖
> 每篇完成立即commit+记录MEDIA_OUTPUT_LOG
