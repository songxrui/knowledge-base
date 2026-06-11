import os

BASE_CARDS = r"D:\KnowledgeBase\cards\topics"

xref_text = """---

## Stanley框架交叉引用 [Skill: dbs-content + humanizer-zh]

Stanley在《流量的本质与暴力》中与本卡互补的框架：

- **HKR的完整上下文**：本卡的HKR来自Stanley的实战体系。完整的Stanley HKR还包含Hook(前0.5秒的注意力钩子)、Key Content(扫描模式下的信息密度)、Resonance(替用户翻译说不清楚的感受)三个子维度。
- **输出密度>输出频率**：一年100篇走心深度内容，胜过三年3650篇水文。与本卡的"100篇练习"建议互相印证。
- **两级传播理论**：与其触达100万普通人，不如触达1000个意见领袖。注意力不是"买来的"，是"赢来的"。
- **GEO新入口**：AI时代的流量新入口是成为AI的"引用来源"。本卡中讨论的"AI能否替代人类创作者"问题，答案取决于你的内容是否能成为AI引用的原始信源。

> 互补点：本卡从内容质量维度分析HKR，Stanley从传播战略维度设计完整的流量获取系统——两者结合形成"做好内容+做好传播"的完整闭环。

---

> **Skill链**: dbs-content(交叉引用诊断) → humanizer-zh → compile-and-verify(终检)
"""

targets = ["T8-01_流量本质.md", "T8-03_HKR内容公式.md", "T8-04_平台依赖症.md"]

for fname in targets:
    filepath = os.path.join(BASE_CARDS, fname)
    if not os.path.exists(filepath):
        print(f"MISSING: {fname}")
        continue
    
    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
    
    if "Stanley框架交叉引用" in content:
        print(f"SKIP: {fname}")
        continue
    
    content = content.rstrip() + "\n" + xref_text
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"ENHANCED: {fname}")

print("Done.")
