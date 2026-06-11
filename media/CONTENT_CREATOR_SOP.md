# 内容创作者操作手册 — 如何复现本次工作的完整SOP

> 产出方法: 综合总结 (基于56+ skill调用经验)  
> 目标: 任何内容创作者可以按此SOP复现"1主题→40+变体"的内容生产

---

## SOP: 从1个主题到40+内容变体

### Phase 0: 准备 (5 min)

```bash
# 1. 确认环境
git status                    # 确认在正确仓库
feishu --version              # 确认飞书CLI可用
$env:WEREAD_TOKEN = "xxx"     # 设置信源token

# 2. 启动监工
.\scripts\heartbeat.ps1 -TargetRepo "D:\KnowledgeBase"

# 3. 选择主题
# 规则: 有数据+有外部源+有个人经验的主题
```

### Phase 1: 信源接入 (10 min)

```
Step 1: weread-skills → 拉取书架/划线/笔记
Step 2: exa-search → 搜索学术论文 (arXiv) + 官方博客
Step 3: 记录所有信源到 SOURCE_LOG.md
Step 4: 每个信源标注: URL/日期/关键引用
```

### Phase 2: 核心创作 (15 min)

```
Step 1: dbs-content-system → 结构化 (QST/CON/OPI/CAS/SOL)
Step 2: khazix-writer → 主文章 (1500-2500字)
Step 3: compile-and-verify → 验证 (目标/证据/完整性)
Step 4: humanizer-zh → 去AI味
Step 5: brand-voice → 声音校准
```

### Phase 3: 多维扩散 (30 min, 可并行)

```
并行组A (分析):
├── dbs-deconstruct → 第一性拆解
├── ljg-think → 5层深钻
├── dbs-benchmark → 竞争对标
└── dbs-diagnosis → 商业化诊断

并行组B (教学):
├── ljg-learn → 3课学习序列
├── ljg-read → 阅读伴侣
└── ljg-qa → 20问题

并行组C (工程):
├── api-design → API规范
├── backend-patterns → 架构模式
└── security-review → 安全审查

并行组D (平台):
├── crosspost → 微信/小红书/Twitter/英文
├── content-repurposing → checklist/slide
└── baoyu-* → 图表/封面/漫画
```

### Phase 4: 验证与完整循环 (10 min)

```
Step 1: content-auditor → 全量审计
Step 2: quality-gatekeeper → 3关门禁
Step 3: verification-loop → 5 Loop验证
Step 4: content-truth-lock → 主张验证
Step 5: diff-reviewer → 变更审查
```

### Phase 5: 交付 (5 min)

```
Step 1: git add -A && git commit
Step 2: git push origin master
Step 3: 飞书同步 (需环境变量)
Step 4: MASTER_INDEX.md 更新
Step 5: dbs-save → 状态存档
```

---

## 总耗时

| Phase | 时间 | 可并行? |
|-------|:---:|:---:|
| 准备 | 5 min | 否 |
| 信源 | 10 min | 部分 |
| 核心创作 | 15 min | 否 |
| 多维扩散 | 30 min | **是** (节省50%) |
| 验证 | 10 min | 部分 |
| 交付 | 5 min | 否 |
| **总计** | **75 min** | **并行后~50 min** |

---

## 核心原则

1. **信源先行**: 没有外部验证不开始创作
2. **核心链优先**: 主文章稳定后再扩散
3. **并行扩散**: 识别无依赖路径, 同时进行
4. **每步commit**: 不批量提交, 保持可追溯
5. **验证完整循环**: 不通过门禁不交付
6. **零造假**: 无自述工时, 心跳system-captured

---

> SOP: 5 Phase, 75 min (并行后50 min), 6条核心原则, 可直接复制使用
