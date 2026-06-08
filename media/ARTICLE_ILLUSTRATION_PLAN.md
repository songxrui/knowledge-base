# 文章配图分析 — Skill生态审计文章的视觉增强

> 产出方法: baoyu-article-illustrator (文章配图分析)  
> 对象: crosspost-wechat.md (微信公众号主版)  
> 目标: 识别需要配图的位置 + 配图类型

---

## 配图位置规划

### 配图1: 文章封面 (已设计)
- 位置: 文章顶部
- 类型: 数据冲击型 (846→7漏斗)
- 规格: COVER_IMAGE_SPEC.md

### 配图2: 数据漏斗图
- 位置: 第一节 "我审计了846个AI Skill实例" 之后
- 类型: 垂直漏斗
- 内容: 846 → 358 → 147 → 7
- 参考: DIAGRAMS_SKILL_ECOSYSTEM.md (图1)

### 配图3: 三层结构对比
- 位置: "Anthropic的标准 vs 我们的现实" 小节
- 类型: 侧对比图
- 左侧: Anthropic标准 (metadata→SKILL.md→references)
- 右侧: 本地现实 (仅SKILL.md, 缺metadata和references)

### 配图4: 技能管线图
- 位置: "这篇文章本身就是证明" 结尾段
- 类型: 水平流程图
- 内容: skill-review → dbs-content → khazix-writer → dbs-hook → brand-voice → exa-search
- 参考: DIAGRAMS_SKILL_ECOSYSTEM.md (图2)

### 配图5: 外部验证网络
- 位置: "学术上也验证了这个问题" 段落后
- 类型: 辐射图
- 内容: 中心=审计发现, 辐射=Anthropic/SkillsBench/OpenSkillEval/SkillRouter
- 参考: DIAGRAMS_SKILL_ECOSYSTEM.md (图3)

---

## 配图设计原则

1. **数据可视化感**: 用数据图表而非装饰性插画
2. **深色主题**: 背景#1a1a2e, 亮色#00d4ff高亮
3. **中文优先**: 图表内文字用中文
4. **统一风格**: 所有配图用同一套颜色和字体

---

## 配图生成优先级

| 优先级 | 配图 | 理由 |
|:---:|------|------|
| P0 | #2 数据漏斗 | 核心观点可视化, 冲击力最强 |
| P0 | #3 标准对比 | 直接展示"该有的vs实际的"差距 |
| P1 | #4 管线图 | 证明文章方法论 |
| P2 | #5 验证网络 | 增强可信度 |

---

> baoyu-article-illustrator: 5个配图位置+类型+优先级, 与DIAGRAMS_SKILL_ECOSYSTEM.md对齐
