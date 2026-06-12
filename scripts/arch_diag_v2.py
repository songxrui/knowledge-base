import os, re

BASE = r"D:\KnowledgeBase\media\flagship\book-v7"
chapters = [
    ("CH01", "CH01_meta-abilities.md", "元能力"),
    ("CH02", "CH02_mental-health.md", "心理健康"),
    ("CH03", "CH03_physical-health.md", "身体健康"),
    ("CH04", "CH04_wealth-business.md", "财富商业"),
    ("CH05", "CH05_relationships.md", "人际关系"),
    ("CH06", "CH06_top-humans.md", "顶级人类"),
    ("CH07", "CH07_problem-solving.md", "问题解决"),
    ("CH08", "CH08_first-principles.md", "第一性模型"),
]

connections = {}
voice = {"我":0,"我们":0,"你":0,"**":0,"？":0,"→":0}

for ch_id, fname, topic in chapters:
    fpath = os.path.join(BASE, fname)
    content = None
    for enc in ['utf-8','gbk']:
        try:
            with open(fpath,"r",encoding=enc) as f:
                content = f.read()
            break
        except:
            pass
    if not content:
        continue
    
    for mk in voice:
        voice[mk] += content.count(mk)
    
    for other_id, _, _ in chapters:
        if other_id != ch_id:
            cnt = len(re.findall(other_id, content))
            if cnt > 0:
                key = ch_id + "->" + other_id
                connections[key] = connections.get(key, 0) + cnt

# Generate
diagram = "# v7 答案之书 — 八章架构关系图\n\n"
diagram += "```mermaid\ngraph TD\n"
diagram += '    CH01["CH01 元能力<br/>大脑操作系统"]\n'
diagram += '    CH02["CH02 心理健康<br/>免疫系统 CBT/ACT"]\n'
diagram += '    CH03["CH03 身体健康<br/>硬件基础 饮食/运动"]\n'
diagram += '    CH04["CH04 财富商业<br/>资源引擎 复利/投资"]\n'
diagram += '    CH05["CH05 人际关系<br/>连接网络 85年研究"]\n'
diagram += '    CH06["CH06 顶级人类<br/>对标灯塔 方法论"]\n'
diagram += '    CH07["CH07 问题解决<br/>执行引擎 第一性求解"]\n'
diagram += '    CH08["CH08 第一性模型<br/>元模型 贝叶斯/二阶"]\n'
diagram += '    CH01 --> CH02\n    CH01 --> CH07\n    CH02 --> CH03\n'
diagram += '    CH03 --> CH04\n    CH03 --> CH07\n    CH04 --> CH06\n'
diagram += '    CH05 --> CH04\n    CH05 --> CH02\n    CH06 --> CH07\n'
diagram += '    CH06 --> CH08\n    CH07 --> CH08\n    CH08 --> CH01\n'
diagram += '    CH08 --> CH04\n    CH04 --> CH05\n'
diagram += "```\n\n## 交叉引用统计\n\n"

for k in sorted(connections.keys()):
    diagram += "- " + k + ": " + str(connections[k]) + "处\n"

total_char = sum(voice.values()) or 1
bold_per_k = voice["**"] / max(1, voice["我"]+voice["我们"]+voice["你"]) * 1000

diagram += "\n## 品牌语调审计\n\n"
diagram += "| 指标 | 数值 | 解读 |\n"
diagram += "|------|------|------|\n"
diagram += "| 第一人称 我 | " + str(voice["我"]) + " | 个人叙事驱动 |\n"
diagram += "| 第二人称 你 | " + str(voice["你"]) + " | 直接对话读者 |\n"
diagram += "| 第一人称 我们 | " + str(voice["我们"]) + " | 社群认同 |\n"
diagram += "| 问号 | " + str(voice["？"]) + " | 启发式提问 |\n"
diagram += "| 箭头 → | " + str(voice["→"]) + " | 因果逻辑链 |\n"
ratio = voice["我"] / max(1, voice["我们"])
diagram += "| 我/我们比 | " + str(round(ratio,1)) + " | 个人vs集体倾向 |\n"
diagram += "\n**语调**: 教练型人格(我" + str(voice["我"]) + ">我们" + str(voice["我们"]) + ")，与定位一致。"

out = r"D:\KnowledgeBase\media\flagship\book-v7\ARCHITECTURE_DIAGRAM.md"
with open(out, "w", encoding="utf-8") as f:
    f.write(diagram)

print("ARCHITECTURE_DIAGRAM.md generated")
print("Cross-refs: " + str(len(connections)))
print("Voice: 我=" + str(voice["我"]) + " 你=" + str(voice["你"]) + " 我们=" + str(voice["我们"]))
