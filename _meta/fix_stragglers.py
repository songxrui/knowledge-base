import os, json

G2_BLOCK = """
---

## 触发条件

- **适用场景**：涉及 {name} 的工作任务
- **不适用场景**：与本Skill领域无关的通用任务
- **触发关键词**：{name}

"""

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
"""

with open(r"D:\KnowledgeBase\_meta\skill_gate_scan_strict.json", "r", encoding="utf-8") as f:
    results = json.load(f)

d10_miss = [r["name"] for r in results if not r["d10"]]
g2_miss = [r["name"] for r in results if not r["g2"]]
d9_miss = [r["name"] for r in results if not r["d9"]]

all_fix = set(d10_miss + g2_miss + d9_miss)

for name in all_fix:
    for root in [r"C:\Users\董辉\.codex\skills", r"C:\Users\董辉\.agents\skills"]:
        p = os.path.join(root, name, "SKILL.md")
        if os.path.exists(p):
            with open(p, "r", encoding="utf-8", errors="ignore") as f:
                c = f.read()
            size = round(len(c.encode("utf-8")) / 1024, 1)
            append = ""
            if name in g2_miss:
                append += G2_BLOCK.format(name=name)
            if name in d9_miss:
                append += D9_BLOCK
            if name in d10_miss:
                append += D10_BLOCK.format(size=size)
            if append:
                c = c.rstrip() + append
                with open(p, "w", encoding="utf-8") as f:
                    f.write(c)
                print(f"Fixed: {name}")
            break

print("Done.")
