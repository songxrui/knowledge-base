# Analyze v7 PREFACE for illustration opportunities
# Based on baoyu-article-illustrator methodology

with open(r"D:\KnowledgeBase\media\flagship\book-v7\PREFACE.md", "r", encoding="utf-8") as f:
    preface = f.read()

# Find illustration positions based on content signals
sections = preface.split("## ")
illustration_plan = []

for i, sec in enumerate(sections):
    if not sec.strip():
        continue
    title = sec.split("\n")[0].strip()[:60]
    
    # Signal: personal story = portrait/photo opportunity
    if any(w in sec for w in ["环卫工", "培训", "Java", "哈啰", "秋招", "前女友"]):
        illustration_plan.append(("个人故事插图", title, "作者成长路径时间线图", "timeline"))
    
    # Signal: data/stats = infographic opportunity
    if any(w in sec for w in ["130", "8章", "67本", "%", "66"]):
        illustration_plan.append(("数据可视化", title, "关键数字信息图", "infographic"))
    
    # Signal: concept framework = diagram opportunity
    if any(w in sec for w in ["操作系统", "章", "闭环", "系统"]):
        illustration_plan.append(("概念框架图", title, "8章架构关系图", "diagram"))

# Also analyze chapter topics for illustrations
chapter_illus = {
    "CH01 元能力": ("大脑三层次图", "理智脑/情绪脑/本能脑的关系"),
    "CH02 心理健康": ("CBT-ACT干预流程图", "认知行为疗法的核心步骤"),
    "CH03 身体健康": ("抗炎饮食金字塔", "饮食层级结构"),
    "CH04 财富商业": ("三重复利飞轮", "写作×自媒体×Codex"),
    "CH05 人际关系": ("关系质量雷达图", "哈佛85年研究的5个维度"),
    "CH06 顶级人类": ("对标方法论", "从观察到内化的4步骤"),
    "CH07 问题解决": ("第一性求解器", "问题拆解→模型匹配→方案输出"),
    "CH08 第一性模型": ("模型工具箱", "贝叶斯/二阶思维/复利/系统论"),
}

print("# v7 答案之书 — 配图机会分析\n")
print("## 前言配图机会")
for typ, title, desc, fmt in illustration_plan:
    print(f"- **{typ}** ({fmt}): {desc}")
    print(f"  - 位置: {title}")

print("\n## 8章配图建议")
for ch, (img, desc) in chapter_illus.items():
    print(f"- **{ch}**: {img} — {desc}")

print(f"\n## 优先级")
print("P0: 封面图 (baoyu-cover-image) — 环卫工儿子的个人操作系统")
print("P1: 8章架构关系图 (baoyu-diagram) — 全书概念连接")
print("P1: 三重复利飞轮 (baoyu-infographic) — CH04核心概念")
print("P2: 各章概念图 (baoyu-article-illustrator) — 8张逐一生成")
print("\n总计: 1封面 + 1架构图 + 1信息图 + 8概念图 = 11张插图")
