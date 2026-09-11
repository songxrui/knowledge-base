import os, re, random

roots = [
    r"C:\Users\董辉\.codex\skills",
    r"C:\Users\董辉\.agents\skills"
]

random.seed(67890)
all_skills = []
for root in roots:
    if not os.path.exists(root): continue
    for name in os.listdir(root):
        if name.startswith("."): continue
        p = os.path.join(root, name, "SKILL.md")
        if os.path.exists(p):
            all_skills.append((name, root, p))

sample = random.sample(all_skills, min(15, len(all_skills)))

issues = []
pass_count = 0
dup_count = 0

for name, root, skfile in sample:
    with open(skfile, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
    
    size_kb = round(len(content.encode('utf-8')) / 1024, 1)
    problems = []
    
    # Check D9
    d9_count = content.count("DS v4 Pro 适配说明")
    if d9_count == 0: problems.append("NO_D9_BLOCK")
    elif d9_count > 1: problems.append(f"D9_DUP({d9_count})")
    
    # Check D10
    d10_count = content.count("Token 预算")
    if d10_count == 0: problems.append("NO_D10_BLOCK")
    elif d10_count > 1: problems.append(f"D10_DUP({d10_count})")
    
    # Check G2
    g2_count = content.count("触发条件")
    if g2_count == 0: problems.append("NO_G2_BLOCK")
    elif g2_count > 1: problems.append(f"G2_DUP({g2_count})")
    
    # Check for trailing --- artifacts
    has_trailing_dash = content.rstrip().endswith("---")
    
    # Check for garbled
    garbled = bool(re.search(r'[姘村钩搴﹀寲寮€鍙戦棬绂佽Е瑙︽柊]', content))
    
    root_label = "codex" if "codex" in root else "agents"
    
    if not problems:
        pass_count += 1
        print(f"  PASS: {name} ({root_label}) {size_kb}KB")
    else:
        dup_count += len([p for p in problems if "DUP" in p])
        print(f"  ISSUE: {name} ({root_label}) {size_kb}KB -> {', '.join(problems)}")

print(f"\nClean: {pass_count}/{len(sample)}")
print(f"Duplications found: {dup_count}")
