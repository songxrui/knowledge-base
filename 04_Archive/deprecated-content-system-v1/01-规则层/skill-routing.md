# Skill路由映射表

> 生成时间：2026-06-06
> 用途：内容进入_content-system后，根据内容类型自动确定skill处理链
> 维护：每次skill升级后更新本表

---

## 一、内容类型 → Skill主链

| 内容类型 | 触发条件 | Step 1 | Step 2 | Step 3 | Step 4(发布) |
|---------|---------|--------|--------|--------|-------------|
| **公众号长文** | 写文章/出稿/长文 | khazix-writer | humanizer-zh | - | content-engine(分发) |
| **深度批判文章** | 观点剖析/批判/手术刀 | ljg-think | ljg-writes | humanizer-zh | article-writing(扩展) |
| **白话科普** | 说人话/解释/grok | ljg-plain | humanizer-zh | - | content-engine(短内容) |
| **博客/教程/指南** | 教程/blog/guide | article-writing | brand-voice | humanizer-zh | crosspost |
| **社交媒体短内容** | 推文/帖子/thread | content-engine | dbs-hook(钩子) | humanizer-zh | crosspost |
| **小红书内容** | xhs/小红书/笔记 | baoyu-xhs-images | dbs-xhs-title | humanizer-zh | baoyu-post-to-wechat |
| **视频脚本** | 脚本/视频/短视频 | content-engine | dbs-hook | - | dbs-content-system |
| **演讲/演讲稿** | 演讲/speech/talk | speech | brand-voice | article-writing | - |
| **幻灯片/PPT** | PPT/演示/幻灯片 | baoyu-slide-deck | article-writing | - | - |
| **信息图/可视化** | 信息图/图表 | baoyu-infographic | baoyu-diagram | - | - |
| **新闻稿/通讯** | newsletter/通讯 | article-writing | brand-voice | humanizer-zh | content-engine |
| **SEO文章** | SEO/搜索优化 | seo | article-writing | humanizer-zh | crosspost |
| **翻译内容** | 翻译/translate | baoyu-translate | ljg-plain(白话) | humanizer-zh | - |
| **读书笔记→文章** | 读书笔记/划线/总结 | ljg-book | ljg-rank | ljg-writes | article-writing |

---

## 二、诊断/优化链（内容已有·需改进）

| 诊断目标 | Step 1 | Step 2 | Step 3 | Step 4 |
|---------|--------|--------|--------|--------|
| **AI味检测+去AI味** | stop-slop(检测) | humanizer-zh(修复) | humanizer-zh(复检) | - |
| **内容全周期诊断** | dbs-diagnosis | dbs-content-system | dbs-good-question | dbs-decision |
| **钩子/开头优化** | dbs-hook | dbs-xhs-title | dbs-deconstruct | - |
| **概念深度理解** | ljg-learn(八刀) | ljg-think(追本) | ljg-plain(白话) | ljg-writes(成文) |
| **内容质量审计** | dbs-content | dbs-slowisfast | dbs-report | - |
| **发布前自检** | humanizer-zh | stop-slop | content-engine(QG) | - |

---

## 三、平台分发链

| 目标平台 | 内容源 | Step 1 | Step 2 | Step 3 |
|---------|--------|--------|--------|--------|
| **X/Twitter** | 长文/博客 | content-engine(X规则) | brand-voice | x-api(发布) |
| **微信公众号** | 任何长内容 | khazix-writer | humanizer-zh | baoyu-post-to-wechat |
| **小红书** | 图文内容 | baoyu-xhs-images | dbs-xhs-title | humanizer-zh |
| **LinkedIn** | 专业内容 | content-engine(LinkedIn规则) | brand-voice | crosspost |
| **YouTube** | 视频脚本 | content-engine(YouTube规则) | dbs-hook | - |
| **多平台一键分发** | 单源内容 | content-engine | crosspost | brand-voice(一致性) |

---

## 四、Skill分级速查（按内容用途）

### S级（可直接信任·自动触发）
| Skill | 用途 | 触发关键词 |
|-------|------|-----------|
| khazix-writer | 公众号长文 | 写文章/写稿子/出稿/公众号/续写/扩写 |

### A级（推荐主力·手动确认后使用）
| Skill | 用途 | 触发关键词 |
|-------|------|-----------|
| dbs-hook | 钩子/开头优化 | 钩子/开头/hook/吸引人/前三秒 |
| humanizer-zh(升级后) | 去AI味 | 去AI味/活人感/说人话/自然/不像AI写的 |
| article-writing(升级后) | 博客/教程长文 | 写博客/教程/指南/长文/article |
| content-engine(升级后) | 平台内容分发 | 社交媒体/帖子/thread/分发/LinkedIn/X |
| ljg-writes(升级后) | 深度批判文章 | 深度/批判/剖析/手术刀式/挖到底 |
| ljg-plain(升级后) | 白话重写 | 说人话/白话说/grok/解释一下/12岁 |
| ljg-think(升级后) | 纵向深钻 | 想透/追本/本质是什么/为什么会这样/深挖 |

### B级（可用·需人工判断适用性）
| Skill | 用途 | 触发关键词 |
|-------|------|-----------|
| brand-voice | 声音一致性 | 声音/风格/调性/voice/tone |
| crosspost | 多平台发布 | 跨平台/同步发布/分发 |
| deep-research | 深度研究 | 研究/research/调查/来源 |
| dbs-xhs-title | 小红书标题 | 小红书标题/xhs标题/标题优化 |
| dbs-diagnosis | 内容诊断 | 诊断/分析内容/评测 |
| dbs-content-system | 内容系统化 | 内容系统/结构化/整理 |
| dbs-good-question | 好问题提炼 | 好问题/提问/question |

### C级（辅助·特定场景使用）
| Skill | 用途 |
|-------|------|
| dbs-decision/dbs-slowisfast/dbs-deconstruct/dbs-content/dbs-learning/dbs-report | dbs辅助诊断工具 |
| ljg-rank/ljg-paper/ljg-book/ljg-read | ljg深度思维工具 |
| baoyu系列 | 媒体制作/格式转换/平台发布 |

---

## 五、Skill升级追踪

| Skill | 升级日期 | 升级前分 | 升级后分(估) | 新增内容 |
|-------|---------|---------|------------|---------|
| humanizer-zh | 2026-06-05 | 67/B | 80/A | +触发条件·+反例库·+边界 |
| article-writing | 2026-06-06 | 67/B | 80/A | +执行步骤·+验证清单·+边界·+路由 |
| content-engine | 2026-06-06 | 67/B | 80/A | +执行步骤·+验证清单·+边界·+路由 |
| ljg-writes | 2026-06-06 | 71/B | 80/A | +边界·+通用输出·+路由 |
| ljg-plain | 2026-06-06 | 71/B | 80/A | +边界·+通用输出·+路由 |
| ljg-think | 2026-06-06 | 69/B | 78/A | +通用输出·+路由 |

---

> 维护规则：每次skill升级后更新第五节的追踪记录。
> 下次评测时间：2026-07-06（建议每月一次全量评测）
