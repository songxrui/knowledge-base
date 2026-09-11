# 《书不是行动系统》v2：预检与基线

> 建立日期：2026-07-16。用途：锁定旧稿与改动边界；不是研究结论。

## 目标

基于可核验的一手来源研究 Dan Koe 的选题、写作与信源生态，比较卢曼卡片盒、Minto 金字塔、费曼式自我解释、PARA/CODE 与学习科学证据，据此生成独立的《书不是行动系统》v2。借用方法结构，不模仿 Dan Koe 的个人声线，也不把生产力作者的方法写成实验事实。

## 锁定基线

| 文件 | 2026-07-16 SHA-256 | 处理规则 |
| --- | --- | --- |
| `flagship/article.md` | `5FED1CB4B4D11150A531CA6C3E1FCAAACE03271897E4ABD...` | 保留为“可撤回进展循环”伴生文章，不修改 |
| `flagship/article-v1.md` | 终验时补录 | 不修改 |
| `D:/KnowledgeBase/90-归档/已完成项目/books-knowing-doing-20260716/ARTICLE_FINAL.md` | `F4B0D2D1DFA37072D14C0EC9F9AE72B84259E104869A232...` | 只读底稿，不修改 |
| `README.md` | `B356CA713338D1FDA28814228A62BC7735C02B19F1896BF...` | 仅在交付完成后增加 v2 导航与状态 |
| `D:/KnowledgeBase/03-资源/创作者素材/Dan-Koe/01-官方内容索引.md` | `AD75748BA5AA0D517F2FEBF8E538428E6503A690DD4B184...` | 保持不改；日期校正在项目研究账本记录 |

表中哈希为终端显示截断值；终验使用 `Get-FileHash` 重新比较完整值，并在验证报告记录结果。

## 允许改动

- 新增 `research/05-dan-koe-method-and-source-audit.md`
- 新增 `research/06-note-methods-and-learning-science.md`
- 新增 `research/07-v2-source-ledger.md`
- 新增 `model/06-v2-writing-optimization-framework.md`
- 新增 `flagship/book-is-not-action-system-v2.md`
- 新增 `00-缓冲区/audit/08-v2-citation-audit.md`
- 新增 `00-缓冲区/audit/09-v2-content-guard-and-verification.md`
- 最后小幅更新 `README.md`

## 风险与处置

| 风险 | 等级 | 处置 |
| --- | --- | --- |
| 把 Dan Koe 自述当作普遍效果证据 | WARNING | 作者方法只标 `P2`；效果判断回到独立研究 |
| 模仿在世作者的独特声线 | WARNING | 只迁移问题入口、论证层级、长短媒介分工等高层机制 |
| 把流行“费曼技巧”冒充 Feynman 原法 | WARNING | 分开记录历史来源与自我解释研究 |
| 用卡片系统增加新的资料维护负担 | WARNING | 最终框架限定为一条来源链、一个论断树、一次现实验证 |
| 多文件编辑导致旧稿退化 | WARNING | 旧稿只读；新增文件逐项校验；终验做哈希、链接、长度和关键词扫描 |

## 命令边界

- 网络只读：官方页面、DOI、Crossref、PubMed/PMC、机构档案。
- 文件写入只限上述项目路径，使用 `apply_patch`。
- 不删除、不迁移、不发布、不提交、不推送，不改第三方配置或凭据。

## 预检判定

- Phase 1：范围明确，无 BLOCKER；多文件与引用密度为 WARNING。
- Phase 2：无需提权；破坏性命令 0；外部状态变更 0。
- 结论：放行。
