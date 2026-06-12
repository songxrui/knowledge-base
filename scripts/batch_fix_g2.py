import os, re, json

with open(r"D:\KnowledgeBase\_meta\skill_gate_scan.json", "r", encoding="utf-8") as f:
    results = json.load(f)

g2_fixed = 0
skipped = 0

for r in results:
    if r["g2"]:
        skipped += 1
        continue
    
    name = r["name"]
    skfile = None
    for root in [r"C:\Users\董辉\.codex\skills", r"C:\Users\董辉\.agents\skills"]:
        candidate = os.path.join(root, name, "SKILL.md")
        if os.path.exists(candidate):
            skfile = candidate
            break
    if not skfile:
        continue
    
    with open(skfile, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
    
    # Extract purpose from content (first meaningful line after frontmatter)
    lines = content.split('\n')
    purpose = ""
    in_frontmatter = False
    fm_closed = False
    for line in lines:
        stripped = line.strip()
        if stripped == "---":
            if not in_frontmatter:
                in_frontmatter = True
                continue
            elif in_frontmatter and not fm_closed:
                fm_closed = True
                in_frontmatter = False
                continue
            else:
                continue
        if in_frontmatter:
            if "description:" in stripped.lower():
                purpose = stripped.split(":", 1)[1].strip()
                break
        if fm_closed and stripped and not stripped.startswith("# "):
            purpose = stripped[:200]
            break
    
    if not purpose:
        purpose = f"与 {name} 相关的专业任务处理"
    
    # Clean purpose
    purpose = purpose.replace('"', "'").replace('|', '/')[:200]
    
    # Generate G2 block
    g2_block = f'''

## 触发条件

- **适用场景**：涉及 {name} 的工作任务
- **不适用场景**：与本Skill领域无关的通用任务，或已有其他专项Skill覆盖的任务
- **触发关键词**：{name}
- **边界说明**：若任务涉及多个领域，优先路由至最相关的专项Skill

> 核心用途：{purpose}
'''
    
    # Insert after frontmatter closing ---
    fm_end = content.find("---", content.find("---") + 3)
    if fm_end > 0 and fm_end < 800:
        content = content[:fm_end+3] + g2_block + content[fm_end+3:]
        g2_fixed += 1
        
        with open(skfile, "w", encoding="utf-8") as f:
            f.write(content)

print(f"G2 (触发条件) 轻量注入: {g2_fixed}")
print(f"已跳过(已有G2): {skipped}")
