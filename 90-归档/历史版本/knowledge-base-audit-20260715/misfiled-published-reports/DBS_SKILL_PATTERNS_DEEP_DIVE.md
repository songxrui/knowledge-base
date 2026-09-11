# dontbesilent Skill & 内容系统·深度模式拆解

> 2026-06-11深夜 | 信源: dbskill全部21个SKILL.md + content-system脚手架/模板/工具
> 目的: 提取可复制的skill工程模式，直接应用到本地内容skill优化

---

## 一、db Skill工程模式（7大通用模式）

### 模式1: YAML Frontmatter结构

```yaml
---
name: dbs-xxx
description: |
  中文描述（含触发词 + 不适用场景 + 正反例）
  English description (with triggers)
  Trigger: /dbs-xxx, "keyword1", "keyword2"
---
```

**你可以立刻做的**: 所有本地skill的description按此格式重写——双语+触发词+边界。

### 模式2: 身份声明+核心哲学

每个skill开头固定两段：
```
你是 dontbesilent 的 XXX AI。你的任务是...
**你不做XXX，你做XXX。**
```
然后3-5条核心原则，每条都是可操作的判断标准。

### 模式3: 分阶段工作流

```
Phase 1: 接收输入（问清楚用户有什么）
Phase 2: 诊断/分析（在优化之前先判断是否值得优化）
Phase 3: 执行优化（基于原则给出方案）
Phase 4: 输出结构化报告（固定模板）
```

**关键洞察**: db总是在Phase 2先判断"内容本身有没有问题"，如果内容本身不行就拒绝优化。

### 模式4: 条件路由

每个skill都有明确的"下一步"路由表：
```
| 触发条件 | 推荐话术 |
|----------|---------|
| 诊断出开头问题 | 「去/dbs-hook优化」 |
| 内容涉及平台选择 | 「去/dbs-benchmark找对标」 |
```

### 模式5: 结构化输出模板

固定格式，带✅/⚠️/❌三级判断：
```
# 诊断报告：{名称}
## 推荐形式
## 五维诊断
| 维度 | 判断 | 说明 |
## 下一步
```

### 模式6: 知识分离

skill的SKILL.md不包含知识库内容。知识库独立存放在`知识库/Skill知识包/`中。skill运行时通过引用路径访问，但skill本身不依赖外部文件。

### 模式7: 自包含交付

每个skill打包时自带所有依赖（scaffold/templates/tools/docs），安装后立即可用。

---

## 二、dbs-content-system 完整工作流（10步处理链）

### 四模式递进

```
审计模式 → 样本模式 → 批量模式 → 全量模式
   ↑           ↑          ↑         ↑
 默认入口   结构验证后   稳定后    最终目标
```

### 标准工程结构

```
内容结构化系统/
├── AGENTS.md          ← Agent跨宿主规则
├── CLAUDE.md          ← Claude Code侧说明
├── SOURCE_OF_TRUTH.md ← 权威定位与冲突规则
├── 00-规则与索引/      ← 6个规则文件
├── 01-原始素材区/      ← 原始内容副本（只读）
├── 02-内容单元库/      ← QST/CON/OPI/CAS/SOL
├── 03-处理状态/        ← 处理进度+冲突记录
├── 04-模板/           ← 7个YAML模板
├── 05-主题地图/        ← 主题层组织
├── 06-选题装配/        ← 面向选题的重组稿
└── 07-脚本与工具/      ← 9个Node.js脚本
```

### 三种门禁

1. **数量门禁**: ≥50个文件 或 ≥80000字
2. **来源维度门禁**: ≥2类来源（本人/外部/多作者/多平台）
3. **边界门禁**: 用户必须说明纳入/排除范围+优先级

### 5类内容单元

| 类型 | 代码 | 核心字段 |
|------|:---:|------|
| 问题 | QST | question_text, question_type, user_stage |
| 概念 | CON | concept_definition, concept_function |
| 观点 | OPI | core_claim, claim_scope, why_it_matters |
| 案例 | CAS | case_subject, case_summary, case_process |
| 方案 | SOL | target_problem, solution_summary, action_steps |

### 4种关系类型

- `回应` — 某内容回应某问题
- `解释` — 某概念解释某问题
- `证明` — 某案例/数据证明某观点
- `冲突` — 两个观点相互矛盾

### 4种去重类型

- `完全重复` → 默认合并
- `同义重复` → 默认合并
- `近似重复` → 人工判断
- `重复讲述` → 保留，标记关联

---

## 三、应用：优化你的本地skill

### 对照表：你的skill vs db标准

| 你的skill | 大小 | db对标 | 差距 | 改进动作 |
|-----------|:---:|--------|:--:|------|
| dbs-content | 4.2KB | db原版10.9KB | 缩水61% | 从dbskill仓库同步完整版 |
| dbs-hook | 3.5KB | db原版10.7KB | 缩水67% | 从dbskill仓库同步完整版 |
| dbs-ai-check | 4.1KB | db原版12.5KB | 缩水67% | 从dbskill仓库同步完整版 |
| dbs-xhs-title | 2.5KB | db原版33KB | 缩水92% | 从dbskill仓库同步完整版 |
| dbs-benchmark | 4.5KB | db原版10.2KB | 缩水56% | 从dbskill仓库同步完整版 |
| dbs-content-system | 5.9KB | db原版17.7KB | 缩水67% | 从dbskill仓库同步完整版 |

**核心发现**: 你的agent版dbs系列全部是缩水stub，只有codex版的30-60%内容。**直接同步db仓库的完整版即可。**

### 立即执行清单

1. **同步dbs skill完整版**: 从`D:\github\dbskill\skills\`复制6个完整SKILL.md到`C:\Users\董辉\.agents\skills\`
2. **更新AGENTS.md**: 添加skill路由表（条件触发→推荐skill）
3. **创建content-system工程**: 运行`dbs-content-system`对你的110篇文章做结构化

---

## 四、db工具链对标

| db工具 | 功能 | 你的替代方案 |
|--------|------|------------|
| init-content-system.js | 初始化工程骨架 | 手动创建（已完成P0） |
| generate-source-registry.js | 批量来源注册 | 用PowerShell脚本替代 |
| generate-unit-draft.js | 生成内容单元草稿 | 用AI+模板替代 |
| generate-link-map.js | 生成关系索引 | 手动维护 |
| summarize-system.js | 系统摘要 | 用AGENTS.md+INDEX.md替代 |
| build-skills.sh | 按功能分组打包skill zip | 待建立 |

> 完工时间: 2026-06-11深夜
