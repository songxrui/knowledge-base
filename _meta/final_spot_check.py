import os, re, random

roots = [
    r"C:\Users\董辉\.codex\skills",
    r"C:\Users\董辉\.agents\skills"
]

random.seed(99999)
all_skills = []
for root in roots:
    if not os.path.exists(root): continue
    for name in os.listdir(root):
        if name.startswith("."): continue
        p = os.path.join(root, name, "SKILL.md")
        if os.path.exists(p):
            all_skills.append((name, root, p))

sample = random.sample(all_skills, 20)

results = []
pass_count = 0
issues = []

for name, root, skfile in sample:
    with open(skfile, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
    
    size_kb = round(len(content.encode('utf-8')) / 1024, 1)
    root_label = "codex" if "codex" in root else "agents"
    
    checks = {
        "D9_block": "DS v4 Pro 适配说明" in content,
        "D9_table": "| 维度 | DS v4 Pro 表现 | 补偿策略 |" in content,
        "D10_block": "Token 预算" in content,
        "D10_estimate": bool(re.search(r'~\d+\.?\d*KB', content)),
        "G2_block": "触发条件" in content,
        "G2_scenario": "适用场景" in content,
        "G5_block": ("fallback" in content.lower() or "兜底" in content or "重试" in content or "降级" in content or "回退" in content),
        "D9_nodup": content.count("DS v4 Pro 适配说明") == 1,
        "D10_nodup": content.count("Token 预算") == 1,
        "G2_nodup": content.count("触发条件") <= 1  # Allow 0 for skills with native trigger
    }
    
    all_ok = all(checks.values())
    if all_ok:
        pass_count += 1
    
    problems = [k for k,v in checks.items() if not v]
    if problems:
        issues.append(f"{name} ({root_label}): {problems}")
    
    results.append((name, root_label, size_kb, all_ok))

print(f"=== Final Spot Check (n=20) ===")
for name, rl, sz, ok in results:
    status = "PASS" if ok else "FAIL"
    print(f"  {status}: {name} ({rl}) {sz}KB")

print(f"\nClean: {pass_count}/20 ({100*pass_count/20:.0f}%)")
if issues:
    print(f"\nIssues found:")
    for i in issues:
        print(f"  - {i}")
