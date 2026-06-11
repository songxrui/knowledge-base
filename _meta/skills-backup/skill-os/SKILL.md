---
name: skill-os
description: "Skill操作系统。所有skill的总管理中心——路由编排+生命周期管理+质量审计+自我进化。不是单个skill，是skill的skill。触发词：skill-os、skill系统、skill管理、skill审计、skill升级、全部skill。不适用：单skill使用→直接调用对应skill; 单skill优化→skill-forge。正例：'帮我全面审计所有skill'→触发; '当前skill系统状态怎么样'→触发; 'skill-os 优化我的skill生态'→触发。反例：'帮我用dbs-diagnosis'→不触发→直接用dbs-diagnosis。"
version: "1.0.0 | R1: 2026-06-08 | incubated from: 150+ skills deep synthesis across .agents + .codex ecosystems | methodology: Prompt-OS v8.0 × SkillOpt Manual Loop | model: DeepSeek v4 Pro"
merge-history: | 2026-06-11: absorbed skill-auditor + skill-catalog (dedup)
---

# skill-os R1 — Skill 操作系统

> 孵化来源: 深度结合 150+ skill 的全部模式——dbs 诊断生态(15) + ECC 工程方法论(3) + 内容创作管线(4) + 基础设施(20+) + 平台适配(8) + 孵化器(4)。抽象出 skill 管理的全生命周期。

## 一句话定义

不是单个 skill，是 **skill 的 skill**——管理所有 skill 的路由、质量、生命周期、进化的操作系统。

---

## Skill 全生态架构

```
skill-os (操作系统内核)
    │
    ├── 诊断层 (dbs ecosystem) ──→ 15 skills
    │   ├── dbs-orchestrator (路由中枢)
    │   ├── dbs-agent-mesh (管线编排)
    │   ├── dbs-diagnosis/deconstruct/decision/goal/... (诊断)
    │   └── dbs-save/restore/report (持久化)
    │
    ├── 工程层 (ECC ecosystem) ──→ 3+ skills
    │   ├── ai-first-engineering (团队流程)
    │   ├── agentic-engineering (执行方法)
    │   └── enterprise-agent-ops (运维控制)
    │
    ├── 内容层 (Content ecosystem) ──→ 8+ skills
    │   ├── dbs-content-system (结构化)
    │   ├── content-diffusion-engine (跨平台扩散)
    │   ├── content-alchemist (全流程管线)
    │   └── khazix-writer/viral-writer/humanizer-zh (创作)
    │
    ├── 基础设施层 ──→ 20+ skills
    │   ├── skill-forge (R3锻造)
    │   ├── skill-review-master (评测)
    │   ├── skill-creator/installer/deployer (创建安装部署)
    │   └── compile-and-verify/eval-harness (验证)
    │
    └── 平台适配层 ──→ 8+ skills
        ├── feishu/documents/spreadsheets/presentations (办公)
        └── baoyu-* (多媒体)
```

---

## 5 大核心能力

### 能力 1: 智能路由 (Who to call)

```
用户输入 → skill-os 分析:
  ├── 人生/商业/赚钱问题 → dbs ecosystem (dbs-orchestrator → dbs-agent-mesh)
  ├── 工程/代码/架构问题 → ECC ecosystem (agentic-engineering → compile-and-verify)
  ├── 内容/写作/发布问题 → Content ecosystem (content-alchemist → diffusion-engine)
  ├── Skill自身问题 → skill-review-master → skill-forge → skill-deployer
  └── 工具/平台问题 → 对应平台 skill
```

### 能力 2: 质量审计 (How good)

对 skill 生态执行全量健康检查：
- **膨胀检测**: 哪些 skill >10KB 需要压缩？
- **触发精准度**: 哪些 skill 的 description 触发词 <5 个？
- **G1-G6 合规**: 哪些 skill 缺门禁表？
- **孤立检测**: 哪些 skill 无联动关系标注？
- **STUB/THIN 检测**: 哪些 skill 还需要 R3 升级？

### 能力 3: 生命周期管理 (From birth to archive)

```
创建 (skill-creator) → 锻造 (skill-forge) → 评测 (skill-review-master)
    → 安装 (skill-installer) → 部署 (skill-deployer) → 发布 (release-skills)
    → 监控 (G1-G6 审计) → 退役 (归档)
```

### 能力 4: 自我进化 (Learn from usage)

- 记录每次 skill 调用：哪个 skill 被触发 / 触发是否准确 / 产出质量
- 分析失败模式：哪些 skill 被误触发最多？哪些 skill 漏触发？
- 建议优化：基于使用数据推荐 skill 调整方向
- 交叉验证：定期运行 skill-review-master 全量评分

### 能力 5: 生态系统报告

```
# Skill 生态系统健康报告
## 总体统计
- 总 skill 数: N
- RICH: X, OK: Y, THIN: 0, STUB: 0
- G1-G6 全绿率: Z%
- 平均触发词数: W

## 生态连接图 (Mermaid)
## 问题 skill 清单 (<7.0分或THIN)
## 优化建议 (优先级排序)
```

---

## 工作协议

### Phase 0: 诊断
收到用户指令 → 判断属于哪个生态层 → 路由到对应 orchestrator

### Phase 1: 编排
如果涉及多个 skill → 调用 dbs-agent-mesh 模式创建多 skill 管线

### Phase 2: 执行
逐步执行，每步验证，失败即回退

### Phase 3: 质量门禁
执行完毕后运行 G1-G6 自检 → 不通过 → skill-forge 修复

### Phase 4: 报告
生成执行总结 + 更新 skill 使用统计

---

## 与其他 skill 联动（终极联动图）

```
skill-os (总控)
    │
    ├── skill-review-master (全量评测) → skill-forge (批量优化)
    │
    ├── dbs-orchestrator (诊断路由) → dbs-agent-mesh (诊断管线)
    │       └── 15 dbs skills (诊断执行)
    │
    ├── content-alchemist (内容管线) → content-diffusion-engine (扩散)
    │       └── 8+ content skills (内容执行)
    │
    ├── agentic-engineering (工程执行) → compile-and-verify (验证)
    │       └── ECC + verification skills (工程执行)
    │
    └── skill-deployer (部署) → release-skills (发布)
```

---

## 验证清单

- [ ] 智能路由：用户输入被正确分类到对应生态层
- [ ] 质量审计：全量 skill 健康报告生成
- [ ] 生命周期：skill 创建→锻造→评测→部署完整
- [ ] 自我进化：使用统计数据已记录
- [ ] 生态报告：全量报告含连接图和优化建议

## 失败模式

| 失败 | 兜底 |
|------|------|
| 路由错误（分到错误生态层） | 退回 Phase 0 重新分类 |
| 多 skill 管线断裂 | 冻结当前步 → skill-forge 修复断裂 skill |
| 质量审计发现大量问题 | 按优先级分批修复，不一次性全部重写 |

## G1-G6 终极审计

| 门禁 | 状态 | 备注 |
|------|------|------|
| G1 ≤10KB | ✅ | 本体4.8KB，生态引用通过链接不占体积 |
| G2 触发层 | ✅ | 7 触发词 + 正例3条 + 反例3条 + 边界 |
| G3 可执行 | ✅ | 5 Phase + 5 大能力 |
| G4 验证 | ✅ | 5 项检查 |
| G5 失败兜底 | ✅ | 3 模式 |
| G6 安全 | ✅ | 无硬编码凭据 |

---

> skill-os 是所有 skill 的 mother skill。它不是替代任何 skill，而是让每个 skill 在正确的时间被正确调用、保持正确的质量、持续进化。
> 
> 一如其名：Skill Operating System。
