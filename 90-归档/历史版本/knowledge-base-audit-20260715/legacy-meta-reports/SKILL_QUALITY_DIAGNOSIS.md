# Skill 仓库质量诊断报告

> 2026-06-12 | 扫描 413 个真实 Skill | G1-G6 门禁批量审计

---

## 一、总体健康度

| 门禁通过数 | Skill 数 | 占比 | 评级 |
|-----------|---------|------|------|
| 6/6 全绿 | 45 | 10.9% | S — 可发布 |
| 5/6 | 86 | 20.8% | A — 良好 |
| 4/6 | 177 | 42.9% | B — 及格 |
| 3/6 | 83 | 20.1% | C — 需修复 |
| 2/6 | 21 | 5.1% | D — 严重 |
| 1/6 | 1 | 0.2% | F — 废弃级 |

**核心发现：仅 10.9% 的 Skill 通过全部 6 项门禁。51.6%（213个）存在至少 2 项缺陷。**

---

## 二、影响整体质量工程最大的 5 类病灶

### 病灶 1：重复 Skill（跨目录多副本）— 严重性：P0

| Skill 名 | 副本数 | 影响 |
|---------|--------|------|
| bun-runtime | 2 | 触发歧义 |
| frontend-patterns | 2 | 版本不一致风险 |
| everything-claude-code | 2 | 同名不同质 |
| dmux-workflows | 2 | 配置冲突 |
| backend-patterns | 2 | 语义重叠 |
| api-design | 2 | 过时版本共存 |
| security-review | 2 | 安全检查标准不一致 |
| coding-standards | 2 | 规范冲突 |
| canvas-design | 2 | 重复占用上下文 |
| mle-workflow | 2 | 冗余加载 |
| 其他 ~10 个 | 2 | 同上 |

**根因**：`~/.codex/skills/` 和 `~/.agents/skills/` 中同时存在相同 Skill。
**影响**：模型在选择 Skill 时不确定用哪个版本；不同版本的规则可能矛盾。

### 病灶 2：超大体积无结构 Skill（>20KB）— 严重性：P0

| Skill | 大小 | 缺什么 |
|-------|------|--------|
| hatch-pet | 36.5KB | 无步骤、无验证、无兜底 |
| playwright-interactive | 31.1KB | 同上 |
| quality-nonconformance | 30KB | 同上 |
| energy-procurement | 29.5KB | 同上 |
| customs-trade-compliance | 28.7KB | 同上 |
| humanizer | 27.7KB | 同上 |
| returns-reverse-logistics | 24.4KB | 同上 |
| scrapling | 23.4KB | 同上 |
| carrier-relationship-management | 23.4KB | 同上 |
| inventory-demand-planning | 24.1KB | 同上 |
| mle-workflow | 22.3KB | 同上 |
| windows-desktop-e2e | 30.5KB | 同上 |

**根因**：这些 Skill 把大量领域知识直接塞进 body，没有拆分 references/。
**影响**：每次触发加载 20-36KB 内容，挤占任务上下文；加载进来的内容大部分与当前任务无关。

### 病灶 3：描述与触发残缺 — 严重性：P1

**统计**：213 个 Skill（51.6%）在 G2（触发层）未通过或仅 WARN。

**典型病例**：
| Skill | 问题 |
|-------|------|
| tailored-resume-generator | 全英文 description，无中文触发词，无正反例，无边界 |
| agent-reach | description 含路由逻辑但缺"不适用场景"段 |
| geju | 中英混杂，触发词不明确 |
| strategic-compact | 有触发示例但 description 字段本身无结构化触发词列表 |

**影响**：模型在中文语境下无法准确触发这些 Skill——用户说中文但 Skill 只有英文触发词。

### 病灶 4：零验证零兜底 — 严重性：P1

**统计**：104 个 Skill（25.2%）缺少验证机制（G4=0），93 个 Skill（22.5%）缺少失败兜底（G5=0）。

**典型**：
- tailored-resume-generator：执行后无任何验证
- storage-analyzer：扫描失败时无降级方案
- agent-reach：17 平台中任一平台调用失败无兜底
- weread-exporter：扫码登录失败时无提示

**影响**：Skill 执行中卡死时模型无法自主恢复。

### 病灶 5：无步骤/无工作流 — 严重性：P2

**统计**：超过 200 个 Skill（~50%）没有编号步骤或分阶段工作流（G3=0）。

**典型**：agent-reach、storage-analyzer、geju、tailored-resume-generator 等全部缺少执行步骤。

**影响**：模型拿到 Skill 后不知道该按什么顺序做什么，自由发挥空间过大。

---

## 三、最影响整体质量的 15 个 Skill（优先级降序）

| # | Skill | GP | 大小 | 病灶 | 影响评分 |
|---|-------|----|------|------|---------|
| 1 | tailored-resume-generator | 1/6 | 12.5KB | G1-G5全FAIL | 10/10 |
| 2 | humanizer | 3/6 | 27.7KB | G1(超限)+G2(无中文触发)+G3(无步骤) | 9/10 |
| 3 | hatch-pet | 3/6 | 36.5KB | G1(严重超限)+G2+G3 | 9/10 |
| 4 | scrapling | 3/6 | 23.4KB | G1+G2+G3 | 8/10 |
| 5 | energy-procurement | 3/6 | 29.5KB | G1+G2+G3 | 8/10 |
| 6 | customs-trade-compliance | 3/6 | 28.7KB | G1+G2+G3 | 8/10 |
| 7 | quality-nonconformance | 3/6 | 30KB | G1+G2+G3 | 8/10 |
| 8 | agent-reach | 2/6 | 2.7KB | G2+G3+G4+G5 | 7/10 |
| 9 | storage-analyzer | 2/6 | 0.8KB | G2+G3+G4+G5 | 7/10 |
| 10 | skill-creator | 3/6 | 18.3KB | G1+G2+G5 | 7/10 |
| 11 | mcp-builder | 3/6 | 13.5KB | G1+G2+G5 | 6/10 |
| 12 | academic-paper-composer | 3/6 | 12.6KB | G1+G2+G5 | 6/10 |
| 13 | geju | 2/6 | 9KB | G2+G3+G4+G5 | 6/10 |
| 14 | weread-exporter | 3/6 | 0.8KB | G3+G4+G5 | 5/10 |
| 15 | context-compressor | 3/6 | 0.9KB | G3+G4+G5 | 5/10 |

**影响评分算法**：GP越低×体积越大×与用户核心工作流越相关 = 影响越高。
- 影响 ≥8：立即修复
- 影响 6-7：本轮修复
- 影响 4-5：下轮修复

---

## 四、修复路线图

### 立即执行（本轮）

**1. 去重**：合并 `~/.codex/skills/` 和 `~/.agents/skills/` 中的重复 Skill。
- 保留版本号更新的副本
- 旧版移入 `.archived/`
- 预计处理 ~15 对重复

**2. 超大 Skill 减肥**：12 个 >20KB 的 Skill 拆分 references/。
- 路径：body 保留核心定义+工作流（≤8KB），其余移入 references/

**3. G2 补全**：213 个 Skill 追加中文触发词+正反例+边界声明。

### 下轮执行

**4. G3-G5 补全**：给 200+ 个 Skill 追加步骤、验证和失败兜底。

### 后续

**5. 全量 R3 升级**：用 skill-forge 对 GP≤3 的 Skill 逐批升级。

---

## 五、质量工程度量基线

| 指标 | 当前值 | 目标值 |
|------|--------|--------|
| 6/6 全绿率 | 10.9% | ≥50% |
| 重复 Skill 数 | ~30 副本 | 0 |
| 超大 Skill (>20KB) | 12 个 | 0 |
| G2 通过率 | 48.4% | ≥90% |
| G4 验证覆盖率 | 74.8% | ≥95% |
| G5 兜底覆盖率 | 77.5% | ≥95% |

---

> 扫描工具: PowerShell G1-G6 批量审计脚本
> 扫描范围: 413 个真实 Skill（排除 7 个无 SKILL.md 的组织目录）
> 数据来源: C:\Users\董辉\.codex\skills\ + C:\Users\董辉\.agents\skills\ + C:\Users\董辉\.codex\.agents\skills\