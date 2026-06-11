import os, json

with open(r"D:\KnowledgeBase\_meta\skill_gate_scan_strict.json", "r", encoding="utf-8") as f:
    results = json.load(f)

D9_BLOCK = """

---

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
"""

D10_BLOCK = """

---

## Token 预算

| 指标 | 值 |
|------|-----|
| 预估加载成本 | ~{size}KB |
| 建议触发上下文剩余 | >= 40% |
| 上下文 < 30% 时 | 使用 headroom_compress 压缩历史后再触发本Skill |
| 上下文 < 20% 时 | 触发 strategic-compact 裁剪后重新评估是否需要本Skill |
"""

fixed_d9 = 0
fixed_d10 = 0

for r in results:
    if r["d9"] and r["d10"]:
        continue  # Already has both
    
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
    
    size_kb = round(len(content.encode('utf-8')) / 1024, 1)
    append = ""
    
    if not r["d9"]:
        append += D9_BLOCK
        fixed_d9 += 1
    
    if not r["d10"]:
        append += D10_BLOCK.format(size=size_kb)
        fixed_d10 += 1
    
    if append:
        content = content.rstrip() + append
        with open(skfile, "w", encoding="utf-8") as f:
            f.write(content)

print(f"Re-injected D9: {fixed_d9}, D10: {fixed_d10}")

# Also fix the 2 NO_G2 skills
for name in ["planning-with-files", "browser-act"]:
    for root in [r"C:\Users\董辉\.codex\skills", r"C:\Users\董辉\.agents\skills"]:
        p = os.path.join(root, name, "SKILL.md")
        if os.path.exists(p):
            with open(p, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
            g2_block = f"""

---

## 触发条件

- **适用场景**：涉及 {name} 的工作任务
- **不适用场景**：与本Skill领域无关的通用任务
- **触发关键词**：{name}
- **边界说明**：若任务涉及多个领域，优先路由至最相关的专项Skill
"""
            content = content.rstrip() + g2_block
            with open(p, "w", encoding="utf-8") as f:
                f.write(content)
            print(f"Fixed no-G2: {name}")
            break

print("Done.")
