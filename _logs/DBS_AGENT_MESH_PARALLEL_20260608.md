# dbs-agent-mesh 多Agent管线编排 | 内容创作并行化方案

> 使用skill: dbs-agent-mesh (管线编排, 将串行skill改为并行)
> 当前: 单模型串行, 每step 1-2min
> 目标: 多Agent并行, 效率2-3x
> 时间: 2026-06-08

---

## 当前串行管线

```
[weread拉数据] → [dbs-content-system结构化] → [khazix-writer创作] → [humanizer-zh去味] → [content-auditor审计]
    2min               3min                        5min                  2min                 3min
                                                                                总: ~15min/篇
```

---

## 并行化方案(3 Agent)

### Agent 1: 信源Agent
**任务**: 拉取weread划线 + exa验证 + 结构化
**Skill**: weread-skills, exa-search, dbs-content-system
**输入**: 选题/关键词
**输出**: 结构化的5类单元(QST/CON/OPI/CAS/SOL)

### Agent 2: 创作Agent
**任务**: 基于结构化单元生成正文
**Skill**: khazix-writer, viral-writer, ljg-plain
**输入**: 结构化单元
**输出**: 多平台版本(微信/小红书/抖音)

### Agent 3: 审计Agent
**任务**: 质量检查 + AI味检测 + 验证
**Skill**: humanizer-zh, content-auditor, compile-and-verify, content-truth-lock
**输入**: 创作Agent的输出
**输出**: 通过/返工 + 具体修改建议

---

## 并行时序

```
时间轴 →

Agent1: [weread(2min)] → [structure(3min)] ──────────────┐
                                                          ├→ Agent2接收
Agent2:                     等待中...          [write(5min)] → [多平台(2min)]
                                                                        ├→ Agent3接收  
Agent3:                                       等待中...          [audit(3min)] → 放行/返工

总时间: 串行15min → 并行~10min (节省33%)
```

---

## 当前限制

| 限制 | 影响 | 解决方案 |
|------|------|---------|
| Codex multi-agent需手动触发 | 无法全自动并行 | 手动分3步启动 |
| Agent间无共享内存 | 需手动传递结构化单元 | 用文件作为Agent间通信 |
| 3个Agent可能产生不一致 | 审计Agent纠错 | content-truth-lock交叉验证 |

---

## 实施建议

1. **Phase 1**: 先拆为2个Agent(信源+创作合并, 审计独立) — 降低复杂度
2. **Phase 2**: 验证2 Agent方案效率后, 拆为3 Agent
3. **Phase 3**: 引入session-memory实现Agent间共享上下文
