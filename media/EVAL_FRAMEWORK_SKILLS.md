# 评估框架 — Skill质量评测体系设计

> 产出方法: eval-harness (评估驱动开发)  
> 目标: 设计可复用的Skill质量评测框架
> 参考: SkillsBench (7,308条轨迹) + OpenSkillEval (677案例)

---

## 评测维度 (5维)

### D1: 可发现性 (Discovery) — 权重30%
**测量**: Skill是否能在正确时机被Agent召回
**方法**: 
- 准备20个任务描述, 其中10个应该触发目标skill, 10个不应该
- 运行3次取平均值
- 指标: Precision(不该触发时不触发) / Recall(该触发时触发) / F1

**参考**: SkillRouter论文 — 路由精度可量化测量

---

### D2: 输出质量 (Quality) — 权重25%
**测量**: Skill产生的输出是否优于baseline(无skill)
**方法**:
- A/B测试: 同一任务, 有skill vs 无skill
- 3人盲评打分(1-10)
- 指标: Δ = 有skill平均分 - 无skill平均分

**参考**: SkillsBench — curated +16.2pp, self-gen -1.3pp

---

### D3: Token效率 (Efficiency) — 权重20%
**测量**: Skill消耗的token是否合理
**方法**:
- 记录每次调用的input/output token
- 对比: 同任务, 有skill vs 无skill的token消耗
- 指标: Token ROI = 质量Δ / 额外token消耗

**参考**: Anthropic progressive disclosure — metadata ~50t, body ~500t

---

### D4: 可维护性 (Maintainability) — 权重15%
**测量**: Skill的工程质量
**方法**:
- 7文件门禁检查(pass/fail)
- Git commit数(越多越好, 说明在迭代)
- CHANGELOG完整性(有/无)

**参考**: Anthropic — "version them with Git"

---

### D5: 安全性 (Security) — 权重10%
**测量**: Skill是否存在安全风险
**方法**:
- 10项安全检查清单(pass/fail)
- 硬编码密钥检测(正则扫描)
- 外部API调用声明(有/无)

**参考**: security-review skill 10风险矩阵

---

## 综合评分公式

```
Skill Score = D1×0.30 + D2×0.25 + D3×0.20 + D4×0.15 + D5×0.10

等级:
≥9.0 → GA (产品级)
7.0-8.9 → Beta
5.0-6.9 → Alpha
<5.0 → Draft
```

---

## 最少可行评测集 (MVP Eval Set)

不需要对147个skill全部跑5维评测。先用10个任务做MVP:

**任务设计**:
1. "帮我优化这个公众号文章的开头" → 应触发 dbs-hook
2. "这个选题适合小红书吗" → 应触发 viral-writer
3. "翻译这段文字" → 不应触发内容skill, 应触发 translate
4. "帮我写一篇关于AI的文章" → 应触发 khazix-writer
5. "这个skill的description怎么写" → 应触发 compile-and-verify
... (共10个)

**运行**: 每任务跑3轮, 记录: 触发了哪个skill, 输出质量, token消耗

**产出**: SKILL_EVAL_REPORT.md

---

> eval-harness方法: 5维×权重→综合评分→MVP评测集→运行→报告
