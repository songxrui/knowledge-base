import json, os

# Load batch2 extracts
with open(r"D:\KnowledgeBase\_alchemist\weread_extracts\batch2_bookmarks.json", "r", encoding="utf-8") as f:
    extracts = json.load(f)

# Map to chapters based on book topic
chapter_map = {
    "CH04": [],  # 财富商业: 复利效应, 穷查理宝典, 复利投资课, 简单致富
    "CH06": [],  # 顶级人类: 穷查理宝典, 游戏改变人生
    "CH08": [],  # 第一性模型: 穷查理宝典
    "CH02": [],  # 心理健康: 游戏改变人生
    "CH01": [],  # 元能力: 认知觉醒青少年版
}

for e in extracts:
    book = e["book"]
    if "复利" in book or "致富" in book:
        chapter_map["CH04"].append(e)
    if "穷查理" in book or "芒格" in book:
        chapter_map["CH04"].append(e)
        chapter_map["CH06"].append(e)
        chapter_map["CH08"].append(e)
    if "游戏" in book:
        chapter_map["CH02"].append(e)
        chapter_map["CH06"].append(e)
    if "认知觉醒" in book and "青少年" in book:
        chapter_map["CH01"].append(e)

# Enrich chapters
BASE = r"D:\KnowledgeBase\media\flagship\book-v7"
ch_files = {
    "CH01": "CH01_meta-abilities.md",
    "CH02": "CH02_mental-health.md",
    "CH03": "CH03_physical-health.md",
    "CH04": "CH04_wealth-business.md",
    "CH06": "CH06_top-humans.md",
    "CH08": "CH08_first-principles.md",
}

for ch, items in chapter_map.items():
    if not items or ch not in ch_files:
        continue
    
    fname = ch_files[ch]
    fpath = os.path.join(BASE, fname)
    
    # Read
    content = None
    for enc in ['utf-8', 'gbk']:
        try:
            with open(fpath, "r", encoding=enc) as f:
                content = f.read()
            break
        except:
            pass
    
    if not content:
        print(f"SKIP {fname}: can't read")
        continue
    
    if "微信读书证据补充Batch2" in content:
        print(f"SKIP {fname}: already enriched")
        continue
    
    # Deduplicate by content
    seen = set()
    unique_items = []
    for e in items:
        c = e["content"][:40]
        if c not in seen:
            seen.add(c)
            unique_items.append(e)
    
    enrichment = "\n\n## 微信读书证据补充Batch2（2026-06-11）\n\n"
    enrichment += "以下为第二批微信读书高价值划线，扩充本章证据链：\n\n"
    
    for e in unique_items[:8]:
        enrichment += "> **" + e["book"] + "** / " + e["author"] + "\n"
        enrichment += "> " + e["content"] + "\n\n"
    
    content += enrichment
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)
    print("ENRICHED: " + fname + " +" + str(len(unique_items[:8])) + " extracts")

print("\nDone: Batch2 mapped to chapters")
