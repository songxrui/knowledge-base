import os

skill_file = r"C:\Users\董辉\.codex\skills\traffic-engineering\SKILL.md"
with open(skill_file, "r", encoding="utf-8") as f:
    content = f.read()

size = len(content.encode("utf-8"))
print(f"R2 Size: {size} bytes")

# R2 evaluation scores
checks = {
    "D1_触发特异性": sum([1 for x in ["何时使用", "不使用", "→", "skill", "触发"] if x in content]),
    "D2_结构完整": sum([1 for x in ["---", "## ", "agents/openai.yaml", "references/"] if x in content]),
    "D3_可执行性": sum([1 for x in ["布尔", "Phase ", "rg ", "检测命令"] if x in content]),
    "D4_验证闭环": sum([1 for x in ["评级", "输出格式", "rg ", "example.md"] if x in content]),
    "D5_平台兼容": sum([1 for x in ["小红书", "抖音", "公众号", "PowerShell", "Codex", "DeepSeek"] if x in content]),
    "D6_证据锚定": sum([1 for x in ["et al", "确认", "推断", "禁止编造"] if x in content]),
    "D7_失败处理": sum([1 for x in ["失败模式", "解法", "不确定", "推断"] if x in content]),
    "D8_效率": 10 if size < 8000 else (9 if size < 10000 else 8),
    "D9_AI味抵抗": 10 - sum(1 for w in ["赋能","抓手","闭环","综上所述","众所周知","值得注意的是"] if w in content),
    "D10_大小": 10 if size < 8000 else (9 if size < 10000 else 8),
}

weights = {"D1": 10, "D2": 10, "D3": 15, "D4": 10, "D5": 10, "D6": 10, "D7": 10, "D8": 5, "D9": 10, "D10": 5}
total = 0
for k, v in checks.items():
    dim = k[:3]
    score = min(10, v * 2)
    w = weights[dim]
    weighted = score * w / 100
    total += weighted
    print(f"  {dim}: {score}/10 ({v} checks, weighted={weighted:.1f})")

print(f"\n  R2 TOTAL: {total*10:.1f}/100")
print(f"  R2 vs R1: R1=91.5 → R2={total*10:.1f}")
