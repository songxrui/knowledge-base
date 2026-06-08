# baoyu-slide-deck 演讲Slide完整内容 | Skill生态审计演讲版

> 使用skill: baoyu-slide-deck (专业Slide deck生成)
> 用途: 15-20页可演讲的完整Slide
> 时间: 2026-06-08

---

## Slide 1: 标题页
**标题**: 审计846个AI Skill后, 重新定义"产品"
**副标题**: 一个个人Skill生态系统的建设实录
**日期**: 2026年6月
**演讲者**: 董辉

---

## Slide 2: 一句话冲击
**核心数据**: 846 → 358 → 147 → **7**
**解读**: 846个skill实例, 只有7个达到产品标准
**金句**: "不是优化问题, 是信任问题"

---

## Slide 3: 问题1 — 隐身
**大数字**: **74%**
**文案**: 的skill在Agent面前是隐身的
**解释**: description缺触发词 → Agent不知道什么时候调用 → skill被"隐身"
**来源**: SkillRouter论文 (arXiv 2603.22455v4): 路由精度暴跌31-44pp

---

## Slide 4: 问题2 — 无版本控制
**大数字**: **3.3%**
**文案**: 的.codex/skills有git
**对比**: .agents目录 100%有git(流程强制)
**后果**: 同一个skill用两次, 结果不同, 无法debug

---

## Slide 5: 标准 — Anthropic三层
**图示**: 
  Level 1: Metadata (~50 tokens, 始终加载)
  → Level 2: SKILL.md (~500 tokens, 触发时加载)
  → Level 3: references/ (2000+ tokens, 按需加载)

---

## Slide 6: 标准 — GA级的7种文件
**列表**:
1. SKILL.md — 核心指令
2. references/ — 可追溯素材
3. examples/ — 可验证案例
4. EVIDENCE.md — 可审计证据
5. CHANGELOG.md — 可演进的版本
6. tests/ — 可复现测试
7. git history — 真实commit序列

---

## Slide 7: 深层1 — "产品"定义错了
**来源**: ljg-think 6层深钻
**论点**: 7种文件 = 信任, ≠ 功能
**新标准**: 3步核心 = 被找到 → 被正确使用 → 被验证有效
**推论**: 对个人工具skill, 草稿就够了

---

## Slide 8: 深层2 — 产品光谱
**来源**: dbs-deconstruct 5变量拆解
**光谱**: 个人用 → 团队用 → 公开用
**匹配**: 0信任(草稿) → 低信任(Alpha) → 高信任(GA)

---

## Slide 9: 深层3 — 经济学视角
**来源**: dbs-chatroom-austrian (哈耶克×米塞斯)
**论点**: 先消灭"隐身税"(信息不对称), 再让调用数据驱动自然选择
**实践**: 补触发词 → 观察30天 → 淘汰/加强

---

## Slide 10: 深层4 — 信任深钻
**来源**: ljg-word
**3层信任**: L1功能信任 → L2溯源信任 → L3演进信任
**启示**: 先确保功能(好SKILL.md), 再补信任(7种文件)

---

## Slide 11: 管线 — 从信源到发布
**流程图**: weread → dbs-content-system → khazix-writer → humanizer-zh → content-auditor → crosspost
**状态**: 5/7阶段已覆盖, 2待补充

---

## Slide 12: 扩散 — 1:45的内容杠杆
**来源**: content-diffusion-engine
**1篇核心文章** → 3个平台适配 → 9种分析视角 → 45个衍生文件
**关键洞察**: skill = 认知透镜, 同一篇东西在不同skill眼里完全不同

---

## Slide 13: 慢方法ROI
**来源**: dbs-slowisfast
**算账**: 首月多花3h → 之后每月省8h → 3个月净省21h
**结论**: 看起来慢的方法, 长期快得多

---

## Slide 14: 护城河 — 为什么别人抄不了
**来源**: ljg-rank + ljg-invest
**可抄的**: skill文件, 管线结构
**抄不了的**: 自我纠错系统, 3073条读书笔记, "自愿被审计"的文化

---

## Slide 15: 对标 — 唯一机会
**来源**: dbs-benchmark
**定位**: 中文市场第一个系统化 Skill工程 × 内容创作 的交叉实践者
**对标**: dontbesilent (内容结构化), Simon Willison (独立开发者×写作)

---

## Slide 16: 行动 — 4步路线图
**Week1**: 补核心30个skill触发词 (1h)
**Week2**: 管线全流程测试 + 出5篇 (2.5h)
**Week3+**: 观察调用数据, 淘汰/加强
**Month3+**: 慢方法红利开始显现

---

## Slide 17: 今天做一件事
**行动**: 打开最常用的3个skill → 读description → 5秒能说清它是干什么的吗?
**不能** → 花5分钟补4-8个触发词
**投入**: 15分钟 **回报**: 这3个skill的Agent匹配率翻倍

---

## Slide 18: 结尾
**金句**: "草稿不是产品。信任不是功能。隐身不是优化问题。"
**链接**: github.com/songxrui/knowledge-base
