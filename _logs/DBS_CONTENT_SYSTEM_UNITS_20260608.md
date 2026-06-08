# dbs-content-system 内容结构化 | 本轮全部知识拆解为5类单元

> 使用skill: dbs-content-system (QST/CON/OPI/CAS/SOL 5类单元)
> 输入: 本轮26个分析文件
> 时间: 2026-06-08

---

## QST (问题) — 共6个

| ID | 问题 | 来源文件 |
|----|------|---------|
| QST-01 | 为什么74%的skill在Agent面前是隐身的？ | CONTENT_DIAGNOSIS |
| QST-02 | "产品"的正确定义是什么？7种文件够吗？ | LJG_THINK |
| QST-03 | 快方法和慢方法怎么选？ROI怎么算？ | DBS_SLOWISFAST |
| QST-04 | 如何让skill生态自我进化而非中央计划？ | DBS_CHATROOM_AUSTRIAN |
| QST-05 | 现有2篇文章的真实可验证率是多少？ | CONTENT_TRUTH_LOCK |
| QST-06 | 下一步该先做什么？出内容还是优化系统？ | LJG_ROUNDTABLE |

---

## CON (概念) — 共8个

| ID | 概念 | 定义 | 来源 |
|----|------|------|------|
| CON-01 | 隐身税 | description缺触发词导致的Agent无法匹配 | DBS_DECONSTRUCT |
| CON-02 | 产品光谱 | 产品不是开关(是/否)，是连续光谱(个人用→团队用→公开用) | LJG_THINK |
| CON-03 | 3步核心 | skill能用的最低标准: 被找到→被正确使用→被验证有效 | DBS_DECONSTRUCT |
| CON-04 | 信任基础设施 | 7种文件(不是功能)是让别人敢用你的skill的信任层 | DBS_DECONSTRUCT |
| CON-05 | 慢方法 | 首次投入大但长期节省的方法论(首月+3h, 每月省8h) | DBS_SLOWISFAST |
| CON-06 | Skill市场 | 让调用数据驱动优胜劣汰，而非人工选定核心skill | DBS_CHATROOM_AUSTRIAN |
| CON-07 | 匹配率 | skill被正确触发次数/总触发机会(不受隐身影响的信号) | DBS_CHATROOM_AUSTRIAN |
| CON-08 | 审计者风格 | 用数字拆穿幻觉、用对比制造张力、用三件事收官的写作风格 | BRAND_VOICE |

---

## OPI (观点) — 共6个

| ID | 观点 | 提出者/来源 |
|----|------|-----------|
| OPI-01 | "7种文件解决信任问题,不是功能问题" | LJG_THINK |
| OPI-02 | "99%不配叫产品"这个论断太苛刻—对个人工具,草稿够了 | DBS_DECONSTRUCT |
| OPI-03 | 先消灭隐身税(补触发词),再让市场决定 | DBS_CHATROOM_AUSTRIAN |
| OPI-04 | 唯一机会: 中文市场系统化Skill工程+内容创作交叉定位 | DBS_BENCHMARK |
| OPI-05 | 匹配率替代调用频率作为skill质量信号 | DBS_CHATROOM_AUSTRIAN |
| OPI-06 | 内容管线首篇慢(30min搭建),后续快(10min/篇) | KNOWLEDGE_FORGE |

---

## CAS (案例) — 共4个

| ID | 案例 | 数据 | 来源 |
|----|------|------|------|
| CAS-01 | dbs-orchestrator匹配率提升 | 47%→81% | crosspost-wechat.md |
| CAS-02 | .codex vs .agents git覆盖率 | 3.3% vs 100% | 本地审计 |
| CAS-03 | skill-overseer从0到GA | 2天, 7种文件齐全 | skill-ecosystem-audit |
| CAS-04 | dontbesilent内容工程 | 143目录→1419内容单元 | dbs-benchmark |

---

## SOL (方案) — 共5个

| ID | 方案 | 步骤 | 来源 |
|----|------|------|------|
| SOL-01 | 补触发词 | 选30核心→每个5min→加4-8词+正反例 | DBS_SLOWISFAST |
| SOL-02 | 建内容管线 | weread→structure→write→humanize→verify | KNOWLEDGE_FORGE |
| SOL-03 | 4步路线图 | 第1周触发词→第2周管线测试→第3周起数据驱动 | LJG_ROUNDTABLE |
| SOL-04 | SkillOpt进化 | Rollout→Reflection→Edit(≤4)→Validation→Buffer | DBS_LEARNING |
| SOL-05 | 3步核心迭代 | 确保被找到→确保被正确用→确保被验证有效 | DBS_DECONSTRUCT |

---

## 关系连接 (≥5条)

| 连接 | 类型 | 说明 |
|------|------|------|
| QST-02 → OPI-01 | 回应 | OPI-01回答了QST-02 |
| OPI-01 → CON-04 | 解释 | CON-04解释了OPI-01为什么成立 |
| CAS-01 → SOL-01 | 证明 | CAS-01证明了SOL-01有效 |
| OPI-03 → QST-06 | 回应 | OPI-03给出了QST-06的方向 |
| SOL-03 → CON-05 | 实现 | SOL-03是CON-05慢方法的具体落地 |
