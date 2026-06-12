import os

BASE = r"D:\KnowledgeBase\media\wechat_2026-06-07"

# Define complement texts
complements = {
    "W06": "Ben Wen cong ren zhi ke xue jiao du lun zheng zhu yi li de shen jing ji zhi, Stanley cong jing ji xue jiao du lun zheng qi xi que xing",
    "W128": "Ben Wen de HKR gong shi shi nei rong ceng mian de cao zuo kuang jia, Stanley de zhu yi li qie pian shi liu liang ceng mian de zhan lve kuang jia",
    "W132": "Ben Wen cong ge ren xiao lv jiao du guan li zhu yi li, Stanley cong chuang zuo zhe jiao du huo qu zhu yi li",
    "W127": "Ben Wen zhen duan nei rong wei shi me si, Stanley zhen duan liu liang wei shi me lai",
}

xref_template = """---

## Stanley框架交叉引用 [Skill: dbs-content + humanizer-zh]

Stanley在《@@@@》中提出了与本文高度互补的框架。@@@@

> 本文与Stanley框架的互补点：{complement}

---

> **Skill链**: dbs-content(交叉引用诊断) → humanizer-zh → compile-and-verify(终检)
"""

for prefix, complement in complements.items():
    # Find matching file
    for f in os.listdir(BASE):
        if f.startswith(prefix + "_"):
            filepath = os.path.join(BASE, f)
            break
    else:
        print(f"MISSING: {prefix}")
        continue
    
    with open(filepath, "r", encoding="utf-8", errors="ignore") as fh:
        content = fh.read()
    
    if "Stanley" in content.split("\n")[-20:]:  # Already in last 20 lines
        print(f"SKIP: {f}")
        continue
    
    xref = xref_template.replace("{complement}", complement)
    xref = xref.replace("@@@@", "流量的本质与暴力")
    xref = xref.replace("@@@@", "本文从认知科学角度论证注意力的神经机制，Stanley从经济学角度论证其稀缺性。输出密度大于输出频率，自有阵地优于平台账号，两级传播优于广撒网。")
    
    content = content.rstrip() + "\n" + xref
    with open(filepath, "w", encoding="utf-8") as fh:
        fh.write(content)
    print(f"ENHANCED: {f}")

print("Done.")
