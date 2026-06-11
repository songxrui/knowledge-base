import json, os, time

# 10维度评测 traffic-engineering skill
# 基于 skill-review v3.0 框架

skill_path = r"C:\Users\董辉\.codex\skills\traffic-engineering"
skill_md_path = os.path.join(skill_path, "SKILL.md")

with open(skill_md_path, "r", encoding="utf-8") as f:
    content = f.read()

# 获取参考文件
refs = {}
ref_dir = os.path.join(skill_path, "references")
for fname in os.listdir(ref_dir):
    fpath = os.path.join(ref_dir, fname)
    try:
        with open(fpath, "r", encoding="utf-8") as f:
            refs[fname] = f.read()
    except:
        pass

total_size = len(content.encode("utf-8"))
ref_sizes = {k: len(v.encode("utf-8")) for k, v in refs.items()}

print(f"SKILL.md: {total_size} bytes")
for k, v in ref_sizes.items():
    print(f"  refs/{k}: {v} bytes")

# Scoring
scores = {}

# D1: 触发层描述特异性 (10%)
# 检查: description 字段是否含适用/不适用/关键词/边界/正反例
has_when = "何时使用" in content or "when" in content.lower()
has_not_when = "不使用" in content or "not use" in content.lower()
has_keywords = len([l for l in content.split("\n") if "触发" in l or "关键词" in l]) >= 2
has_boundary = "→" in content and "skill" in content  # 指向相邻skill

d1 = 0
if has_when: d1 += 3
if has_not_when: d1 += 3
if has_keywords: d1 += 2
if has_boundary: d1 += 2
scores["D1_trigger_specificity"] = d1

# D2: 文档结构完整度 (10%)
has_frontmatter = content.startswith("---")
has_body_sections = content.count("## ") >= 3
has_references_files = len(refs) >= 2
has_agents_yaml = os.path.exists(os.path.join(skill_path, "agents", "openai.yaml"))

d2 = 0
if has_frontmatter: d2 += 3
if has_body_sections: d2 += 3
if has_references_files: d2 += 2
if has_agents_yaml: d2 += 2
scores["D2_structure"] = d2

# D3: 可执行性 (15%)
has_boolean_checks = "布尔" in content
has_phase_routing = "→" in content and "Phase" in content
has_step_sequence = content.count("Phase") >= 4
has_detection_commands = "rg " in content or "检测" in content

d3 = 0
if has_boolean_checks: d3 += 4
if has_phase_routing: d3 += 4
if has_step_sequence: d3 += 4
if has_detection_commands: d3 += 3
scores["D3_executability"] = d3

# D4: 验证闭环 (10%)
has_scoring_rubric = "分" in content and "评级" in content
has_output_format = "输出格式" in content
has_verification_commands = "rg " in content
has_example = "example.md" in refs

d4 = 0
if has_scoring_rubric: d4 += 3
if has_output_format: d4 += 3
if has_verification_commands: d4 += 2
if has_example: d4 += 2
scores["D4_verification"] = d4

# D5: 平台兼容性 (10%)
platforms = ["小红书", "抖音", "公众号", "X", "Codex", "PowerShell", "Windows"]
mentioned = sum(1 for p in platforms if p in content)
d5 = min(10, mentioned * 2)
scores["D5_platform_compat"] = d5

# D6: 证据锚定 (10%)
has_academic_refs = "et al" in content or "199" in content or "201" in content
has_source_tiers = "确认" in content and "推断" in content
has_anti_fabrication = "禁止编造" in content or "不得伪造" in content
d6 = 0
if has_academic_refs: d6 += 4
if has_source_tiers: d6 += 3
if has_anti_fabrication: d6 += 3
scores["D6_evidence"] = d6

# D7: 失败处理 (10%)
has_failure_table = "失败模式" in content
has_fallback = "解法" in content and ("Phase" in content or "→" in content)
has_uncertainty = "不确定" in content or "推断" in content
d7 = 0
if has_failure_table: d7 += 4
if has_fallback: d7 += 3
if has_uncertainty: d7 += 3
scores["D7_failure_handling"] = d7

# D8: 资源效率 (5%)
body_size = total_size - len(content.split("---\n", 2)[0].encode("utf-8"))
refs_total = sum(ref_sizes.values())
d8 = 10 if body_size < 8000 else (8 if body_size < 12000 else 5)
scores["D8_efficiency"] = d8

# D9: AI味抵抗 (10%)
banned_words = ["赋能", "抓手", "闭环", "底层逻辑", "综上所述", "众所周知", "值得注意的是", "空壳排比"]
banned_hits = sum(1 for w in banned_words if w in content)
has_three_para_opening = "首先" in content[:500] and "其次" in content[:500]
d9 = 10 if banned_hits == 0 and not has_three_para_opening else (8 if banned_hits <= 1 else 4)
scores["D9_ai_flavor_resist"] = d9

# D10: 大小 (5%)
d10 = 10 if total_size < 8000 else (9 if total_size < 10000 else (7 if total_size < 15000 else 5))
scores["D10_size"] = d10

# Weighted total
weights = {"D1_trigger_specificity": 10, "D2_structure": 10, "D3_executability": 15, 
           "D4_verification": 10, "D5_platform_compat": 10, "D6_evidence": 10,
           "D7_failure_handling": 10, "D8_efficiency": 5, "D9_ai_flavor_resist": 10, "D10_size": 5}

total = sum(scores[k] * weights[k] / 100 for k in scores)
max_possible = sum(v * weights[k] / 100 for k, v in scores.items())

print("\n=== Round 1 Evaluation ===")
for k, v in scores.items():
    w = weights[k]
    print(f"  {k}: {v}/10 (weight={w}%, weighted={v*w/100:.1f})")
print(f"\n  TOTAL: {total:.1f}/100")

# Grade
if total >= 85: grade = "S"
elif total >= 75: grade = "A"
elif total >= 65: grade = "B"
elif total >= 55: grade = "C"
else: grade = "D"
print(f"  GRADE: {grade}")

# Issues found
issues = []
if d1 < 8: issues.append("D1: 触发层缺少不适用场景的具体反例")
if d3 < 13: issues.append("D3: 可执行性可增强——添加更多 rg 检测命令")
if d5 < 10: issues.append("D5: 平台兼容性——未显式提及Windows/PowerShell/Codex约束")
if d8 < 7: issues.append("D8: Body大小接近上限，考虑进一步压缩")
if d10 < 8: issues.append("D10: 文件大小超标")

print("\nIssues found:")
for i in issues:
    print(f"  - {i}")
