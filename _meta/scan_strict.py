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
        
        g1 = "---" in content[:100] or content.startswith("# ")
        
        # STRICT G2: must have both a trigger block AND boundary block
        g2_trigger = "触发条件" in content or "适用场景" in content
        g2_boundary = "不适用" in content or "不适合" in content or "排除" in content
        g2 = g2_trigger and g2_boundary
        
        g3 = bool(re.search(r'\d+[\.\)、]|Step\s*\d|Phase\s*\d|第[一二三四五六七八九十\d]+步', content))
        g4 = "验证" in content or "verify" in content.lower() or "validate" in content.lower()
        g5 = any(k in content.lower() for k in ["fallback", "retry", "rollback", "兜底", "降级", "重试", "回退", "备选"])
        
        # STRICT D7: must have explicit boundary section
        d7 = "边界" in content or "不适用" in content or "限制" in content
        
        # STRICT D8: must have references/sources section
        d8 = "参考" in content or "来源" in content or "reference" in content.lower() or "论文" in content
        
        # STRICT D9: must have DS v4 Pro adaptation BLOCK (not just keyword)
        d9 = "DS v4 Pro 适配" in content or "DS v4 Pro" in content  # actual block title
        
        # STRICT D10: must have Token budget section
        d10 = "Token 预算" in content or "token预算" in content or "上下文预算" in content
        
        gates = sum([g1,g2,g3,g4,g5])
        
        results.append({
            "name": name,
            "gates": gates,
            "g1": g1,"g2": g2,"g3": g3,"g4": g4,"g5": g5,
            "d7": d7,"d8": d8,"d9": d9,"d10": d10
        })

g1c=sum(1 for r in results if r["g1"])
g2c=sum(1 for r in results if r["g2"])
g3c=sum(1 for r in results if r["g3"])
g4c=sum(1 for r in results if r["g4"])
g5c=sum(1 for r in results if r["g5"])
d7c=sum(1 for r in results if r["d7"])
d8c=sum(1 for r in results if r["d8"])
d9c=sum(1 for r in results if r["d9"])
d10c=sum(1 for r in results if r["d10"])
all5=sum(1 for r in results if r["gates"]==5)

print(f"=== STRICT Scan ===")
print(f"Total: {total}")
print(f"G1: {g1c} | G2(STRICT): {g2c} | G3: {g3c} | G4: {g4c} | G5: {g5c}")
print(f"D7: {d7c} | D8: {d8c} | D9(BLOCK): {d9c} | D10(BLOCK): {d10c}")
print(f"5/5 AllGreen(STRICT): {all5} ({100*all5/total:.1f}%)")

# Gap analysis
g2_miss = [r for r in results if r["gates"]==4 and not r["g2"]]
d9_miss = [r for r in results if not r["d9"]]
d10_miss = [r for r in results if not r["d10"]]
g2_miss5 = [r for r in results if not r["g2"]]

print(f"\nG2 missing (any): {len(g2_miss5)}")
print(f"D9 missing (no DS block): {len(d9_miss)}")
print(f"D10 missing (no Token block): {len(d10_miss)}")

# Check overlap: skills missing BOTH D9 and D10
both_miss = [r for r in results if not r["d9"] and not r["d10"]]
print(f"Both D9+D10 missing: {len(both_miss)}")

# Previously claimed 100% D9 but actually missing
false_d9 = [r for r in results if not r["d9"]]
print(f"\nSkills genuinely missing D9 block ({len(false_d9)}):")
for r in false_d9[:15]:
    print(f"  - {r['name']}")
if len(false_d9) > 15:
    print(f"  ... and {len(false_d9)-15} more")

with open(r"D:\KnowledgeBase\_meta\skill_gate_scan_strict.json", "w", encoding="utf-8") as f:
    json.dump(results, f, ensure_ascii=False, indent=2)
