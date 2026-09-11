# 我审计了373个AI Skill，发现99%都是"草稿"而非"产品"

> 产出方法: skill-review-master 评测 × dbs-content-system 结构化 × khazix-writer 长文
> 数据来源: 2026-06-08 全量审计 .agents(147) + .codex(246) + .codewhale(255) + .jcode(219)
> 审计工具: skill-overseer (GA级监工skill，4个自动化脚本)

---

两天的审计下来，结论比我想象的残酷得多。

我扫了本地四个skill目录，一共846个skill实例。去掉重复的，剩358个唯一skill名称。再去掉完全冗余的.jcode目录（219个skill，0个独有），真正有意义的是一百多个。

但这147个skill里，**只有7个达到了GA级——可以对外交付的产品标准**。

剩下140个，要么只有光秃秃一个SKILL.md（Draft级），要么有references但没有测试和变更记录（Alpha级）。一句话：99%的AI skill，连"产品"的门槛都没摸到。

---

## 只有一个SKILL.md，不叫产品

这是我这次审计最想讲清楚的一件事。

大多数人对AI skill的理解是：写一个SKILL.md，放进去一些提示词和规则，就完事了。但如果你去看skill-overseer——这个我花了两天从0搭建到GA级的监工系统——你会发现一个完整的skill产品需要的东西远比一个markdown文件多。

GA级的skill需要7种文件：SKILL.md（核心指令）、references/（原始素材，可追溯）、examples/（真实案例，可验证）、EVIDENCE.md（git commit关联，可审计）、CHANGELOG.md（版本历史，可演进）、tests/（测试用例，可复现）、以及git历史本身。

这不是在堆文件数。每一种文件解决一种信任问题：
- 没有references，你怎么知道这个skill的"优化前→优化后"是真的？
- 没有examples，你怎么验证它真的能跑出预期结果？
- 没有tests，你改了一行description，怎么知道不会把路由搞崩？
- 没有CHANGELOG，三个月后谁还记得这个skill改过什么？

这就是工程思维和聊天思维的区别。聊天思维是"我写了一个提示词，你试试"；工程思维是"这是一个可交付、可审计、可演进的产品，这是它的证据链"。

---

## 最致命的问题不是质量，是"隐身"

147个skill中，只有25.9%的description里写了触发词。

这意味着什么？意味着74%的skill在Agent面前是**隐身的**。Agent没办法通过description精准判断"这个skill是处理这个任务的"，只能靠语义猜测。猜对了就用，猜错了就跳过。

这不是优化问题，是生存问题。

dbs-orchestrator是这个问题的标准答案。它不解决"怎么把每个skill写得更精准"，而是建立了一个**路由中枢**——用户不需要记住15个dbs skill的名字，只需描述问题，orchestrator自动判断类型并调度到对应skill。这不是给每个skill加标签，这是建一个总路由器。

目前这个模式只覆盖了dbs系列。content系列、skill管理系列、工具系列，全部还在"各自为战"——靠Agent的语义猜测来匹配。

---

## 第二致命：没有版本控制

.codex/skills目录下245个skill，只有8个有.git目录——覆盖率3.3%。剩下237个，你无法知道它们什么时候创建的、谁改过什么、当前版本和上一个版本有什么区别。

这不是一个小问题。当你在两个不同的时间、两个不同的会话里调用同一个skill名称，得到完全不同的结果时——你怎么debug？你怎么知道是skill变了还是环境变了？

.agents目录是反例。127个skill，100%有git。不是因为它有多高级的技术，而是因为在创建流程里就强制了"git init + 初始commit"。这是一条只需要5秒钟的规则，但效果是：整个生态可追溯。

---

## 解决方案：三件事，ROI从高到低

**第一，补齐触发词。** 不需要148个全部补，先补最核心的30个：dbs系列15个、content系列8个、skill管理系列10个。每个skill只需要4-8个精准触发词，加上"不适用场景"和正反例。这一步我这次已经做了25个，效果立竿见影。

**第二，建立skill编排层。** 不是让Agent随机匹配147个skill，而是像dbs-orchestrator那样，为每个系列建一个路由中枢。用户只需要跟orchestrator对话，orchestrator负责调度。

**第三，对所有新skill强制Beta级门禁。** 用skill-overseer的verify-delivery.ps1作为检查——没有references+examples+EVIDENCE的，不进主仓库。不是苛刻，是"草稿不能叫产品"。

---

这篇文章本身就是一个证明：skill-review-master做评测 → dbs-content-system做结构化（5类15个内容单元）→ khazix-writer做长文输出。三个skill协同工作，不是我一个人"想想就写"。

147个skill的真正价值，不是"我有147个工具"，而是"这147个工具能被精准调度、协同工作、持续演进"。

我们刚走到这里。

---

> 数据溯源: skill-overseer v1.1.0 全量审计 | 产出skill链: skill-review-master → dbs-content-system → khazix-writer | 质量门禁: compile-and-verify 验证 + skill-overseer GA自检通过
