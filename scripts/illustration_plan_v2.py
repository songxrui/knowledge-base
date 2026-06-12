# Analyze v7 PREFACE for illustration opportunities
preface_path = r"D:\KnowledgeBase\media\flagship\book-v7\PREFACE.md"

preface = None
for enc in ['utf-8', 'gbk', 'gb2312']:
    try:
        with open(preface_path, "r", encoding=enc) as f:
            preface = f.read()
        break
    except:
        pass

sections = preface.split("## ")
illustration_plan = []

for i, sec in enumerate(sections):
    if not sec.strip():
        continue
    title = sec.split("\n")[0].strip()[:60]
    
    if any(w in sec for w in ["环卫工", "培训", "Java", "哈啰", "秋招"]):
        illustration_plan.append(("个人故事插图", title, "作者成长路径时间线图", "timeline"))
    if any(w in sec for w in ["130", "8章", "67本", "134"]):
        illustration_plan.append(("数据可视化", title, "关键数字信息图", "infographic"))
    if any(w in sec for w in ["操作系统", "八章", "闭环"]):
        illustration_plan.append(("概念框架图", title, "8章架构关系图", "diagram"))

print("# v7 答案之书 — 配图机会分析\n")
print("## 前言配图机会")
for typ, title, desc, fmt in illustration_plan:
    print("- **" + typ + "** (" + fmt + "): " + desc)
    print("  位置: " + title)

print("\n## 8章配图建议")
chs = [
    ("CH01 元能力", "大脑三层次图", "理智脑/情绪脑/本能脑"),
    ("CH02 心理健康", "CBT-ACT干预流程", "认知行为疗法核心步骤"),
    ("CH03 身体健康", "抗炎饮食金字塔", "饮食层级结构"),
    ("CH04 财富商业", "三重复利飞轮", "写作×自媒体×Codex"),
    ("CH05 人际关系", "关系质量雷达图", "哈佛85年研究5维度"),
    ("CH06 顶级人类", "对标方法论4步骤", "观察→提取→内化→超越"),
    ("CH07 问题解决", "第一性求解器", "拆解→匹配→输出"),
    ("CH08 第一性模型", "模型工具箱", "贝叶斯/二阶/复利/系统论"),
]
for ch, img, desc in chs:
    print("- **" + ch + "**: " + img + " — " + desc)

print("\n## 优先级")
print("P0: 封面图 (baoyu-cover-image) — 环卫工儿子的个人操作系统")
print("P1: 8章架构图 (baoyu-diagram) — 全书概念关系")
print("P1: 三重复利飞轮 (baoyu-infographic) — CH04核心")
print("P2: 8章概念图 × 8 (baoyu-article-illustrator)")
print("\n总计: 1封面 + 1架构图 + 1信息图 + 8概念图 = 11张")
