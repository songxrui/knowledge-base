# Slide大纲 — Skill生态审计完整演示文稿

> 产出方法: baoyu-slide-deck (专业Slide设计) → 内容大纲  
> 用途: 可直接交给PPT工具或baoyu-slide-deck渲染

---

## Slide Deck: 15页

### 第1页: 封面
- 标题: "AI Skill生态审计: 846个Skill, 7个能用"
- 副标题: "从Draft到GA — 如何让你的Agent工具真正有效"
- 日期: 2026年6月

### 第2页: 审计范围
- 4个目录扫描 (.agents/.codex/.codewhale/.jcode)
- 846→358→147→7的数据链路
- 审计工具: skill-overseer v1.1.0

### 第3页: 核心发现
- 95.2%未达产品标准
- 74% Agent面前隐身
- 3.3%有版本控制
- 32%可能有负面效果

### 第4页: 什么是GA级Skill?
- 7文件标准 (SKILL.md/references/examples/EVIDENCE/CHANGELOG/tests/git)
- 与Anthropic标准对齐
- 对比: Draft只有SKILL.md

### 第5页: 外部验证
- SkillsBench: +16.2pp curated / -1.3pp self-gen
- OpenSkillEval: 选错<不用
- SkillRouter: 31-44pp精度下降

### 第6页: 第一性拆解
- 5变量(可发现性/可执行性/可验证性/可组合性/可演进性)
- 3层定义(表层→中层→深层)
- 一句定义: "Skill是Agent的可执行外脑"

### 第7页: 隐身危机
- 74%无触发词
- SkillRouter量化: -31~44pp路由精度
- 实测: 补齐25个→47%→81%

### 第8页: 信任危机
- .git覆盖率对比(.codex 3.3% vs .agents 100%)
- Anthropic: "version them with Git"
- 5秒规则: git init + commit

### 第9页: 解决方案总览
- P0: 补触发词(30min/skill)
- P0: 删有害skill
- P1: 建编排层
- P1: 规范化git
- P2: 管线稳定

### 第10页: 实操: 30min Draft→GA
- Step 1: 补触发词(5min)
- Step 2: git init(5min)
- Step 3: 模块精简(10min)
- Step 4: 建验证(5min)
- Step 5: CHANGELOG(5min)

### 第11页: 编排层架构
- dbs-orchestrator模式
- API Gateway类比
- 用户→Orchestrator→15个dbs skill

### 第12页: Token经济学
- 147 skill→7350 tokens metadata
- 分批→250-400 tokens
- 编排层→50+按需
- 目标: <2000 tokens metadata

### 第13页: 22-Skill内容管线
- 审计→结构化→创作→分析→沉淀
- 42个文件产出
- 17.7x扩散倍率
- 8外部源验证

### 第14页: 决策框架
- 先删坏的>建新的
- 修核心>全量升级
- 开源方法论>纯工程
- 验证假设>立即收费

### 第15页: 结语
- "这篇文章本身就是证明: 9个skill协同产出"
- 下一步: 修复10个核心skill + 建编排层
- GitHub: songxrui/knowledge-base

---

> baoyu-slide-deck: 15页大纲, 每页=标题+核心要点, 可直接渲染
