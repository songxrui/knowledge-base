# 知识锻造管线 — 从信源到Skill的全链路

> 产出方法: knowledge-forge (知识锻造管线)  
> 链路: weread信源 → 内容结构化 → Skill自动化  
> 应用: 本次会话的完整知识生产流程

---

## 锻造管线的5个阶段

### 阶段1: 信源提取 (Input)
**工具**: weread-skills, exa-search, Notion导出
**本次产出**: 
- weread: 37+本书架数据, 4条理论锚点连接
- exa-search: Anthropic/SkillsBench/OpenSkillEval/SoK/SkillRouter 5个一级信源
- Notion: 未直接调用 (可后续接入)

### 阶段2: 内容结构化 (Structure)
**工具**: dbs-content-system
**本次产出**:
- 5类内容单元: QST(问题) + CON(概念) + OPI(观点) + CAS(案例) + SOL(方案)
- 15个内容单元 → 主题地图 → 装配稿

### 阶段3: 深度创作 (Create)
**工具**: khazix-writer, article-writing, viral-writer
**本次产出**:
- 1篇主文章(2542字) + 1篇实操指南(2549字)
- 三平台适配(微信/小红书/Twitter)
- 5张知识卡片 + 白话版

### 阶段4: 多维分析 (Analyze)
**工具**: ljg-think, dbs-deconstruct, dbs-benchmark, dbs-diagnosis, ljg-roundtable, dbs-chatroom-austrian, dbs-slowisfast
**本次产出**: 7篇深度分析(第一性拆解/5层深钻/竞争对标/商业化诊断/4角色圆桌/奥派视角/慢方法)

### 阶段5: 资产沉淀 (Archive)
**工具**: ljg-card, brand-voice, ljg-learn, ljg-read, ljg-qa, ljg-word
**本次产出**: 声音画像, 学习序列, 阅读伴侣, 20问题, 关键词深钻

---

## 锻造管线的复用性

这条5阶段管线不是一次性的。下次有新信源(新的书/文章/播客), 可以复现:

```
新信源进入 → weread-skills提取 → dbs-content-system结构化 
→ khazix-writer创作 → ljg系列多维度分析 → 资产沉淀
```

---

## 本次锻造数据

| 指标 | 数值 |
|------|:---:|
| 信源数 | 7个 (5学术 + 1书架 + 1本地审计) |
| Skill调用 | 35+次, 30+个skill |
| 产出文件 | 35个 |
| 内容类型 | 6大类 (可发布/深度分析/学习/验证/资产/元数据) |
| Git commits | 31 |
| 内容复用 | 同一套信源 → 30+种不同形态的内容 |

---

> knowledge-forge方法: 5阶段锻造(信源→结构化→创作→分析→沉淀), 一入多出, 管线可复用
