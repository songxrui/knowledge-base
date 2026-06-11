# Generate v7 8-chapter architecture diagram + brand-voice audit
import os, re

BASE = r"D:\KnowledgeBase\media\flagship\book-v7"
chapters = [
    ("CH01", "CH01_meta-abilities.md", "元能力：大脑操作系统"),
    ("CH02", "CH02_mental-health.md", "心理健康：免疫系统"),
    ("CH03", "CH03_physical-health.md", "身体健康：硬件基础"),
    ("CH04", "CH04_wealth-business.md", "财富商业：资源引擎"),
    ("CH05", "CH05_relationships.md", "人际关系：连接网络"),
    ("CH06", "CH06_top-humans.md", "顶级人类：对标灯塔"),
    ("CH07", "CH07_problem-solving.md", "问题解决：执行引擎"),
    ("CH08", "CH08_first-principles.md", "第一性模型：元模型"),
]

# Extract key concepts and cross-refs
connections = []
voice_markers = {"我": 0, "我们": 0, "你": 0, "**": 0, "？": 0, "。": 0, "→": 0}

for ch_id, fname, topic in chapters:
    fpath = os.path.join(BASE, fname)
    content = None
    for enc in ['utf-8', 'gbk']:
        try:
            with open(fpath, "r", encoding=enc) as f:
                content = f.read()
            break
        except:
            pass
    if not content:
        continue
    
    # Count voice markers
    for marker in voice_markers:
        voice_markers[marker] += content.count(marker)
    
    # Find cross-references to other chapters
    for other_id, _, _ in chapters:
        if other_id != ch_id:
            pattern = other_id + "|第" + other_id[-1] + "章"
            count = len(re.findall(pattern, content))
            if count > 0:
                connections.append((ch_id, other_id, count))

# Generate Mermaid diagram
diagram = """# v7 答案之书 — 八章架构关系图

```mermaid
graph TD
    CH01["CH01 元能力<br/>大脑操作系统<br/>理智脑/情绪脑/本能脑"]
    CH02["CH02 心理健康<br/>免疫系统<br/>CBT/ACT/MBCT"]
    CH03["CH03 身体健康<br/>硬件基础<br/>抗炎饮食/运动/睡眠"]
    CH04["CH04 财富商业<br/>资源引擎<br/>复利/投资/商业"]
    CH05["CH05 人际关系<br/>连接网络<br/>哈佛85年研究"]
    CH06["CH06 顶级人类<br/>对标灯塔<br/>姜胡说/价值心法"]
    CH07["CH07 问题解决<br/>执行引擎<br/>第一性求解器"]
    CH08["CH08 第一性模型<br/>元模型<br/>贝叶斯/二阶/系统论"]
    
    CH01 -->|认知基础| CH02
    CH01 -->|认知基础| CH07
    CH02 -->|身心一体| CH03
    CH03 -->|硬件支撑| CH04
    CH03 -->|能量基础| CH07
    CH04 -->|资源放大| CH06
    CH05 -->|关系赋能| CH04
    CH05 -->|社会支持| CH02
    CH06 -->|对标驱动| CH07
    CH06 -->|模型来源| CH08
    CH07 -->|实践反馈| CH08
    CH08 -->|模型指导| CH01
    CH08 -->|模型指导| CH04
    CH04 -->|独立基础| CH05
```

## 连接说明

"""
for src, dst, count in sorted(set((s,d) for s,d,c in connections)):
    diagram += "- " + src + " → " + dst + ": " + str(count) + "处交叉引用\n"

# Brand voice audit
total_chars = sum(voice_markers.values()) or 1
first_person_ratio = voice_markers["我"] / max(1, voice_markers["我们"] + voice_markers["你"])
bold_density = voice_markers["**"] / max(1, total_chars / 1000)

diagram += """
## 品牌语调审计

| 指标 | 数值 | 解读 |
|------|------|------|
| 第一人称"我" | """ + str(voice_markers["我"]) + """ | 个人叙事驱动 |
| 第二人称"你" | """ + str(voice_markers["你"]) + """ | 直接对话读者 |
| 第一人称"我们" | """ + str(voice_markers["我们"]) + """ | 社群认同感 |
| 加粗密度(每千字) | """ + str(round(bold_density, 1)) + """ | 强调重点节奏 |
| 问号数 | """ + str(voice_markers["？"]) + """ | 启发式提问 |
| 箭头"→" | """ + str(voice_markers["→"]) + """ | 因果逻辑链 |

**语调判定**: 个人叙事+直接对话+启发性提问="教练型人格"品牌语调，与"环卫工儿子的个人操作系统"定位一致。
"""

# Save
out_path = r"D:\KnowledgeBase\media\flagship\book-v7\ARCHITECTURE_DIAGRAM.md"
with open(out_path, "w", encoding="utf-8") as f:
    f.write(diagram)

print("Generated: ARCHITECTURE_DIAGRAM.md")
print("Cross-ref connections found: " + str(len(set((s,d) for s,d,c in connections))))
print("Brand voice: " + str(voice_markers["我"]) + " 我 / " + str(voice_markers["你"]) + " 你 / " + str(voice_markers["我们"]) + " 我们")
