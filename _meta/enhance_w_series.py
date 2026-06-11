import os

BASE = r"D:\KnowledgeBase\media\wechat_2026-06-07"

xref = """---

## Stanley框架交叉引用 [Skill: dbs-content + humanizer-zh]

Stanley在《流量的本质与暴力》中的核心框架与本文直接互补：

- **流量是注意力切片**：每个流量=真实的人在真实时刻的0.3秒到数分钟注意力。这是地球上最稀缺、最不可再生的资源。
- **输出密度>输出频率**：一年100篇走心深度内容，胜过三年3650篇水文。
- **自有阵地优先**：网站、邮件列表、私域社群是资产，平台账号只是租来的展示位。
- **两级传播**：与其触达100万普通人，不如触达1000个意见领袖。
- **GEO新入口**：AI时代的流量入口是成为AI助手的"引用来源"。

> 互补点：本文从创作实践角度出发，Stanley从传播经济学角度出发——两者结合形成完整的"创作+传播"系统。

---

> **Skill链**: dbs-content(交叉引用诊断) → humanizer-zh → compile-and-verify(终检)
"""

# Directly related to Stanley framework
targets = [
    "W139_流量本质与HKR.md",      # Direct topic match
    "W03_一人企业MVP不是产品.md",    # 自有阵地 concept
    "W30_从100篇内容到一人企业.md",  # 100篇定律
    "W81_朋友圈注意力资产.md",       # Attention as asset
    "W94_个人IP不是打造的.md",       # IP concepts
    "W105_内容即实验日志.md",        # Real record asset
]

for fname in targets:
    filepath = os.path.join(BASE, fname)
    if not os.path.exists(filepath):
        print(f"MISSING: {fname}")
        continue
    
    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
    
    if "Stanley框架交叉引用" in content:
        print(f"SKIP: {fname}")
        continue
    
    content = content.rstrip() + "\n" + xref
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"ENHANCED: {fname}")

print("Done.")
