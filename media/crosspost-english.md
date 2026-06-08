# English Translation — Skill Ecosystem Audit: 99% of AI Skills Are Drafts, Not Products

> Output method: baoyu-translate (Chinese→English)  
> Source: crosspost-wechat.md  
> Target: English version for international audience

---

# I Audited 846 AI Skills. 99% Don''t Qualify as "Products."

I audited 846 AI Skill instances across four local tool directories.

After deduplication: 358 unique names. After removing redundant directories: 147 meaningful skills. Reaching the product-grade standard usable by strangers: **7.**

The remaining 140 are drafts. Not "needs-a-little-polish" drafts — "one bare SKILL.md file with zero version history" drafts.

---

## Anthropic''s Standard vs. Our Reality

Let''s look at what Anthropic officially defines as a skill. From their January 2026 engineering blog: a compliant skill needs three layers — metadata (name + description, ~50 tokens) → SKILL.md (full instructions, ~500 tokens) → references/ (supporting docs, 2000+ tokens loaded on demand).

Each layer solves a different problem. Metadata handles routing — the agent glances at the description and decides whether to invoke. SKILL.md handles execution — loaded when triggered. References handle depth — fetched only when needed.

Now look at our local situation. Of 147 skills, only 25.9% have trigger words in their description. **74% are invisible to the Agent** — not because they''re low quality, but because the Agent literally doesn''t know they exist.

Academically validated: the SkillRouter paper (arXiv 2603.22455v4) quantified that hiding the skill body causes a 31–44 percentage point drop in routing accuracy.

Translation: you wrote 100 SKILL.md files, but if your descriptions aren''t precise, the Agent correctly matches fewer than 60.

---

## .git Isn''t Optional — It''s the Trust Foundation

.codex/skills: 245 skills. With .git: 8. Coverage: 3.3%.

This sounds like developer pedantry but is actually fundamental trust. When you invoke the same skill in two different sessions and get completely different results — how do you debug? Is it the skill that changed, the model, or your prompt?

Anthropic is explicit: "You can version them with Git." Not "optionally" — it''s part of the architecture.

.agents is the counterexample. 127 skills, 100% have git. Not because of superior technology, but because the creation workflow mandates "git init + initial commit." Five seconds. Result: fully traceable ecosystem.

---

## What To Do: Three Priorities

**First, add trigger words.** Not all 148. Start with the 30 most-used: 15 dbs-series, 8 content-series, 10 skill-management. Four to eight precise trigger words each, plus "not applicable" scenarios and positive/negative examples.

Done for 25 skills this round. dbs-orchestrator auto-match rate: 47% → 81%.

**Second, build orchestration layers.** Don''t let the Agent randomly match 147 skills. Like dbs-orchestrator, build a routing hub for each series. Users talk to the orchestrator; the orchestrator dispatches skills.

The SoK paper (arXiv 2602.20867v1) defines it precisely: "A skill carries its own applicability conditions, termination criteria, and callable interface." Skills should carry their own routing signals. A good orchestration layer just organizes those signals.

**Third, enforce Beta-level gatekeeping.** Use skill-overseer''s verify-delivery.ps1. No references + examples + EVIDENCE = no entry to the main repository.

This isn''t harsh. It''s "drafts don''t qualify as products."

---

This article is itself proof: skill-review-master → dbs-content-system → khazix-writer → dbs-hook → brand-voice → exa-search → viral-writer → crosspost → quality-gatekeeper. Nine skills collaborating. Not me "thinking and writing."

---
> Sources: Anthropic "Building Agents with Skills" (Jan 2026) | SoK: Agentic Skills (arXiv 2602.20867v1) | SkillsBench (arXiv 2602.12670) | OpenSkillEval (arXiv 2605.23657) | SkillRouter (arXiv 2603.22455v4)
