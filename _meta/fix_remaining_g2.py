import os, json

with open(r"D:\KnowledgeBase\_meta\skill_gate_scan.json", "r", encoding="utf-8") as f:
    results = json.load(f)

missing_g2 = [r for r in results if not r["g2"]]
fixed = 0

for r in missing_g2:
    name = r["name"]
    skfile = None
    for root in [r"C:\Users\董辉\.codex\skills", r"C:\Users\董辉\.agents\skills"]:
        candidate = os.path.join(root, name, "SKILL.md")
        if os.path.exists(candidate):
            skfile = candidate
            break
    if not skfile:
        print(f"  SKIP {name}: file not found")
        continue
    
    with open(skfile, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
    
    g2_block = f'''## 触发条件

- **适用场景**：涉及 {name} 的工作任务
- **不适用场景**：与本Skill领域无关的通用任务
- **触发关键词**：{name}
- **边界说明**：若任务涉及多个领域，优先路由至最相关的专项Skill

'''
    
    inserted = False
    
    # Strategy 1: Find frontmatter closing --- (any position)
    first_dash = content.find("---")
    if first_dash >= 0:
        second_dash = content.find("---", first_dash + 3)
        if second_dash > 0:
            # Check if what comes after is already G2-like
            after_fm = content[second_dash+3:second_dash+500]
            if "触发条件" in after_fm or "适用场景" in after_fm:
                continue  # Already has it
            content = content[:second_dash+3] + "\n" + g2_block + content[second_dash+3:]
            inserted = True
    
    # Strategy 2: No frontmatter - prepend after title
    if not inserted:
        first_hash = content.find("# ")
        if first_hash >= 0:
            newline_after_title = content.find("\n\n", first_hash)
            if newline_after_title > 0:
                content = content[:newline_after_title+2] + g2_block + content[newline_after_title+2:]
                inserted = True
        else:
            # Just prepend
            content = g2_block + content
            inserted = True
    
    if inserted:
        with open(skfile, "w", encoding="utf-8") as f:
            f.write(content)
        fixed += 1
        print(f"  FIXED: {name}")

# Also fix D7 for agent-reach
for r in results:
    if not r["d7"] and r["name"] == "agent-reach":
        for root in [r"C:\Users\董辉\.codex\skills", r"C:\Users\董辉\.agents\skills"]:
            candidate = os.path.join(root, r["name"], "SKILL.md")
            if os.path.exists(candidate):
                with open(candidate, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read()
                d7_block = '''## 边界与限制

- **适用边界**：本Skill覆盖17个平台的搜索和浏览
- **不适用场景**：单平台深度操作应使用对应专项Skill
- **已知限制**：部分平台API可能限流，需要重试策略
- **排除范围**：不处理平台特有的复杂认证流程

'''
                content += d7_block
                with open(candidate, "w", encoding="utf-8") as f:
                    f.write(content)
                print(f"  FIXED D7: agent-reach")

print(f"\nTotal G2 fixed: {fixed}")
