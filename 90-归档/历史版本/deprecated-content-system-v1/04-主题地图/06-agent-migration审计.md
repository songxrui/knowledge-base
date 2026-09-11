# dbs-agent-migration 工作台迁移审计

> 审计时间: 2026-06-05
> 工作台: Codex CLI (主) + Claude Code (副)
> 方法: dbs-agent-migration Phase 1

---

## Phase 1: 迁移审计

### 规则层状态

| 文件 | 状态 | 说明 |
|---|---|---|
| AGENTS.md | ✅ 存在 | `C:\Users\董辉\.codex\AGENTS.md` — 功能完整，含ECC配置+GitHub管理+创作者工具 |
| CLAUDE.md | ❌ 缺失 | 无Claude Code兼容层 |
| SOURCE_OF_TRUTH.md | ❌ 缺失 | 无真源声明 |

### Skill分布

| 位置 | 数量 | 角色 |
|---|---|---|
| `~/.codex/skills/` | 246 | Codex主技能库（含大量baoyu/ljg系列） |
| `~/.agents/skills/` | 105 | Agent通用技能（含dbs系列21个） |
| `D:\_ai\skills\` | 7 | 专项技能（skill-review等） |
| `~/.claude/skills/` | 存在 | Claude Code bridge已建立 |
| `~/.grok/skills/` | ❌ 缺失 | 无Grok bridge |

### 问题诊断

1. **真源分散**: 三个独立skill目录(246+105+7=358个技能)，无统一真源
2. **无Claude兼容**: 缺少CLAUDE.md，Claude Code用户无法直接使用
3. **无Grok bridge**: 缺少Grok TUI支持
4. **命名不统一**: dbs系列在`.agents/skills/`，其他在`.codex/skills/`
5. **bridge策略缺失**: `~/.claude/skills/`存在但不确定是否薄bridge还是重副本

### 当前状态评级: 可运行但不可维护

---

## Phase 2-3: 分层层级建议

### 推荐架构

```
真源层 (Source of Truth):
  ~/.agents/skills/          ← 所有skill的真源（105个，含dbs 21个）
  
规则层:
  ~/.codex/AGENTS.md         ← 三端公共规则（已存在，需补充Claude兼容）
  ~/.codex/CLAUDE.md         ← Claude Code入口（新建，指向AGENTS.md）
  ~/.codex/SOURCE_OF_TRUTH.md ← 真源声明（新建）

Bridge层 (薄指针):
  ~/.codex/skills/           ← Codex bridge → 指向真源
  ~/.claude/skills/          ← Claude Code bridge → 指向真源
  ~/.grok/skills/            ← Grok bridge → 指向真源（新建）
```

### 问题：246个Codex技能如何处理？

当前`.codex/skills/`有246个目录，远超`.agents/skills/`的105个。其中大量baoyu/ljg系列技能可能是：
- 直接从外部安装的完整副本（不是bridge）
- 部分与`.agents/skills/`重叠

**建议**: 先不迁移246个技能，而是建立一个清晰的层级文档。后续按需将高价值技能从`.codex/skills/`迁移真源到`.agents/skills/`。

---

## Phase 4: 立即行动清单

### 最小迁移路径（可今天完成）

1. **创建 CLAUDE.md** — 薄指针指向AGENTS.md
2. **创建 SOURCE_OF_TRUTH.md** — 声明真源位置
3. **审计 dbs技能bridge状态** — 确认`~/.claude/skills/dbs*`是否为薄指针

### 后续优化（按需）

4. 生成Grok bridge（当用户需要使用Grok TUI时）
5. 逐步将`.codex/skills/`高价值技能迁移到`.agents/skills/`真源
6. 统一所有skil frontmatter命名规范
