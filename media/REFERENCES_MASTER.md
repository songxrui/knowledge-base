# 外部引用索引 — 本轮所有外部信源的统一管理

> 产出方法: 统一引用索引 (替代各文件中重复的引用)  
> 用途: 单文件管理所有外部源, 其他文件用 [REF:n] 引用

---

## 外部源清单

### 一级信源 (官方/权威)

**[REF:1]** Anthropic. "Equipping Agents for the Real World with Agent Skills." Engineering Blog, Dec 2025.
URL: https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills

**[REF:2]** Anthropic. "Building Agents with Skills." Claude Blog, Jan 2026.
URL: https://claude.com/blog/building-agents-with-skills-equipping-agents-for-specialized-work

**[REF:3]** Anthropic. "Agent Skills Documentation." Claude API Docs.
URL: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview

### 学术论文

**[REF:4]** SkillsBench: Benchmarking How Well Agent Skills Work. arXiv 2602.12670, Feb 2026.
关键数据: curated +16.2pp, self-gen -1.3pp, 7,308 trajectories, 11 domains.

**[REF:5]** OpenSkillEval: Automatically Auditing the Open Skill Ecosystem. arXiv 2605.23657, May 2026.
关键数据: 677 cases, worst skill < no skill baseline, Data family no skill clears baseline.

**[REF:6]** SoK: Agentic Skills — Beyond Tool Use in LLM Agents. arXiv 2602.20867v1, Feb 2026.
关键数据: skill定义, 5 acquisition modes, progressive disclosure, routing mechanisms.

**[REF:7]** SkillRouter: Skill Routing for LLM Agents at Scale. arXiv 2603.22455v4, Mar 2026.
关键数据: 31-44pp routing accuracy drop without body, 1.2B pipeline, 80K candidate skills.

### 图书/阅读

**[REF:8]** 董辉微信读书书架. 2026-06-08 实时拉取. 
Token: weread API (wrk-yC_PeQeCQBWIBD7_uFhTwwAA). 37+本书, 涵盖心理/认知/个人成长/文学.

---

## 本地数据源

**[LOCAL:1]** Skill生态全量审计. skill-overseer v1.1.0, 2026-06-08.
846实例, 4目录(.agents/.codex/.codewhale/.jcode), 147有意义skill, 7 GA级.

**[LOCAL:2]** dbs-orchestrator触发词补齐实测.
25个skill补齐后, 自动匹配率 47% → 81%.

**[LOCAL:3]** .git覆盖率对比.
.codex 3.3% (8/245), .agents 100% (127/127).

---

## 引用规范

**在本仓库中**: 使用 `[REF:n]` 或 `[LOCAL:n]` 标记
**在外部发布**: 替换为完整引用格式

**禁止**: 伪造引用、库内交叉引用冒充独立验证、引用不可访问的URL
**必须**: 每条引用标注来源类型(官方/学术/图书/本地)和可验证性等级

---

> 统一引用索引: 8个外部源 + 3个本地源, 标准化引用格式
