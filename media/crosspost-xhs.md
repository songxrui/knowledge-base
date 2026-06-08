# 小红书版本 — skill生态审计

> 产出skill链: content-engine (XHS adaptation) × viral-writer
> 平台规格: 标题≤20字, 正文300-800字, 口语化, 个人经历≥1处

---

📊 装了147个AI Skill，7个能用

我干了一件很笨的事。

把电脑上四个AI工具目录里的skill全部扫了一遍。846个文件，去重后358个唯一名称，再摘掉完全冗余的，剩147个。

然后我一个一个看：有没有references？有没有测试用例？有没有git版本记录？

结果：**只有7个达标。**

---

剩下的140个是什么状态？

📛 74%的skill连触发词都没写 — AI根本不知道这些skill存在，安装=白装

📛 245个.codex skill里只有8个有.git — 改了什么都查不到，出了问题没法debug

📛 大部分skill只有一个光秃秃的SKILL.md — Anthropic官方要求的是三层结构：metadata+body+references

---

不是我定的标准。

Anthropic今年1月发博客说skill要"version them with Git"。学术界SkillRouter论文量化过：description写不好，路由精度暴跌31-44个百分点。

我自己的真实体验：上周调dbs-orchestrator，加了触发词后自动匹配率从47%提到81%。不是优化，是让skill别在AI面前隐身。

---

建议你花5分钟：
去skills目录，数一下有多少个有.git文件夹的。

评论区告诉我你的数字 👇

#AI工具 #Skill工程 #Prompt工程 #效率提升
