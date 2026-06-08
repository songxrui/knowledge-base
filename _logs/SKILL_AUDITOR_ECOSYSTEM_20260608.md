# skill-auditor 全生态审计 | 版本控制+完整性+有效性

> 使用skill: skill-auditor (全Skill生态审计)
> 审计范围: 当前正在使用的content skill生态
> 时间: 2026-06-08

---

## 版本控制审计

| 目录 | Skill数 | 有git | 覆盖率 | 评级 |
|------|---------|-------|--------|------|
| .agents/skills | ~90 | 100%有git(根repo) | 100% | ✅ |
| .codex/skills | 263 | ~8个独立git | ~3% | ❌ |

**建议**: .codex/skills统一纳入根repo管理

---

## 产品完整性审计

| 等级 | 数量(估计) | 代表 | 问题 |
|------|----------|------|------|
| GA级(7种文件) | ~7 | skill-overseer | 极少 |
| Beta级(5-6种) | ~15 | dbs-content, humanizer-zh | 缺tests |
| Alpha级(3-4种) | ~40 | most content skills | 缺examples/tests |
| Draft级(1-2种) | ~200+ | most .codex/skills | 只有SKILL.md |

---

## 触发有效性审计

| 指标 | 估计值 | 来源 |
|------|--------|------|
| 有明确触发词的skill | ~25% | 基于"description含触发词"标准 |
| 有正反例的skill | ~15% | 基于description结构 |
| 有不适用场景的skill | ~10% | 最容易被忽略的字段 |

---

## 功能重叠审计

| 重叠对 | 重叠度 | 建议 |
|--------|--------|------|
| dbs-content vs content-auditor | 中(都涉及"诊断") | 保留, 定位不同(诊断vs审计) |
| khazix-writer vs viral-writer | 中(都涉及"写作") | 保留, 风格不同(长文vs多平台) |
| humanizer-zh vs dbs-ai-check | 高(都涉及"AI检测") | 合并或明确分工 |
| knowledge-forge vs content-alchemist | 中(都涉及"管线") | 保留, 粒度不同(锻造vs全流程) |

---

## 审计建议

1. **P0**: 合并humanizer-zh和dbs-ai-check的功能重叠
2. **P1**: .codex/skills纳入版本控制
3. **P2**: 核心30个skill补充examples/tests
4. **P3**: 10%有"不适用场景" → 目标是50%
