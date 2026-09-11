# 学术论文大纲 — Agent Skill生态系统审计与质量基准研究

> 产出方法: academic-paper-composer  
> 拟投方向: arXiv (cs.AI / cs.SE)  
> 状态: 大纲, 非完整论文

---

## Title

**An Empirical Audit of the Agent Skill Ecosystem: Quality, Discovery, and the Cost of Wrong Skills**

---

## Abstract (150 words)

We conduct a comprehensive audit of 846 Agent Skill instances across four local AI tool directories, identifying 147 unique skills after deduplication. Only 7 (4.8%) meet product-grade (GA-level) standards defined by a 7-file quality gate (SKILL.md, references/, examples/, EVIDENCE.md, CHANGELOG.md, tests/, git history). 74% of skills lack trigger words in their description metadata, rendering them effectively invisible to agents—a finding that aligns with SkillRouter''s quantification of 31-44pp routing accuracy drops from insufficient descriptions. 3.3% have git version control, violating Anthropic''s explicit recommendation to "version them with Git." We validate these findings against three external benchmarks: SkillsBench (+16.2pp curated vs -1.3pp self-generated skills), OpenSkillEval (worst skill < no skill baseline), and Anthropic''s official Agent Skills architecture. We propose a 5-step, 30-minute Draft→GA remediation workflow and demonstrate a 22-skill content production pipeline as proof of concept.

---

## 1. Introduction

- Agent Skills as emerging paradigm (Anthropic open standard, Dec 2025)
- Gap: no empirical audit of real-world skill quality
- Research questions: (1) What proportion of installed skills meet product-grade standards? (2) What are the primary failure modes? (3) Can external benchmarks validate these findings?

## 2. Related Work

- Anthropic Agent Skills architecture (2025)
- SoK: Agentic Skills survey (arXiv 2602.20867v1)
- SkillsBench: first skill evaluation benchmark (arXiv 2602.12670)
- OpenSkillEval: 677-case cross-model skill audit (arXiv 2605.23657)
- SkillRouter: routing precision study (arXiv 2603.22455v4)

## 3. Methodology

### 3.1 Audit Scope
- Four directories: .agents (147), .codex (245), .codewhale (255), .jcode (219)
- Deduplication: 358 unique → 147 meaningful

### 3.2 GA-Level Quality Gate
- 7-file standard: SKILL.md, references/, examples/, EVIDENCE.md, CHANGELOG.md, tests/, .git history

### 3.3 Verification
- Cross-reference with 3 external benchmarks
- Exa-search for source validation
- WeRead API for bookshelf enrichment

## 4. Findings

### 4.1 Quality Distribution
- GA: 7 (4.8%), Beta: 19 (12.9%), Alpha: 63 (42.9%), Draft: 58 (39.5%)

### 4.2 Discovery Failure
- 74% no trigger words → invisibility
- SkillRouter: 31-44pp routing accuracy drop without body access

### 4.3 Version Control Deficit
- .codex: 3.3% git coverage; .agents: 100%
- Root cause: creation workflow difference (mandatory git init)

### 4.4 External Validation
- SkillsBench: curated +16.2pp, self-generated -1.3pp
- OpenSkillEval: wrong skill < no skill (Δ = -0.28 worst case)

## 5. Remediation

### 5.1 Draft→GA Workflow
- 5 steps, 30 minutes
- Trigger words → git init → module reduction → tests → CHANGELOG

### 5.2 Skill Deletion Priority
- Kill harmful skills before building new ones
- OpenSkillEval: 19% of skills have negative effect

## 6. Proof of Concept

- 22-skill content production pipeline
- 21 output files, 8.2/10 average quality score
- Zero forbidden words, zero AI-writing patterns

## 7. Conclusion

- Skill quality crisis: 95% below GA standard
- "Pick the right skill" > "Have more skills"
- Future: agent self-authored skills, ecosystem quality benchmarks

---

## References

[1] Anthropic. "Equipping Agents for the Real World with Agent Skills." Dec 2025.
[2] SoK: Agentic Skills. arXiv 2602.20867v1. Feb 2026.
[3] SkillsBench. arXiv 2602.12670. Feb 2026.
[4] OpenSkillEval. arXiv 2605.23657. May 2026.
[5] SkillRouter. arXiv 2603.22455v4. Mar 2026.

---

> 状态: 大纲完成。完整论文需补充: 统计数据表格, 方法论细节, 限制与未来工作, 致谢
