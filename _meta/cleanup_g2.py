import os, re

roots = [
    r"C:\Users\董辉\.codex\skills",
    r"C:\Users\董辉\.agents\skills"
]

g2_fixed_dup = 0
g2_fixed_miss = 0

for root in roots:
    if not os.path.exists(root): continue
    for name in os.listdir(root):
        if name.startswith("."): continue
        p = os.path.join(root, name, "SKILL.md")
        if not os.path.exists(p): continue
        
        with open(p, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        
        g2_count = content.count("触发条件")
        
        if g2_count > 1:
            # Remove duplicate G2 blocks - keep the first one, remove subsequent ones
            # Find all G2 block positions
            positions = [m.start() for m in re.finditer("触发条件", content)]
            # Keep first, remove others
            new_content = content[:positions[1]]  # everything before second G2
            # Remove all content from second G2 onwards that starts with ## 触发条件
            # Actually, simpler: split on "---" before each subsequent G2 block
            # Find the "---" that precedes the second G2
            search_start = positions[1] - 200
            if search_start < 0: search_start = 0
            dash_pos = content.rfind("---", search_start, positions[1])
            if dash_pos >= 0:
                new_content = content[:dash_pos].rstrip()
            else:
                new_content = content[:positions[1]].rstrip()
            
            with open(p, "w", encoding="utf-8") as f:
                f.write(new_content)
            g2_fixed_dup += 1
            print(f"DEDUP G2: {name}")
        
        elif g2_count == 0:
            # Append G2 block
            g2_block = f'''

---

## 触发条件

- **适用场景**：涉及 {name} 的工作任务
- **不适用场景**：与本Skill领域无关的通用任务，或已有其他专项Skill覆盖的任务
- **触发关键词**：{name}
- **边界说明**：若任务涉及多个领域，优先路由至最相关的专项Skill
'''
            content = content.rstrip() + g2_block
            with open(p, "w", encoding="utf-8") as f:
                f.write(content)
            g2_fixed_miss += 1
            print(f"ADD G2: {name}")

print(f"\nG2 duplicates fixed: {g2_fixed_dup}")
print(f"G2 missing fixed: {g2_fixed_miss}")
