import os, json, random, re

with open(r"D:\KnowledgeBase\_meta\skill_gate_scan.json", "r", encoding="utf-8") as f:
    results = json.load(f)

# Random sample with seed for reproducibility
random.seed(12345)
sample = random.sample(results, 10)

output_lines = []
output_lines.append("# Skill Content Spot Check Report")
output_lines.append(f"Date: 2026-06-12 | Sample: 10/300")
output_lines.append("")

for r in sample:
    name = r["name"]
    skfile = None
    actual_root = ""
    for root in [r"C:\Users\董辉\.codex\skills", r"C:\Users\董辉\.agents\skills"]:
        candidate = os.path.join(root, name, "SKILL.md")
        if os.path.exists(candidate):
            skfile = candidate
            actual_root = os.path.basename(os.path.dirname(root))
            break
    
    if not skfile:
        output_lines.append(f"## {name} — FILE NOT FOUND")
        continue
    
    with open(skfile, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
    
    size_kb = round(len(content.encode('utf-8')) / 1024, 1)
    
    # Check D9
    d9_pos = content.find("DS v4 Pro 适配")
    d9_has_table = "| 维度 | DS v4 Pro 表现 | 补偿策略 |" in content if d9_pos >= 0 else False
    d9_has_5rows = len(re.findall(r'\| .+ \| .+ \| .+ \|', content[d9_pos:d9_pos+1500] if d9_pos >= 0 else "")) >= 5
    
    # Check D10
    d10_pos = content.find("Token 预算")
    d10_has_table = "| 指标 | 值 |" in content if d10_pos >= 0 else False
    d10_has_estimate = bool(re.search(r'~\d+\.?\d*KB', content[d10_pos:d10_pos+500] if d10_pos >= 0 else ""))
    
    # Check G2
    g2_pos = content.find("触发条件")
    g2_has_scenario = "适用场景" in content[g2_pos:g2_pos+500] if g2_pos >= 0 else False
    g2_has_exclude = any(k in content[g2_pos:g2_pos+500] for k in ["不适用", "不适合", "排除"]) if g2_pos >= 0 else False
    
    # Check for duplication
    d9_count = content.count("DS v4 Pro 适配说明")
    d10_count = content.count("Token 预算")
    g2_count = content.count("触发条件")
    
    # Check for garbled chars
    has_garbled = bool(re.search(r'[鍖栧紑鍙戦棬绂佽Е]', content))  # common garbled patterns
    
    output_lines.append(f"## {name} ({actual_root}) — {size_kb}KB")
    output_lines.append(f"")
    output_lines.append(f"| 检查项 | 状态 | 详情 |")
    output_lines.append(f"|--------|------|------|")
    output_lines.append(f"| D9存在 | {'PASS' if d9_pos >= 0 else 'FAIL'} | pos={d9_pos} |")
    output_lines.append(f"| D9表格 | {'PASS' if d9_has_table else 'FAIL'} | 5列维度表 |")
    output_lines.append(f"| D9行数 | {'PASS' if d9_has_5rows else 'WARN'} | >=5行 |")
    output_lines.append(f"| D10存在 | {'PASS' if d10_pos >= 0 else 'FAIL'} | pos={d10_pos} |")
    output_lines.append(f"| D10表格 | {'PASS' if d10_has_table else 'FAIL'} | 指标/值表 |")
    output_lines.append(f"| D10估算 | {'PASS' if d10_has_estimate else 'WARN'} | ~X.XKB |")
    output_lines.append(f"| G2存在 | {'PASS' if g2_pos >= 0 else 'FAIL'} | pos={g2_pos} |")
    output_lines.append(f"| G2场景 | {'PASS' if g2_has_scenario else 'FAIL'} | 适用场景 |")
    output_lines.append(f"| G2排除 | {'PASS' if g2_has_exclude else 'FAIL'} | 不适用/排除 |")
    output_lines.append(f"| D9重复 | {'WARN' if d9_count > 1 else 'OK'} | 出现{d9_count}次 |")
    output_lines.append(f"| D10重复 | {'WARN' if d10_count > 1 else 'OK'} | 出现{d10_count}次 |")
    output_lines.append(f"| G2重复 | {'WARN' if g2_count > 1 else 'OK'} | 出现{g2_count}次 |")
    output_lines.append(f"| 乱码 | {'WARN' if has_garbled else 'OK'} | |")
    output_lines.append(f"")

# Summary stats
total_checks = len(sample) * 13
pass_count = 0
fail_count = 0
warn_count = 0
for line in output_lines:
    if "| PASS" in line: pass_count += 1
    if "| FAIL" in line: fail_count += 1
    if "| WARN" in line: warn_count += 1

output_lines.append(f"---")
output_lines.append(f"")
output_lines.append(f"## Summary")
output_lines.append(f"")
output_lines.append(f"| Result | Count |")
output_lines.append(f"|--------|-------|")
output_lines.append(f"| PASS | {pass_count} |")
output_lines.append(f"| WARN | {warn_count} |")
output_lines.append(f"| FAIL | {fail_count} |")
output_lines.append(f"| Total | {pass_count + warn_count + fail_count} |")

with open(r"D:\KnowledgeBase\_meta\spot_check_report.md", "w", encoding="utf-8") as f:
    f.write("\n".join(output_lines))

print(f"Spot check complete: {pass_count} PASS / {warn_count} WARN / {fail_count} FAIL")
print(f"Report: D:\\KnowledgeBase\\_meta\\spot_check_report.md")
