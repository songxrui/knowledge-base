# 对标分析 — Skill工具生态竞争格局

> 产出方法: dbs-benchmark (5重过滤法)  
> 对标对象: Anthropic Agent Skills vs Codex Skills vs 自建skill生态  
> 数据来源: Anthropic工程博客, OpenSkillEval, 本地审计

---

## 5重过滤

### 过滤1: 市场规模 (这个方向值不值得做)

**Anthropic Agent Skills**: 官方标准, 覆盖Claude.ai + Claude Code + Agent SDK + Developer Platform
**Codex Skills**: OpenAI生态, .agents/skills/目录, 与AGENTS.md集成
**自建skill生态**: 147个skill, 覆盖dbs(商业诊断)+content(内容创作)+skill管理

**结论**: Agent Skills市场刚起步(Anthropic 2025年底才发布标准)，但增速极快(SkillsBench收录47,150个skill)。方向值得投入。

---

### 过滤2: 竞争壁垒 (为什么别人不能轻易复制)

**Anthropic**: 
- 壁垒: 官方标准制定者 + 平台绑定(Claude系) + 开源社区推动
- 优势: "Code execution > instructions"的设计理念, progressive disclosure架构

**Codex**:
- 壁垒: OpenAI生态绑定 + AGENTS.md集成 + app市场分发
- 劣势: .codex/skills 3.3%有.git, 显示工程成熟度不足

**自建(dbs系列)**:
- 壁垒: dbs系列15个skill有完整的理论底座(阿德勒心理学/维特根斯坦哲学/奥派经济学)，不是纯工程工具
- 优势: content-system的结构化能力(5类内容单元+主题地图+装配稿)是独特的

**结论**: 差异化在于"理论底座+内容产出"。别人可以复制skill的工程结构，但无法复制dbs系列的理论体系和内容结构化方法论。

---

### 过滤3: 用户画像 (谁在用，为什么用)

**Anthropic用户**: 开发者为主, 需要专业领域的Agent能力(PDF处理/前端设计/数据分析)
**Codex用户**: 全栈开发者, 使用AGENTS.md+skill协同工作
**自建用户**: 内容创作者+独立开发者, 需要从素材到发布的全链路能力

**结论**: 自建skill生态的独特定位是"创作者的内容工程系统"——这条赛道Anthropic和Codex都没有深耕。

---

### 过滤4: 可复制性 (如果别人想做，多久能追上)

**可复制**: 
- SKILL.md模板 (1天)
- git init + 触发词补齐 (1周)
- skill-overseer审计系统 (2周)

**不可复制**:
- dbs系列15个skill的理论底座 (需深度领域知识)
- dbs-content-system的5类内容单元方法论 (1年以上迭代)
- 董辉100+篇公众号长文的语料库 (不可复制)

**结论**: 工程层可复制(2-3周)，内容层和理论层不可复制。护城河在内容资产和理论体系。

---

### 过滤5: 信号验证 (市场是否真的需要)

**正面信号**:
- SkillsBench收录47,150个skill → 生态在爆炸
- Anthropic将skill发布为开放标准 → 巨头在推动
- dbs-orchestrator补齐25个skill后匹配率47%→81% → 用户验证

**负面信号**:
- 19%的skill有负面效果(OpenSkillEval) → 质量参差不齐
- 自生成skill平均-1.3pp退化(SkillsBench) → 自动生成不可靠
- .codex 3.3%有.git → 工程标准普遍很低

**结论**: 市场需要skill，但缺的是"好skill"。谁的skill质量高，谁就能在这个混乱的早期市场建立标准。

---

## 对标结论

| 维度 | Anthropic | Codex | 自建(dbs+content) |
|------|:---:|:---:|:---:|
| 平台绑定 | Claude系 | OpenAI系 | 跨平台 |
| 工程成熟度 | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ |
| 理论底座 | ⭐ | ⭐ | ⭐⭐⭐ |
| 内容产出能力 | ⭐ | ⭐ | ⭐⭐⭐ |
| 社区规模 | ⭐⭐⭐ | ⭐⭐ | ⭐ |

**唯一机会**: "有理论底座的内容工程skill生态"——这是Anthropic和Codex都不会做的方向。他们做平台，你做垂直。

---

> dbs-benchmark方法: 5重过滤(市场→壁垒→用户→可复制→信号), 对标目的不是模仿是找差异
