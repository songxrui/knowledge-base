# skill-os Skill操作系统 | 总管理中心设计

> 使用skill: skill-os (所有skill的总管理中心——路由编排+生命周期+质量审计+自我进化)
> 对象: 当前35个已使用skill的生态管理
> 时间: 2026-06-08

---

## skill-os的5大职能

### 1. 路由编排
**当前**: dbs-orchestrator覆盖13/18路由(72%)
**目标**: 覆盖所有35个skill的精确路由
**方法**: 建立触发词→skill映射表, 消除语义猜测依赖

### 2. 生命周期管理
**阶段**: Draft → Alpha → Beta → GA
**当前分布**: ~7 GA / ~15 Beta / ~40 Alpha / ~200 Draft
**目标**: 核心30个skill全部达到Beta级

### 3. 质量审计
**工具链**: skill-overseer(监工) + compile-and-verify(编译验证) + content-truth-lock(真实性)
**周期**: 每周一次全量审计
**产出**: AUDIT_REPORT.md(自动生成)

### 4. 自我进化
**方法论**: SkillOpt手动循环(Rollout→Reflection→Edit≤4→Validation→Buffer→SlowUpdate)
**周期**: 每2周一次进化循环
**触发**: 匹配率下降/输出质量下降/调用频率下降

### 5. 知识沉淀
**当前**: 45个文件在_logs/, 按session组织
**目标**: 按dbs-content-system的5类单元组织(QST/CON/OPI/CAS/SOL)
**复利**: 每次分析都在积累可调用的知识单元

---

## skill-os与其他skill的关系

```
skill-os (总控)
├── dbs-orchestrator (路由)
├── skill-overseer (监工)
├── compile-and-verify (验证)
├── skill-review-master (评测排序)
├── skill-auditor (全生态审计)
├── skill-forge (新skill孵化)
├── dbs-agent-mesh (并行编排)
└── session-memory (跨session记忆, 待启用)
```

---

## 当前缺失(按优先级)

| 功能 | 状态 | 建议 |
|------|------|------|
| 调用频率统计 | ❌ 缺失 | 部署30天监控脚本 |
| 自动审计报告 | ⚠️ 手动 | 脚本化compile-and-verify |
| 折旧/淘汰机制 | ❌ 缺失 | 未使用>30天的skill自动标记 |
| 新skill孵化流程 | ⚠️ 有skill-forge但未实用 | 标准化孵化→测试→GA流程 |
