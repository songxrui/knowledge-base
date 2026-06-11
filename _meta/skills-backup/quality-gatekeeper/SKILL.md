---
name: quality-gatekeeper
description: "统一质量门禁。组合humanizer-zh(去AI味)+compile-and-verify(任务验证)+content-auditor(发布审计)+禁用词扫描+平台规则校验。触发词：质量门禁/终审/发布前最终检查/gate check/能发了吗。与content-auditor互补：content-auditor侧重内容审计流程，quality-gatekeeper侧重布尔门禁(只判通过/不通过)。正例：'发布前过一遍质量门禁'→触发。"
version: "1.0.0 | created: 2026-06-08 | synthesized from: humanizer-zh+compile-and-verify+content-auditor"
merge-history: | 2026-06-11: absorbed content-auditor (dedup)
---

# Quality-Gatekeeper — 统一质量门禁

**不诊断、不建议、不修改。只判定：通过 / 不通过。**

## 门禁层（3关）

### 关1: 语言质量
- 5维AI味扫描(humanizer-zh): 均分≥3.5?
- 禁用词扫描(PowerShell正则): 零命中?
- 平台策略匹配: 符合目标平台?

### 关2: 任务完成度
- 目标达成(compile-and-verify): 全部量化目标达成?
- 信息完整: 关键字段/步骤无遗漏?
- 无幻觉: 数据/引用可回溯?

### 关3: 发布就绪
- 平台规则: 字数/格式/标签合规?
- 来源追溯: 每个数据点有出处?
- 终审通读: 全文流畅无断点?

---

## 判定输出

```
## 质量门禁报告

### 关1: 语言质量
- 5维均分: X/5 → ✅/❌
- 禁用词: X处 → ✅/❌
- 平台策略: → ✅/❌

### 关2: 任务完成度
- 目标达成: X/Y → ✅/❌
- 信息完整: → ✅/❌
- 无幻觉: → ✅/❌

### 关3: 发布就绪
- 平台规则: → ✅/❌
- 来源追溯: → ✅/❌
- 终审通读: → ✅/❌

### 最终判定
✅ 全部通过 — 可发布
❌ X关不通过 — 禁止发布，返回修复
```

---

## 与其他 skill 关系
- 不如 humanizer-zh 细腻(不提供改写建议)
- 不如 content-auditor 全面(不做深度审计)
- 比两者都快(纯布尔判定，适合频繁调用)

## G1-G6
| 门禁 | 状态 |
|------|------|
| G1 ≤10KB | ✅ |
| G2 触发层 | ✅ |
| G3 可执行(3关布尔) | ✅ |
| G4 验证(门禁报告) | ✅ |
| G5 失败兜底(3关细化) | ✅ |
| G6 安全 | ✅ |