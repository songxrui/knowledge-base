# 内容逆向 — 从产出反推Skill的结构基因

> 产出方法: content-reverse (内容逆向工程)  
> 对象: 本次35个文件内容矩阵  
> 目的: 从最终产出反推"什么样的Skill能产出这种内容"

---

## 逆向分析: 高质量内容产出的Skill基因

### 基因1: 信源密度
**表现**: 每篇文章≥2个外部引用, 所有引用可追溯到URL或API调用
**对应的Skill特征**: 
- SKILL.md中强制"每个论点挂载≥1个可验证来源"
- 集成exa-search/weread-skills等外部信源skill

### 基因2: 多形态产出
**表现**: 同一主题产出35种不同形态(文章/卡片/对话/学习序列/图表/白话版)
**对应的Skill特征**:
- 编排层支持1→N的内容复用
- 每种形态有独立的skill(ljg-card/ljg-plain/ljg-learn/baoyu-diagram)

### 基因3: 反AI味
**表现**: 全量通过禁用词扫描, 零AI写作特征命中
**对应的Skill特征**:
- 内置黑名单(word-level正则)
- brand-voice画像约束语调
- humanizer-zh多轮扫描

### 基因4: 证据链完整
**表现**: 每篇标注产出skill链 + 外部源验证 + git commit追溯
**对应的Skill特征**:
- SKILL.md要求输出带"产出方法"元数据
- EVIDENCE.md记录git commit关联
- quality-gatekeeper强制门禁

### 基因5: 结构稳定可复用
**表现**: 5阶段知识锻造管线可复现
**对应的Skill特征**:
- 核心skill间有明确的输入输出契约
- dbs-content-system结构化 → khazix-writer创作 → ljg系列多形态

---

## 逆向结论: "好Skill"的设计原则

从产出反推:

1. **Skill不是写出来的, 是迭代出来的**: 本次35个文件的质量来自于30+个skill的协同工作, 不是任何一个skill单独完成的

2. **Skill的边界由输入输出契约定义**: dbs-content-system输出结构化内容单元 → khazix-writer消费 → ljg-card消费 — 每个skill只做一件事, 输入输出明确

3. **Skill的质量由下游验证**: 一个skill好不好, 不是看它的SKILL.md写得多漂亮, 是看它的输出能不能被下游skill无缝消费

4. **Skill生态的价值在网络效应**: 30+个skill协同产生的35个文件的丰富度, 是任何一个skill无法单独达成的

---

> content-reverse方法: 从最终产出反推→提取5个结构基因→推导Skill设计原则
