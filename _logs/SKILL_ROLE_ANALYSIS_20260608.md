# 内容创作Skill作用分析报告

> 产出时间: 2026-06-08 13:05
> 方法: 逐skill读取SKILL.md → 提取核心作用/输入/输出/触发条件/边界
> 原则: 只分析作用，不做升级改造

---

## 一、诊断类Skill（判断内容质量，不改写）

### 1. dbs-content — 内容全周期诊断
- **作用**: 对选题→结构→初稿→润色→发布全管线评估
- **输入**: 一篇内容（选题/草稿/成稿均可）
- **输出**: 4 Phase诊断报告（形式匹配→选题评估→结构诊断→执行建议）
- **核心哲学**: 5条（文字洁癖是底线、自媒体本质是精神控制、内容好坏=投入精力×正确理解、先有产品后有内容、知识博主工作只有两件事）
- **触发**: dbs-content、内容诊断、这个内容怎么做、帮我看文案
- **不触发**: 仅开头优化→dbs-hook；仅标题优化→dbs-xhs-title
- **证据要求**: 每条诊断配≥1个具体动作+示例+优先级(🔴🟡🔵)

### 2. content-auditor — 发布前内容质量审计
- **作用**: 组合humanizer-zh+compile-and-verify+平台规则+来源追溯，5关全过才放行
- **输入**: 待发布内容+目标平台
- **输出**: 5关审计报告（AI味→任务完成度→平台规则→来源追溯→终审放行）
- **5关**: Gate1去AI味、Gate2任务完成度、Gate3平台规则、Gate4来源追溯、Gate5终审放行
- **触发**: 发布前检查、内容审计、质检、能发了吗
- **不触发**: 内容创作→khazix-writer；仅去AI味→humanizer-zh

### 3. dbs-ai-check — AI写作特征识别
- **作用**: 检测AI写作痕迹，量化"AI味"比例
- **输入**: 文本
- **输出**: AI味比例报告+具体位置标注

---

## 二、改写/润色类Skill（修改内容文本）

### 4. humanizer-zh — 中文去AI痕迹
- **作用**: 5维度检测并修复AI写作特征
- **5维度**: 句式(长短句比例5:1)、用词(禁用词扫描)、结构(禁三段式)、情感(≥1处立场表达/200字)、细节(≥1个具体细节/300字)
- **平台策略**: 公众号(1500-3000字)、小红书(300-800字)、抖音(200-500字)各有不同要求
- **触发**: 去AI味、活人感、说人话、自然点、审核/润色/编辑
- **不触发**: 纯代码、英文内容、技术文档格式调整、学术论文正文
- **执行流程**: 平台识别→5维诊断→逐段改写→反例库对照→输出before/after

### 5. khazix-writer — 公众号长文写作
- **作用**: 基于4层质检(L1硬性规则→L2风格规范→L3深度要求→L4交付标准)生成公众号长文
- **输入**: 选题/素材/方向
- **输出**: 1000-1500字公众号长文
- **风格**: 数字生命卡兹克的写作风格引擎

### 6. ljg-writes — 观点深挖写作
- **作用**: 像手术刀剖开一个观点，一层层剥到底，1000-1500字

### 7. viral-writer — 自媒体内容创作引擎
- **作用**: 11维度+三平台(公众号/小红书/抖音)深度适配+HKR选题框架+5标题策略+金句提炼+情感曲线
- **输出**: 适配具体平台的内容

---

## 三、格式化/发布类Skill（改变内容形态，不改内容）

### 8. baoyu-format-markdown — Markdown格式化
- **作用**: 格式标准化（frontmatter、标题层级、摘要、列表规范）
- **不涉及**: 内容改写
- **触发**: 格式化、排版

### 9. baoyu-markdown-to-html — Markdown转HTML
- **作用**: 转公众号可用的HTML（含CSS样式）
- **触发**: 转HTML、公众号编辑器

### 10. crosspost — 多平台内容分发
- **作用**: 一篇文章→微信/小红书/Twitter三平台适配版

---

## 四、信源/研究类Skill（补充证据和素材）

### 11. weread-skills — 微信读书助手
- **作用**: 搜索书籍、管理书架、查看笔记划线、浏览书评
- **为内容提供**: 书籍引用、原文摘录、个人划线证据

### 12. deep-research — 多源深度研究
- **作用**: 使用firecrawl和exa MCP做多源研究

---

## 五、编排/工作流类Skill（调度其他skill）

### 13. dbs-orchestrator — DBS路由中枢
- **作用**: 自动识别用户输入类型→路由到对应dbs skill
- **意义**: 用户不需要记住15个dbs skill的名字

### 14. content-alchemist — 统一内容炼金管线
- **作用**: 串联全流程：信源提取→内容结构化→创作→分析→沉淀

### 15. workflow-composer — 工作流编排
- **作用**: 将多个skill和工具编排成可重复执行的工作流

---

## 六、Skill间协作关系

```
信源层: weread-skills + deep-research + exa-search
    ↓ (提供证据和素材)
诊断层: dbs-content + content-auditor + dbs-ai-check
    ↓ (判断质量和方向)
创作层: khazix-writer + ljg-writes + viral-writer
    ↓ (生成正文)
润色层: humanizer-zh + baoyu-format-markdown
    ↓ (去AI味+格式化)
发布层: crosspost + baoyu-markdown-to-html + content-auditor(Gate5)
    ↓ (多平台适配+终审)
编排层: dbs-orchestrator + content-alchemist + workflow-composer
    (总调度)
```

## 七、当前已知问题

1. **触发词缺失**: 74%的skill description缺触发词，Agent无法精准匹配
2. **孤点skill**: 多数content skill缺少orchestrator路由，靠语义猜测
3. **产品完整度**: 仅7个skill达GA级（SKILL.md+references+examples+EVIDENCE+CHANGELOG+tests+git）
4. **交叉引用**: 部分skill间存在语义重叠（如dbs-content vs content-auditor都涉及"诊断"）
