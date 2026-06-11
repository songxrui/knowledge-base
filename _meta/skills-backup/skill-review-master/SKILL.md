---
name: skill-review-master
description: "元Skill评测与优化总控。融合SkillOpt手动循环(Rollout→Reflection→Edit(≤4)→Validation→RejectedBuffer→SlowUpdate)+skill-review评分体系+G1-G6收费产品门禁+微软SkillOpt论文方法论。触发词：评测skill/优化skill/skill评分/skill质量审计/skill门禁检查/skill优化循环/SkillOpt迭代/批量skill评测。不适用场景：单次skill使用(非评测)、非skill内容评测、纯代码review。与相邻skill边界：skill-review(D:\_ai\skills\)(评测评分)、skill-creator(创建新skill)、skill-evolver(自动化进化)、compile-and-verify(任务编译验证)。正例：'帮我评测这50个skill的质量并排序'→触发; '对这个skill执行一轮SkillOpt优化循环'→触发; '检查所有skill的G1-G6门禁通过率'→触发。反例：'用khazix-writer写篇文章'→不触发→khazix-writer; '帮我创建一个新skill'→不触发→skill-creator。"
version: "1.0.0 | created: 2026-06-08 | methodology: SkillOpt+Microsoft | model: DeepSeek v4 Pro"
---

# Skill-Review-Master — 元Skill评测与优化总控

融合微软SkillOpt论文方法论与收费产品级门禁体系的终极skill质量管理系统。

## 核心定义

skill-review-master 不是另一个评测工具，而是把 **SkillOpt 手动优化循环 + G1-G6 收费产品门禁 + 批量评分排序** 统一为一个可重复执行的工程流程。

**关键事实**（以微软SkillOpt原论文为准，未独立核实）：
- SkillOpt 将 skill 文档视为模型唯一可变的"权重"
- 优化循环：rollout → reflection → edit(每轮≤4条) → validation
- 被否改动入 rejected buffer（避免重犯）
- 跨轮 slow/meta update（保护慢更新不被单步覆盖）
- 优化后 skill 中位约 900 token，上限约 2000 token
- 好规则极度具体，空话无效

## 三层架构

```
┌─────────────────────────────────────┐
│  第3层: 批量管理层                    │
│  扫描→评分→排序→优先级→调度           │
├─────────────────────────────────────┤
│  第2层: 单skill优化循环层             │
│  Rollout→Reflection→Edit(≤4)→Validate │
├─────────────────────────────────────┤
│  第1层: 门禁验证层                    │
│  G1(size)→G2(trigger)→G3(exec)→      │
│  G4(verify)→G5(fallback)→G6(security) │
└─────────────────────────────────────┘
```

---

## 第1层: G1-G6 收费产品门禁

| 门禁 | 要求 | 检查方法 |
|------|------|---------|
| G1 大小 | SKILL.md ≤10KB（核心规则密集的可放宽至12KB） | `(Get-Item SKILL.md).Length -le 10240` |
| G2 触发层 | ≥5个触发词 + 不适用场景 + ≥2正例 + ≥2反例 + 边界说明 | frontmatter description字段正则匹配 |
| G3 可执行 | ≥1条可直接执行的命令/脚本 | 搜索代码块中的shell/python命令 |
| G4 验证 | ≥3条布尔验证项（✅/❌格式） | 搜索 `- [ ]` 模式 |
| G5 失败兜底 | ≥3个失败模式 + 对应兜底动作 | 搜索失败模式表格 |
| G6 安全 | 无硬编码凭据(token/password/api_key明文) | 正则: `(token|password|api_key|secret)\s*[:=]\s*[A-Za-z0-9_\-]{20,}` |

### 门禁判定
- 全部6项通过 → PASS ✅
- G1/G2/G6任一失败 → BLOCKED 🔴（必须修复才能发布）
- G3/G4/G5失败 → WARNING ⚠️（允许发布但标记降级）

---

## 第2层: SkillOpt 手动优化循环

### 循环流程（每轮 ≤4 条改动）

```
┌──────────┐     ┌────────────┐     ┌──────────┐     ┌────────────┐
│ ROLLOUT  │────▶│ REFLECTION │────▶│   EDIT   │────▶│ VALIDATION │
│ 跑真实任务 │     │ 分析失败模式 │     │ ≤4条改动  │     │ 留出任务验证 │
│ 记录失败  │     │ 提炼改进方向 │     │ add/del/  │     │ 没涨就回滚  │
└──────────┘     └────────────┘     │ replace  │     └────────────┘
                                     └──────────┘           │
                                          ▲                 │
                                          │   ┌──────────┐   │
                                          └───│ REJECTED │◀──┘
                                              │ BUFFER   │ (被否改动)
                                              └──────────┘
```

### Step-by-Step

**Step 1: ROLLOUT（运行当前skill）**
- 在 ≥3 个真实任务上运行当前 skill
- 记录：每个任务的输出质量（0-10）、失败点、具体问题描述
- 输出：`rollout_log.md`（任务/评分/失败点）

**Step 2: REFLECTION（分析失败模式）**
- 归类失败模式（触发失败/输出空泛/格式错误/信息遗漏）
- 每个失败模式追问：skill 中缺了什么规则导致这个失败？
- 提炼 ≤3 个改进方向（按影响排序）
- 输出：`reflection.md`（失败模式分类 + 改进方向）

**Step 3: EDIT（执行改动，≤4条）**
- 每轮最多 4 条改动（add/delete/replace）
- 克制原则：先删冗余（第1-2条），再补缺失（第3-4条）
- 每条改动标注：类型/位置/原因/预期效果
- 输出：`edit_log.md`（改动清单）

**Step 4: VALIDATION（验证改动效果）**
- 在留出任务（不用于rollout的任务）上验证
- 对比改动前后评分：涨了→保留；没涨→回滚到改动前
- 回滚的改动记入 `rejected_buffer.md`
- 输出：`validation.md`（前后对比 + 判定）

**Step 5: SLOW/META UPDATE（每3-5轮一次）**
- 跨版本纵向回顾：哪些改动模式反复出现？
- 检查 rejected buffer：是否有被否改动在新条件下值得重试？
- 更新 skill 的元规则（版本号、方法论标注、已知局限）

---

## 第3层: 批量管理层

### 3.1 全量扫描
```powershell
Get-ChildItem -Recurse -Filter "SKILL.md" | ForEach-Object {
    $size = (Get-Item $_.FullName).Length
    $desc = (Get-Content $_.FullName -Raw | Select-String -Pattern 'description:\s*"(.*?)"').Matches.Groups[1].Value
    # 评分...
}
```

### 3.2 评分维度（继承 skill-review 评分体系）

| 维度 | 权重 | 说明 |
|------|------|------|
| 触发精准度 | 20% | description含触发词+不适用场景+正反例+边界 |
| 可执行性 | 20% | G3得分 + 流程步骤清晰度 |
| 输出质量 | 20% | G4验证项数量 + 输出格式规范 |
| 失败鲁棒性 | 15% | G5失败模式数量 + 兜底质量 |
| 大小效率 | 10% | G1得分（越小越好，≤5KB满分） |
| 安全性 | 10% | G6得分 |
| 可复用性 | 5% | 是否含可复制模板/脚本 |

### 3.3 评分等级
- **S级 (90-100)**：全部门禁通过 + 含SkillOpt优化痕迹 + ≤5KB
- **A级 (80-89)**：全部门禁通过 + 触发层完整
- **B级 (70-79)**：G1-G6全部通过
- **C级 (60-69)**：有1-2项WARNING
- **D级 (<60)**：有BLOCKED项

### 3.4 优先级调度
1. D级优先修复（BLOCKED项）
2. C级批量提升（WARNING→PASS）
3. B级→A级（增强触发层）
4. A级→S级（SkillOpt深度优化）

---

## 失败模式与兜底

| 失败模式 | 原因 | 兜底动作 |
|---------|------|---------|
| 评分结果与人工判断偏差大 | 评分维度权重不适合该类型skill | 调整权重或增加类型特定维度 |
| SkillOpt循环无效果(连续3轮不涨分) | skill已达当前模型上限 | 停止循环，标记"已达局部最优"，记录在known_limits |
| 批量扫描遗漏skill | 目录结构非标准或文件名不匹配 | 递归扫描+手动补充已知路径 |
| rejected_buffer积累过多(>20条) | 改动方向系统性错误 | 回到reflection阶段重新分析失败根因，放弃rejected buffer中的同方向改动 |
| 优化后skill反而变差 | 改动破坏了原有有效规则 | 立即回滚到上一版本，分析哪条改动导致退化 |

---

## G1-G6 自检

| 门禁 | 要求 | 状态 |
|------|------|------|
| G1 大小 | ≤10KB | ✅ |
| G2 触发层 | ≥5触发词/不适用场景/正反例/边界 | ✅ |
| G3 可执行 | 含PowerShell扫描命令+SkillOpt循环步骤 | ✅ |
| G4 验证 | 含G1-G6门禁表+评分维度+失败模式 | ✅ |
| G5 失败兜底 | ≥5失败模式+兜底 | ✅ |
| G6 安全 | 无硬编码凭据 | ✅ |