import os

FULL_D9_BLOCK = """## DS v4 Pro 适配说明

> 本Skill在DeepSeek v4 Pro环境下运行，以下为已知补偿策略。

| 维度 | DS v4 Pro 表现 | 补偿策略 |
|------|---------------|---------|
| 指令遵循 | 复杂多步指令可能漏步 | 每步编号 + 完成后确认 |
| 长上下文 | 64K+后精度下降 | headroom 压缩 + strategic-compact 裁剪 |
| 工具调用 | 偶有参数格式错误 | compile-and-verify 事后校验 |
| 推理深度 | 中等复杂度可靠，极高复杂度需分解 | 多agent分解 + sequential-thinking |
| 幻觉倾向 | 不确定时可能猜测 | 强制标注"推断/待核实" + exa/deep-research 库外验证 |

**DS 指令风格**：显式 > 隐式 | 编号 > 段落 | 确认 > 假设 | 分解 > 合并 | 先搜 > 先猜
"""

fixed = 0
for root in [r"C:\Users\董辉\.codex\skills", r"C:\Users\董辉\.agents\skills"]:
    if not os.path.exists(root): continue
    for name in os.listdir(root):
        if name.startswith("."): continue
        p = os.path.join(root, name, "SKILL.md")
        if not os.path.exists(p): continue
        
        with open(p, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        
        d9_pos = content.find("DS v4 Pro 适配说明")
        if d9_pos < 0: continue
        
        # Check if D9 block is complete (has all 5 dimension rows)
        d9_end = content.find("---", d9_pos + 10) if content.find("---", d9_pos + 10) > 0 else len(content)
        d9_section = content[d9_pos:min(d9_end, d9_pos + 1500)]
        
        # Count actual data rows (lines with | ... | ... | ... |)
        data_rows = [l for l in d9_section.split('\n') if l.count('|') >= 4 and not l.strip().startswith('|-')]
        
        if len(data_rows) < 7:  # header + separator + 5 data rows = 7
            # Block is incomplete - replace it
            old_block = d9_section
            # Find the actual end of this incomplete block (next --- or next ##)
            next_section = content.find("\n---", d9_pos + 20)
            if next_section < 0:
                next_section = content.find("\n##", d9_pos + 20)
            if next_section < 0:
                next_section = len(content)
            
            content = content[:d9_pos] + FULL_D9_BLOCK + "\n" + content[next_section:]
            with open(p, "w", encoding="utf-8") as f:
                f.write(content)
            fixed += 1
            print(f"Fixed D9: {name} ({len(data_rows)} -> 7 rows)")

print(f"\nTotal D9 blocks repaired: {fixed}")
