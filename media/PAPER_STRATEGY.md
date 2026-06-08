# 学术论文策略 — Skill生态审计论文的投稿路径与策略

> 产出方法: academic-paper-strategist  
> 基于: ACADEMIC_PAPER_OUTLINE.md  
> 状态: 策略建议, 非执行指令

---

## 目标会议/期刊建议

| 目标 | 级别 | 截稿时间(推测) | 匹配度 | 理由 |
|------|:---:|------|:---:|------|
| **NeurIPS 2026 Datasets & Benchmarks** | A* | 约2026-06 | ⭐⭐⭐ | SkillsBench+OpenSkillEval都是benchmark, 你的审计可作为补充性实证研究 |
| **EMNLP 2026** | A | 约2026-06 | ⭐⭐ | NLP系统/Agent方向, 但偏应用 |
| **arXiv预印本** | - | 随时 | ⭐⭐⭐⭐⭐ | 最高优先级 — 先发arXiv确立时间戳, 再投会议 |
| **ICLR 2027** | A* | 约2026-10 | ⭐⭐⭐ | Agent+Benchmark方向很热 |

---

## 论文定位策略

**不要写成**: "我审计了自己的skill目录" — 太个人化, 学术价值弱

**应该写成**: "大规模Agent Skill生态的实证质量审计" — 以147个skill为样本, 连接SkillsBench/OpenSkillEval/SkillRouter的学术讨论

**核心贡献**:
1. 首个真实世界里Agent Skill质量分布的实证研究
2. 提出可复用的GA门禁标准(7文件, 可被其他研究采用)
3. 用外部benchmark验证自评发现(交叉验证提升可信度)

---

## 需要补充的数据(论文发表必需)

- [ ] 详细的审计方法描述(扫描方式/去重逻辑/质量标准/评分者间信度)
- [ ] 统计表格: 每个目录×每个质量等级的分布
- [ ] 评分者间信度: 是否需要第二个评判者独立评分?
- [ ] 限制: 单用户样本, 可能存在选择偏差
- [ ] 伦理声明: 审计的是个人skill, 是否涉及隐私?

---

## 与已有工作的关系

| 已有工作 | 你的论文的定位 |
|---------|-------------|
| SkillsBench | 你的审计验证了SkillsBench的核心发现(self-gen -1.3pp), 提供了补充性实证 |
| OpenSkillEval | 你的"选错skill<不用skill"发现与OpenSkillEval一致, 是在不同环境下的独立验证 |
| SkillRouter | 你的"74%无触发词"为SkillRouter的路由精度讨论提供了真实世界的数据点 |
| Anthropic官方 | 你的GA标准本质上是Anthropic标准的操作化版本 |

**独特贡献**: 不是benchmark(不引入新任务), 而是**audit**(审计真实部署的skill质量)。这是benchmark论文的补充视角。

---

## 发表可行性评估

**优势**:
- 研究问题新颖(Agent Skill生态质量审计)
- 数据真实(非合成)
- 与3个已有benchmark交叉验证

**劣势**:
- 样本量有限(147个skill, 单用户)
- 评分可能有主观成分(需补充评分者间信度)
- 没有引入新任务/新模型/新方法

**建议**: arXiv先发 → 收集社区反馈 → 扩充数据(如果可行) → 投workshop或benchmark track

---

> academic-paper-strategist方法: 会议匹配→论文定位→缺失数据→与已有工作关系→可行性评估
