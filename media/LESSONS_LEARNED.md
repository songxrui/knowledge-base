# 经验教训 — 本轮Skill内容产线的10条经验

> 产出方法: postmortem-solo (轻量复盘)  
> 对象: 本次session的完整工作流程

---

## 做得好的 (Keep)

### 1. 信源先行的策略
先接通weread和exa, 确认信源可用后再开始创作。这避免了"写完了发现没证据"的返工。

### 2. 核心链优先
先建dbs-content→khazix-writer→crosspost的主链路, 再向四周扩散。核心链路稳定后, 扩散才有了基础。

### 3. 每产出独立commit
51个commit每个都有明确的message和关联文件。这保证了完全可追溯, 不需要事后还原工作过程。

### 4. 反造假机制
心跳system-captured, commit messages无自述工时, 外部源全部可追溯。这是本轮最关键的工程纪律。

### 5. 外部验证先行
8个外部源(SkillsBench/OpenSkillEval等)交叉验证了核心发现。这使得内容从"我觉得"变成了"证据显示"。

---

## 需要改进的 (Change)

### 6. 管线并行化不足
42个变体中有20+个可以并行生成(ljg-card/ljg-plain/ljg-learn等无依赖关系)。串行执行浪费了时间。

**改进**: 下次建skill依赖图, 识别无依赖路径, 并行执行。

### 7. 缺少A/B测试
声称"22-skill管线产出质量高于单skill", 但没有做正式的A/B盲评。SkillsBench的论文方法可以借鉴。

**改进**: 下次在管线和单skill之间跑正式的A/B对比。

### 8. 未充分利用并行Agent
本轮是单Agent工作。如果dbs-content→khazix-writer完成后, 派3个并行Agent分别做深度分析/教学/工程, 时间可缩短60%。

**改进**: 下次探索multi-agent并行管线。

### 9. Feishu同步未完成
环境变量未配置导致飞书同步阻塞。这应该在session开始前就检查。

**改进**: session启动checklist加入"信源+API+环境变量"预检。

### 10. 内容深度不均
部分文件(如长篇分析)深度足够(10/10), 部分(如格式审计)偏流程(5/10)。

**改进**: 设定每条产出的最低质量标准(≥7/10), 低于则标记为"内部参考"而非"可发布"。

---

## 下轮行动

- [ ] 并行管线探索 (multi-agent)
- [ ] A/B测试管线 vs 单skill
- [ ] 飞书环境变量配置
- [ ] 对薄弱母题(商业/健康)补充内容
- [ ] 清理Draft级skill (删坏>建新)

---

> postmortem: 5 Keep + 5 Change + 下轮行动, 轻量复盘
