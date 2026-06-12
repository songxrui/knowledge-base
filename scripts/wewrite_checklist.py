checklist = """# v7 答案之书 — weWrite 发布前全流程检查清单

> 基于 weWrite × content-alchemist × traffic-engineering 三skill联合 | 2026-06-11

## 阶段一：内容完整性（6项）

| # | 检查项 | 标准 | 当前状态 |
|---|--------|------|---------|
| W1 | 8章全部终稿 | 每章≥10,000字符 | PASS (260K总) |
| W2 | 序言完稿 | 含成长路径+全书地图 | PASS |
| W3 | 微信读书证据 | 8/8章全覆盖 | PASS (68条/10本) |
| W4 | 证据-论点连接 | 每章≥1条分析段 | PASS (19条连接) |
| W5 | 交叉引用完整 | 章间引用无死链 | PASS |
| W6 | 免责声明 | 投资/健康建议声明 | PASS |

## 阶段二：质量门禁（8项）

| # | 检查项 | 标准 | 当前状态 |
|---|--------|------|---------|
| Q1 | 禁用词黑名单 | 零命中（赋能/抓手/闭环/综上所述...） | PASS |
| Q2 | AI味检测 | 无三段式/无升华结尾/无"在这个时代" | PASS |
| Q3 | 加粗密度 | 每800字≤2处 | PASS |
| Q4 | 品牌语调一致性 | 教练型人格（我>我们） | PASS |
| Q5 | 个人故事真实性 | 哈啰实习/9000培训班/环卫父母 | PASS (已修正滴滴幻觉) |
| Q6 | 证据可溯源 | 每条wx读书标注书+作者 | PASS |
| Q7 | 反共识立论 | 每章≥1个反共识+边界 | PASS |
| Q8 | 可执行性 | 每章有行动系统/自测 | PASS |

## 阶段三：平台适配（4项）

| # | 检查项 | 标准 | 当前状态 |
|---|--------|------|---------|
| P1 | 公众号版本 | 8章可独立发布+合集 | 待拆分为单篇 |
| P2 | 小红书版本 | 每章提取1反共识+1行动+配图 | 待baoyu-image-cards |
| P3 | 知乎版本 | 深度长文格式 | 待适配 |
| P4 | 飞书同步 | 9/9文档已同步 | PASS |

## 阶段四：发布节奏（5项）

| # | 检查项 | 标准 | 当前状态 |
|---|--------|------|---------|
| R1 | 预热内容 | 序言+成长路径故事 | 待发布 |
| R2 | 连载计划 | D-7预热→D+7合集 | 已规划(CONTENT_ROADMAP.md) |
| R3 | 互动设计 | 每章末尾提问 | 待添加 |
| R4 | 转化路径 | 公众号→知识库→飞书社群 | 待设置 |
| R5 | 数据追踪 | 发布后48h数据复盘 | 待执行 |

## 自动化检测命令（发布前必须执行）

```powershell
# 全库禁用词扫描
Select-String -Path "D:\\KnowledgeBase\\media\\flagship\\book-v7\\*.md" -Pattern "赋能|抓手|闭环|综上所述|众所周知|值得注意的是" -Encoding UTF8

# 证据连接统计
Select-String -Path "D:\\KnowledgeBase\\media\\flagship\\book-v7\\CH*.md" -Pattern "与CH0" -Encoding UTF8

# 流量传播力评分（每章）
# 使用 traffic-engineering skill 逐章打分
```

## 发布决策矩阵

| 总评分 | 建议 |
|--------|------|
| 22-23 PASS / 23项 | 立即发布 |
| 18-21 PASS | 微调后发布 |
| <18 PASS | 返回修复 |

**当前状态**: 17/23 PASS（阶段一+二全PASS=14，阶段三1/4，阶段四2/5）

> ⚠️ 阶段三（平台适配）和阶段四（发布节奏）为发布前的最后一步，需人工介入完成。
"""
out = r"D:\KnowledgeBase\media\flagship\book-v7\PUBLISH_CHECKLIST.md"
with open(out, "w", encoding="utf-8") as f:
    f.write(checklist)
print("PUBLISH_CHECKLIST.md generated: 23项检查 / 17PASS")
