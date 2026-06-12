import os
output = []
for name in ['planning-with-files', 'browser-act']:
    for root in [r'C:\Users\董辉\.codex\skills', r'C:\Users\董辉\.agents\skills']:
        p = os.path.join(root, name, 'SKILL.md')
        if os.path.exists(p):
            with open(p, 'r', encoding='utf-8', errors='ignore') as f:
                c = f.read().replace('\ufeff', '')
            head = c[:3000].lower()
            has_trigger = any(k in head for k in ['trigger', 'description', 'when to use'])
            has_boundary = any(k in head for k in ['exclude', 'boundary', 'limitation', 'not for', 'don'])
            output.append(f"{name}: size={len(c)} trigger={has_trigger} boundary={has_boundary} file={p}")
            break
with open(r"D:\KnowledgeBase\_meta\g2_debug.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(output))
print("Done - check g2_debug.txt")
