# Generate HTML presentation from v7 book chapters
import os

BASE = r"D:\KnowledgeBase\media\flagship\book-v7"

# Read key content
preface = ""
for enc in ['gbk','utf-8']:
    try:
        with open(os.path.join(BASE, "PREFACE.md"), "r", encoding=enc) as f:
            preface = f.read()
        break
    except:
        pass

# Extract core thesis from preface
thesis = "环卫工儿子的个人操作系统——130本名著提炼的8步决策-行动-复盘循环"

# Chapter summaries
chapters = [
    ("CH01", "元能力", "大脑操作系统", "理智脑不是干活的——让它驱动本能和情绪，而非取代它们"),
    ("CH02", "心理健康", "免疫系统", "不是学会快乐，是学会与痛苦共处——CBT/ACT是你的心理防弹衣"),
    ("CH03", "身体健康", "硬件基础", "蛀牙和痔疮教会我的：身体在用疼痛给你发信号"),
    ("CH04", "财富商业", "资源引擎", "三重复利飞轮：写作×自媒体×Codex，一年顶十年"),
    ("CH05", "人际关系", "连接网络", "哈佛85年研究：幸福的核心是关系质量，不是财富数字"),
    ("CH06", "顶级人类", "对标灯塔", "从活人身上提取方法论：不是成为他们，是学他们怎么思考"),
    ("CH07", "问题解决", "执行引擎", "第一性求解器：拆解问题→模型匹配→方案输出"),
    ("CH08", "第一性模型", "元模型", "贝叶斯更新+二阶思维+复利不只是钱——终身决策的基础设施"),
]

# Build HTML
html = """<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>答案之书 v7 — 环卫工儿子的个人操作系统</title>
<style>
* { margin:0; padding:0; box-sizing:border-box; }
body { font-family: 'Segoe UI', 'Microsoft YaHei', sans-serif; background:#0d1117; color:#c9d1d9; }
.slide { min-height:100vh; display:flex; flex-direction:column; justify-content:center; align-items:center; padding:60px 40px; border-bottom:1px solid #21262d; }
.slide:nth-child(odd) { background:#0d1117; }
.slide:nth-child(even) { background:#161b22; }
h1 { font-size:3em; color:#58a6ff; margin-bottom:20px; text-align:center; }
h2 { font-size:2.2em; color:#f0883e; margin-bottom:15px; }
h3 { font-size:1.4em; color:#8b949e; margin-bottom:10px; }
p { font-size:1.3em; line-height:1.8; max-width:800px; text-align:center; margin:10px 0; }
.quote { font-style:italic; color:#7ee787; font-size:1.5em; margin:30px 0; border-left:4px solid #7ee787; padding-left:20px; max-width:700px; }
.tag { display:inline-block; background:#1f6feb22; color:#58a6ff; padding:4px 12px; border-radius:12px; font-size:0.9em; margin:5px; }
.stats { display:flex; gap:40px; margin:30px 0; flex-wrap:wrap; justify-content:center; }
.stat { text-align:center; }
.stat .num { font-size:3em; color:#f0883e; font-weight:bold; }
.stat .label { color:#8b949e; font-size:0.9em; }
.grid { display:grid; grid-template-columns:repeat(4,1fr); gap:20px; max-width:1000px; margin:30px 0; }
.card { background:#21262d; border-radius:12px; padding:25px; text-align:center; }
.card h3 { color:#58a6ff; font-size:1.2em; margin-bottom:8px; }
.card p { font-size:0.95em; color:#8b949e; }
.footer { color:#484f58; font-size:0.8em; margin-top:40px; }
</style>
</head>
<body>

<div class="slide">
  <p class="tag">v7 · 2026-06-11</p>
  <h1>答案之书</h1>
  <h3>环卫工儿子的个人操作系统</h3>
  <p>130本名著 × 68条微信读书高亮 × 8章可执行框架</p>
  <div class="stats">
    <div class="stat"><div class="num">260K</div><div class="label">字符</div></div>
    <div class="stat"><div class="num">8</div><div class="label">章节</div></div>
    <div class="stat"><div class="num">10</div><div class="label">信源书籍</div></div>
    <div class="stat"><div class="num">0</div><div class="label">禁用词</div></div>
  </div>
  <p class="footer">GitHub: songxrui/knowledge-base · 飞书: jcn1crrvstv9</p>
</div>

<div class="slide">
  <h2>我的成长路径</h2>
  <p>环卫工父母 → 一本大学 → 9000元Java培训班 → 哈啰实习</p>
  <p>→ 秋招全挂 → 放弃春招 → all in Notion知识库</p>
  <p>→ Codex + 自媒体 + 运动 = 三重复利</p>
  <p class="quote">"不是因为我聪明——是因为我摔得足够多，每一次都记了下来"</p>
  <div class="stats">
    <div class="stat"><div class="num">蛀牙</div><div class="label">第一个警告</div></div>
    <div class="stat"><div class="num">痔疮</div><div class="label">第二个警告</div></div>
    <div class="stat"><div class="num">抑郁</div><div class="label">第三个警告</div></div>
  </div>
</div>

<div class="slide">
  <h2>八章架构：从知道到做到</h2>
  <div class="grid">
"""

for ch_id, name, subtitle, quote in chapters:
    html += '<div class="card"><h3>' + ch_id + '</h3><p><b>' + name + '</b></p><p>' + subtitle + '</p></div>\n'

html += """  </div>
  <p class="quote">"每一章都经过了真实人生的验证——不是纸上推演，是从废墟里挖出来的"</p>
</div>
"""

for ch_id, name, subtitle, quote in chapters:
    html += """
<div class="slide">
  <p class="tag">""" + ch_id + """</p>
  <h2>""" + name + """</h2>
  <h3>""" + subtitle + """</h3>
  <p class="quote">\"""" + quote + """\"</p>
</div>
"""

html += """
<div class="slide">
  <h2>微信读书证据链</h2>
  <p>68条高亮 · 10本核心书籍 · 8章全覆盖</p>
  <div class="stats">
    <div class="stat"><div class="num">4</div><div class="label">认知觉醒/驱动</div></div>
    <div class="stat"><div class="num">3</div><div class="label">成瘾/少有人走的路</div></div>
    <div class="stat"><div class="num">4</div><div class="label">复利/穷查理/致富/游戏</div></div>
  </div>
  <p>每一章匹配2-8条真实划线，杜绝AI空谈</p>
</div>

<div class="slide">
  <h2>三重复利飞轮</h2>
  <p>写作产生思想 → 自媒体放大影响 → Codex降低执行成本</p>
  <p>→ 更多写作素材 → 更精准的受众 → 更高效的执行 → 循环</p>
  <p class="quote">"一年做三件事，不如三年做一件事——前提是这件事自带复利"</p>
</div>

<div class="slide">
  <h2>这不是一本"读完就忘"的书</h2>
  <p>每章配备：</p>
  <p>✅ 可执行行动系统 · ✅ 反共识角度 · ✅ 微信读书证据 · ✅ 失败模式预警</p>
  <p style="margin-top:40px;font-size:1.5em;color:#f0883e;">现在，从第一章开始。</p>
  <p class="footer">答案之书 v7 · songxrui/knowledge-base · 飞书已同步</p>
</div>

</body>
</html>"""

out = r"D:\KnowledgeBase\media\flagship\book-v7\presentation.html"
with open(out, "w", encoding="utf-8") as f:
    f.write(html)
print("presentation.html generated: " + str(len(html)) + " bytes")
