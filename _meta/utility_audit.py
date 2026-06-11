import os

# Test: check if the injected blocks have real utility
# Sample skills from both dirs
test_skills = ["humanizer", "article-writing", "dbs-content", "agent-reach"]

for name in test_skills:
    for root in [r"C:\Users\董辉\.codex\skills", r"C:\Users\董辉\.agents\skills"]:
        p = os.path.join(root, name, "SKILL.md")
        if os.path.exists(p):
            with open(p, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
            
            # Extract the last ~3KB (where D9/D10/G5 blocks should be)
            tail = content[-3000:] if len(content) > 3000 else content
            
            # Check for substantive content vs empty template
            d9_block = tail.find("DS v4 Pro 适配说明")
            d10_block = tail.find("Token 预算")
            g2_block = content[:3000].find("触发条件")  # G2 should be near start
            
            has_d9_table = "| 维度 |" in tail[d9_block:d9_block+500] if d9_block >= 0 else False
            has_d10_cost = "预估加载成本" in tail[d10_block:d10_block+300] if d10_block >= 0 else False
            has_g2_scenario = "适用场景" in content[g2_block:g2_block+300] if g2_block >= 0 else False
            
            print(f"{name}: D9={d9_block>=0}(table={has_d9_table}) D10={d10_block>=0}(cost={has_d10_cost}) G2={g2_block>=0}(scenario={has_g2_scenario})")
            break

print("\n--- Utility Audit ---")
# Check a few skills for empty/incomplete injected blocks
issues = []
for root in [r"C:\Users\董辉\.codex\skills", r"C:\Users\董辉\.agents\skills"]:
    if not os.path.exists(root): continue
    for name in os.listdir(root)[:50]:  # Sample 50
        if name.startswith("."): continue
        p = os.path.join(root, name, "SKILL.md")
        if not os.path.exists(p): continue
        with open(p, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        
        # Check if D9 block has all 5 rows
        d9_pos = content.find("DS v4 Pro 适配说明")
        if d9_pos >= 0:
            d9_section = content[d9_pos:d9_pos+1200]
            row_count = d9_section.count("|") // 3  # rough estimate
            if row_count < 12:  # Less than 4 data rows + header
                issues.append(f"{name}: D9 incomplete ({row_count//4} rows)")
        
        # Check if D10 has cost estimate
        d10_pos = content.find("Token 预算")
        if d10_pos >= 0:
            d10_section = content[d10_pos:d10_pos+300]
            if "预估加载成本" not in d10_section:
                issues.append(f"{name}: D10 missing cost estimate")

if issues:
    print(f"\nIncomplete blocks ({len(issues)}):")
    for i in issues[:10]:
        print(f"  - {i}")
else:
    print("\nAll sampled skills have complete D9/D10 blocks.")
