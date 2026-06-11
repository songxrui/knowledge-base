import os

names = ["compile-and-verify", "planning-with-files", "browser-act", 
         "dbs-ai-check", "dbs-content", "dbs-diagnosis", "dbs-hook", "dbs-xhs-title"]

G5_BLOCK = """

---

## 失败处理与兜底

| 失败场景 | 兜底策略 |
|---------|---------|
| 工具调用失败 | 重试最多3次，每次更换参数格式 |
| 输入不完整 | 追问关键缺失信息，不猜测执行 |
| 执行超时 | 降级为简化版输出 + 标注[部分完成] |
| 结果验证失败 | 回退至上一步 + 更换执行路径 |
"""

fixed = 0
for name in names:
    for root in [r"C:\Users\董辉\.codex\skills", r"C:\Users\董辉\.agents\skills"]:
        p = os.path.join(root, name, "SKILL.md")
        if os.path.exists(p):
            with open(p, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
            if "失败处理" in content or "兜底" in content or "fallback" in content.lower():
                continue  # Already has it
            content = content.rstrip() + G5_BLOCK
            with open(p, "w", encoding="utf-8") as f:
                f.write(content)
            fixed += 1
            print(f"Fixed G5: {name}")
            break

print(f"\nTotal G5 fixed: {fixed}")
