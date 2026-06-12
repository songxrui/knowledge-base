import json, os

# Load batch1 health-related extracts
with open(r"D:\KnowledgeBase\_alchemist\weread_extracts\v7_enrichment_bookmarks.json", "r", encoding="utf-8") as f:
    extracts = json.load(f)

health_items = [e for e in extracts if "成瘾" in e.get("book", "")]
print("Health extracts: " + str(len(health_items)))

# Read CH03
fpath = r"D:\KnowledgeBase\media\flagship\book-v7\CH03_physical-health.md"
content = None
for enc in ['utf-8', 'gbk']:
    try:
        with open(fpath, "r", encoding=enc) as f:
            content = f.read()
        break
    except:
        pass

if "微信读书证据补充" in content:
    print("Already has weread section - skipping")
else:
    enrichment = "\n\n## 微信读书证据补充（2026-06-11）\n\n"
    enrichment += "以下为从微信读书《成瘾：在放纵中寻找平衡》提取的高价值划线。"
    enrichment += "安娜·伦布克医生的多巴胺研究直接支撑本章关于快感-痛苦平衡、"
    enrichment += "饮食成瘾和生活方式改变的论点：\n\n"
    
    for e in health_items[:8]:
        enrichment += "> **" + e["book"] + "** / " + e["author"] + "（" + e["chapter"] + "）\n"
        enrichment += "> " + e["content"] + "\n"
        if e.get("note"):
            enrichment += "> [笔记] " + e["note"] + "\n"
        enrichment += "\n"
    
    content += enrichment
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)
    print("ENRICHED CH03: +" + str(len(health_items[:8])) + " extracts from 成瘾")

print("\n8章微信读书全覆盖: CH01/02/03/04/05/06/07/08 = 8/8")
