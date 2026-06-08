# Skill 项目全盘位置扫描 — 只读分析报告

> 扫描时间: 2026-06-08
> 方法: 全盘递归扫描 + 交叉比对
> 扫描范围: 7 个目录, 846 个 skill 实例, ~96 MB

## 一、各位置状态

| 位置 | Skill 数 | 有 .git | 存储 | 独有 skill | 评价 |
|------|---------|---------|------|-----------|------|
| .agents/skills | 127 | 127 (100%) | 23 MB | 92 | 🟢 主仓库 |
| .codex/skills | 245 | 8 (3.3%) | 27.1 MB | 5 | 🟡 严重膨胀 |
| .codewhale/skills | 255 | 4 (1.6%) | 24.3 MB | 15 | 🟠 待清理 |
| .jcode/skills | 219 | 2 (0.9%) | 21.9 MB | 0 | 🔴 完全冗余 |
| D:\_ai\skills | 7 | 7 (100%) | — | 6 | 🔵 独立生态 |
| D:\codex-academic-paper-skills | 1 | — | — | 1 | 🔵 待迁移 |

## 二、重复统计

- **重复 skill 名称**: 242 个
- **冗余实例**: 737 个（可删除: 495 个）
- **唯一名称**: 358 个
- **4x 重复** (四目录): ~25 个 (baoyu-* 系列, my-dev-env, pdf 等)
- **3x 重复** (三目录): ~193 个 (codex/codewhale/jcode)
- **2x 重复** (两目录): ~24 个

## 三、各位置独有 skill 清单

### .codewhale 独有 (15, 建议迁移到 .agents)
academic-paper-composer, academic-paper-strategist, agent-browser,
api-design, backend-patterns, bun-runtime, coding-standards,
dmux-workflows, documentation-lookup, everything-claude-code,
frontend-patterns, frontend-slides, mcp-server-patterns,
mle-workflow, nextjs-turbopack

### .codex 独有 (5, 建议迁移到 .agents)
github-starred-manager, keep-codex-fast, khazix-skills,
scrapling, traffic-engineering

### D:\_ai\skills 独有 (6, 建议保留)
doc, github, self-improving-agent, skill-evolver,
skill-review, weread-skills-official

### .jcode: 0 独有 (建议删除)

## 四、建议操作优先级

| 优先级 | 操作 | 影响 |
|--------|------|------|
| P0 | 删除 .jcode/skills | 释放 21.9 MB |
| P1 | 迁移 .codewhale 15 独有 → .agents | 统一入口 |
| P1 | 迁移 .codex 5 独有 → .agents | 同上 |
| P2 | .codex 210 skill: git init | 修复无版本问题 |
| P2 | .codewhale 去重 | 释放 ~20 MB |
| P3 | D:\codex-academic-paper-skills → .agents | 集中管理 |
