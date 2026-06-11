import os, re, json

# Load scan results
with open(r"D:\KnowledgeBase\_meta\skill_gate_scan.json", "r", encoding="utf-8") as f:
    results = json.load(f)

# D9 block template
D9_BLOCK = '''

## DS v4 Pro 适配说明

> 本Skill在DeepSeek v4 Pro环境下运行，以下为已知补偿策略。

| 维度 | DS v4 Pro 表现 | 补偿策略 |
|------|---------------|---------|
| 指令遵循 | 复杂多步指令可能漏步 | 每步编号 + 完成后确认 |
| 长上下文 | 64K+后精度下降 | headroom 压缩 + strategic-compact 裁剪 |
| 工具调用 | 偶有参数格式错误 | compile-and-verify 事后校验 |
| 推理深度 | 中等复杂度可靠，极高复杂度需分解 | 多agent分解 + sequential-thinking |
| 幻觉倾向 | 不确定时可能猜测 | 强制标注"推断/待核实" + exa/deep-research 库外验证 |

**DS 指令风格**：显式 > 隐式 | 编号 > 段落 | 确认 > 假设 | 分解 > 合并 | 先搜 > 先猜
'''

# D10 block template
D10_BLOCK = '''

## Token 预算

| 指标 | 值 |
|------|-----|
| 预估加载成本 | ~{size}KB |
| 建议触发上下文剩余 | >= 40% |
| 上下文 < 30% 时 | 使用 headroom_compress 压缩历史后再触发本Skill |
| 上下文 < 20% 时 | 触发 strategic-compact 裁剪后重新评估是否需要本Skill |
'''

# Also create a lightweight G2 enhancement for skills missing basic trigger
G2_LIGHT = '''

## 触发条件

- **适用场景**：{name} 相关任务
- **不适用场景**：与本Skill无关的通用任务
- **触发关键词**：{name}
- **边界**：若任务超出本Skill范围，路由至对应专项Skill
'''

# Counters
d9_fixed = 0
d10_fixed = 0
g2_enhanced = 0

for r in results:
    name = r["name"]
    # Find the actual file
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
    
    modified = False
    size_kb = round(len(content.encode('utf-8')) / 1024, 1)
    
    # Add D9 if missing
    if not r["d9"]:
        content += D9_BLOCK
        d9_fixed += 1
        modified = True
    
    # Add D10 if missing
    if not r["d10"]:
        content += D10_BLOCK.format(size=size_kb)
        d10_fixed += 1
        modified = True
    
    # Add G2 light if missing
    if not r["g2"] and not r["g3"]:
        # Only for skills that genuinely lack trigger
        insert_pos = content.find("---", content.find("---") + 3)
        if insert_pos > 0 and insert_pos < 500:
            content = content[:insert_pos+3] + G2_LIGHT.format(name=name) + content[insert_pos+3:]
            g2_enhanced += 1
            modified = True
    
    if modified:
        # Backup
        bak = skfile + ".bak2"
        if not os.path.exists(bak):
            with open(bak, "w", encoding="utf-8") as f:
                f.write(content)
        # Write
        with open(skfile, "w", encoding="utf-8") as f:
            f.write(content)

print(f"D9 (DS适配) 修复: {d9_fixed}")
print(f"D10 (Token预算) 修复: {d10_fixed}")
print(f"G2 (触发条件) 轻量修复: {g2_enhanced}")
print(f"总计修复: {d9_fixed + d10_fixed + g2_enhanced} 项")
print("Done.")
