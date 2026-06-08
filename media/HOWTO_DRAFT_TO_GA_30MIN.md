# 实操指南 — 如何在30分钟内把你的Skill从Draft升级到GA

> 产出方法: article-writing (how-to guide format) × dbs-deconstruct × SkillsBench数据  
> 目标受众: 已有skill但不知道如何升级的AI工具使用者  
> 格式: 操作指南, 5步, 每步有时间估算

---

## 背景: 为什么你需要升级skill

SkillsBench (arXiv 2602.12670): 精选skill平均提升+16.2pp通过率，但自生成skill平均退化–1.3pp。

OpenSkillEval (arXiv 2605.23657): **选错skill不如不用skill**。最差skill拖累性能0.28分。

你的Draft级skill不只是"没帮助"——它可能让Agent表现更差。

---

## Step 1: 5分钟 — 补触发词

**操作**: 在SKILL.md的description字段加入4-8个精准触发词 + 不适用场景 + 2正例2反例

```yaml
description: "技能描述。触发词: 具体词1/词2/词3。不适用: 场景A→用X skill; 场景B→用Y skill。正例: '用户会说X'→触发; '用户会说Y'→触发。反例: '用户会说A'→不触发→用Z skill"
```

**验证**: dbs-orchestrator实测，补齐25个skill触发词后自动匹配率 47%→81%

**Anthropic说**: "Pay special attention to the name and description of your skill. Claude will use these when deciding whether to trigger"

---

## Step 2: 5分钟 — git init + 初始commit

**操作**:
```bash
cd your-skill-directory
git init
git add -A
git commit -m "init: [skill name] v1.0 — [一句话描述]"
```

**为什么**: .agents目录127个skill, 100%有git; .codex目录245个skill, 3.3%有git。差距只在一条5秒规则。

**Anthropic说**: Skills是"version them with Git"的文件系统。没有git = 不可追溯 = 不可信任。

---

## Step 3: 10分钟 — 用2-3个精准模块替代长文档

**SkillsBench核心发现**: "Focused Skills with 2-3 modules outperform comprehensive documentation"

**操作**: 
- 如果你的SKILL.md超过5000字 → 拆分为 SKILL.md (核心流程, 500-2000字) + references/ (细节)
- 保留2-3个高频使用模块，删掉不常用的
- 代码 > 文字说明: 把"先搜索、再提取、再总结"写成可执行脚本而不是文字描述

**Anthropic说**: "Code execution > inline instructions" — 脚本执行只消耗输出token，不消耗上下文

---

## Step 4: 5分钟 — 建立验证机制

**操作**: 创建 `tests/` 目录，放2-3个测试用例:
```markdown
# test-01: 基本功能
输入: [具体输入]
期望输出: [具体输出]
通过条件: [可验证标准]
```

**为什么**: SkillsBench证明，没有验证机制的skill无法判断是否有效。19%的skill带来负面效果。

**必须**: 至少1个正向测试（skill应该处理的）和1个边界测试（skill不应该处理的）

---

## Step 5: 5分钟 — 建CHANGELOG + EVIDENCE

**操作**:
```
# CHANGELOG.md
## v1.0 (2026-06-08)
- 初始版本
- 触发词: [list]
- 模块: [list]
- 测试: 2/2 pass

# EVIDENCE.md
- git commit: [hash]
- 关联审计: skill-overseer verify-delivery.ps1
```

**为什么**: 三个月后你还能记得这个skill改过什么。别人也能追溯。

---

## 总耗时: 30分钟

| Step | 时间 | 动作 |
|------|:---:|------|
| 1 触发词 | 5min | description字段重写 |
| 2 git | 5min | git init + commit |
| 3 模块精简 | 10min | 砍长文档, 保留2-3核心模块 |
| 4 验证 | 5min | 创建tests/ + 2-3用例 |
| 5 记录 | 5min | CHANGELOG + EVIDENCE |

---

## 验收标准

完成这5步后，你的skill达到:
- ✅ Agent能发现它 (触发词)
- ✅ 你能追溯它的变化 (git)
- ✅ 它不会太长导致上下文污染 (2-3模块)
- ✅ 你能验证它是否有效 (tests)
- ✅ 别人能理解它的演变 (CHANGELOG)

这就是从Draft到GA的最小可行路径。

---

> 数据来源: Anthropic Engineering Blog (2025-12), SkillsBench (arXiv 2602.12670), OpenSkillEval (arXiv 2605.23657), skill-overseer v1.1.0
