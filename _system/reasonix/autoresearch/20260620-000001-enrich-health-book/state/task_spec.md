# Task Spec: Enrich 生命之书 v2.3 → v3.0

## Goal
Use project content creation skills (ai-taste-check, faith-humanizer, content-research-writer, article-writing, faith-viral-write) to enrich `生命之书.md` from v2.3 to v3.0.

## Source File
`D:\KnowledgeBase\生命之书.md` (v2.3, 145 lines)

## Scope (what to change)
1. Run ai-taste-check on current text → fix AI-typical patterns
2. Run faith-humanizer scan → fix remaining detectable patterns
3. Add companion reading guide (aligned with project convention: 01_Projects/content-creation/health/*.md all have 伴读引导)
4. Strengthen opening hook per article-writing skill
5. Add practical tools subsection: habit tracker template, decision checklist
6. Add FAQ / common objections section
7. Add "这本书怎么来的" origin section
8. Polish transitions and section flow per content-research-writer

## Non-goals (what NOT to change)
- Evidence base: do not add or modify citations/sources
- Core structure: keep 上游根因 → 六根杠杆 → 踩坑 → 90天方案 → 证据来源
- Dose numbers and medical thresholds
- Mermaid diagram (already good)
- The fundamental scientific claims

## Allowed operations
- Read/write files within D:\KnowledgeBase\
- Edit 生命之书.md
- Read project health content for style reference

## Success criteria
1. AI-taste-check: all 6 病征 score ✅ or ⚠️ (no ❌)
2. Faith-humanizer: 41 patterns scanned, A/B/G classes cleared
3. 伴读引导 section added matching project convention
4. Opening hook strengthened per article-writing rules
5. Practical tools subsection added
6. FAQ section added covering ≥5 common questions
7. Origin story section added
8. Overall length: expanded from ~145 lines to 220-300 lines (not bloated)
9. Scientific accuracy preserved (no fabricated claims)
10. Voice consistent with existing project health content

## Verification gates
- Run ai-taste-check self-report on final output
- Run faith-humanizer scan on final output
- Compare before/after line counts
- Verify all original citations [1]-[19] preserved
