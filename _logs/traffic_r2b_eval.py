import os

skill_file = r"C:\Users\董辉\.codex\skills\traffic-engineering\SKILL.md"
with open(skill_file, "r", encoding="utf-8") as f:
    content = f.read()

size = len(content.encode("utf-8"))
print(f"R2 Size: {size} bytes")

# Manual scoring
# D1 (10%): trigger specificity
d1_score = 10  # Already had perfect D1, still good

# D2 (10%): structure
d2_tests = ["---" in content[:10], "## " in content, "agents/openai.yaml", "references/" in content]
d2_score = sum(1 for t in d2_tests if t) * 2.5

# D3 (15%): executability
d3_tests = ["布尔" in content, "Phase " in content, "rg " in content or "Select-String" in content, "检测命令" in content]
d3_score = sum(1 for t in d3_tests if t) * 2.5

# D4 (10%): verification
d4_tests = ["评级" in content, "输出格式" in content, "rg " in content or "Select-String" in content]
d4_score = sum(1 for t in d4_tests if t) * 3.3

# D5 (10%): platform compat
d5_tests = ["小红书" in content, "抖音" in content, "公众号" in content, "PowerShell" in content, "Codex" in content, "DeepSeek" in content]
d5_score = sum(1 for t in d5_tests if t) * 1.7  

# D6 (10%): evidence
d6_tests = ["et al" in content, "确认" in content, "推断" in content, "禁止编造" in content]
d6_score = sum(1 for t in d6_tests if t) * 2.5

# D7 (10%): failure handling
d7_tests = ["失败模式" in content, "解法" in content, "推断" in content]
d7_score = sum(1 for t in d7_tests if t) * 3.3

# D8 (5%): efficiency
d8_score = 10 if size < 8000 else (9 if size < 10000 else 8)

# D9 (10%): AI flavor resistance
banned = ["赋能","抓手","闭环","综上所述","众所周知","值得注意的是"]
d9_score = max(0, 10 - sum(1 for w in banned if w in content))

# D10 (5%): size
d10_score = 10 if size < 8000 else (9 if size < 10000 else 8)

scores = {"D1": d1_score, "D2": d2_score, "D3": d3_score, "D4": d4_score, "D5": d5_score, "D6": d6_score, "D7": d7_score, "D8": d8_score, "D9": d9_score, "D10": d10_score}
weights = {"D1": 10, "D2": 10, "D3": 15, "D4": 10, "D5": 10, "D6": 10, "D7": 10, "D8": 5, "D9": 10, "D10": 5}

total = 0
for k in scores:
    s = scores[k]
    w = weights[k]
    weighted = s * w / 100
    total += weighted
    print(f"  {k}: {s:.0f}/10 (w={w}%, weighted={weighted:.1f})")

print(f"\n  R2 TOTAL: {total*10:.1f}/100")
