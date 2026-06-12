import os, re, json
from collections import Counter

roots = [
    r"C:\Users\董辉\.codex\skills",
    r"C:\Users\董辉\.agents\skills"
]

total = 0
results = []

for root in roots:
    if not os.path.exists(root): 
        continue
    for name in os.listdir(root):
        if name.startswith("."): 
            continue
        dirpath = os.path.join(root, name)
        if not os.path.isdir(dirpath): 
            continue
        skfile = os.path.join(dirpath, "SKILL.md")
        if not os.path.exists(skfile): 
            continue
        total += 1
        
        with open(skfile, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        
        g1 = "---" in content or "name:" in content[:200] or content.startswith("# ")
        g2 = (any(k in content.lower()[:500] for k in ["description", "when to use"])) or \
             (any(k in content[:500] for k in ["触发", "适用场景"]))
        g2 = g2 and (any(k in content[:500] for k in ["不适用", "不适合", "排除", "边界"]))
        g3 = bool(re.search(r'\d+[\.\)、]|Step\s*\d|Phase\s*\d|第[一二三四五六七八九十\d]+步', content))
        g4 = any(k in content for k in ["验证", "校验", "verify", "validate", "确认.*通过", "检查.*失败"])
        g5 = any(k in content.lower() for k in ["fallback", "retry", "rollback", "兜底", "降级", "重试", "回退", "备选", "替代方案"])
        d7 = any(k in content for k in ["边界", "不适用", "限制", "limitation", "适用范围", "排除"])
        d8 = any(k in content for k in ["原理", "参考", "理论", "reference", "论文", "来源", "source"])
        d9 = any(k in content for k in ["DS", "DeepSeek", "deepseek", "模型适配", "model", "补偿策略"])
        d10 = any(k in content for k in ["token", "预算", "上下文", "context budget", "体积"])
        
        gates = sum([g1,g2,g3,g4,g5])
        
        results.append({
            "name": name,
            "gates": gates,
            "g1": g1,"g2": g2,"g3": g3,"g4": g4,"g5": g5,
            "d7": d7,"d8": d8,"d9": d9,"d10": d10
        })

g1c = sum(1 for r in results if r["g1"])
g2c = sum(1 for r in results if r["g2"])
g3c = sum(1 for r in results if r["g3"])
g4c = sum(1 for r in results if r["g4"])
g5c = sum(1 for r in results if r["g5"])
d7c = sum(1 for r in results if r["d7"])
d8c = sum(1 for r in results if r["d8"])
d9c = sum(1 for r in results if r["d9"])
d10c = sum(1 for r in results if r["d10"])
all5 = sum(1 for r in results if r["gates"] == 5)
miss1 = sum(1 for r in results if r["gates"] == 4)

print(f"=== Skill Quality Scan ===")
print(f"Total: {total}")
print(f"G1: {g1c} | G2: {g2c} | G3: {g3c} | G4: {g4c} | G5: {g5c}")
print(f"D7: {d7c} | D8: {d8c} | D9: {d9c} | D10: {d10c}")
print(f"5/5 AllGreen: {all5} ({100*all5/total:.1f}%)")
print(f"4/5 Missing1: {miss1} ({100*miss1/total:.1f}%)")

missing_map = Counter()
for r in results:
    if r["gates"] == 4:
        ms = ""
        if not r["g1"]: ms += "G1,"
        if not r["g2"]: ms += "G2,"
        if not r["g3"]: ms += "G3,"
        if not r["g4"]: ms += "G4,"
        if not r["g5"]: ms += "G5,"
        ms = ms.strip(",")
        missing_map[ms] += 1

print("\n--- Missing Gate (4/5) ---")
for k,v in missing_map.most_common():
    print(f"  {k}: {v}")

print("\n--- D-dimension Missing ---")
for k in ["D7","D8","D9","D10"]:
    c = sum(1 for r in results if not r[k.lower()])
    print(f"  {k}: {c}/{total} ({100*c/total:.1f}%)")

with open(r"D:\KnowledgeBase\_meta\skill_gate_scan.json", "w", encoding="utf-8") as f:
    json.dump(results, f, ensure_ascii=False, indent=2)
print(f"\nSaved to skill_gate_scan.json")
