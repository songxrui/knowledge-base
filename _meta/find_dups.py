import os, re

roots = [
    r"C:\Users\董辉\.codex\skills",
    r"C:\Users\董辉\.agents\skills"
]

# Count all duplications
d9_dups = 0
d10_dups = 0
g2_dups = 0
no_g2 = 0
total = 0

for root in roots:
    if not os.path.exists(root): continue
    for name in os.listdir(root):
        if name.startswith("."): continue
        p = os.path.join(root, name, "SKILL.md")
        if not os.path.exists(p): continue
        total += 1
        with open(p, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        
        d9c = content.count("DS v4 Pro 适配说明")
        d10c = content.count("Token 预算")
        g2c = content.count("触发条件")
        
        if d9c > 1: 
            d9_dups += 1
            print(f"D9_DUP: {name} ({d9c}x)")
        if d10c > 1: 
            d10_dups += 1
            print(f"D10_DUP: {name} ({d10c}x)")
        if g2c > 1: 
            g2_dups += 1
            print(f"G2_DUP: {name} ({g2c}x)")
        if g2c == 0: 
            no_g2 += 1
            print(f"NO_G2: {name}")

print(f"\nTotal: {total} | D9 dups: {d9_dups} | D10 dups: {d10_dups} | G2 dups: {g2_dups} | No G2: {no_g2}")
