import json, os

with open(r"D:\KnowledgeBase\_alchemist\weread_extracts\v7_enrichment_bookmarks.json", "r", encoding="utf-8") as f:
    extracts = json.load(f)

BASE_PATH = r"D:\KnowledgeBase\media\flagship\book-v7"
ch_file_map = {
    "CH01-元能力": "CH01_meta-abilities.md",
    "CH02-心理": "CH02_mental-health.md",
    "CH03-身体健康": "CH03_physical-health.md",
    "CH05-关系": "CH05_relationships.md",
    "CH07-问题解决": "CH07_problem-solving.md",
}

for ch_label, filename in ch_file_map.items():
    items = [e for e in extracts if ch_label in e["relevance"]]
    if not items:
        continue
    
    filepath = os.path.join(BASE_PATH, filename)
    
    # Read with auto-detect
    content = None
    for enc in ['utf-8', 'gbk', 'gb2312']:
        try:
            with open(filepath, "r", encoding=enc) as f:
                content = f.read()
            break
        except:
            continue
    
    if content is None:
        print(f"SKIP: {filename} can't read")
        continue
    
    # Check if already enriched
    if "微信读书证据补充" in content:
        print(f"SKIP: {filename} already enriched")
        continue
    
    # Build enrichment
    enrichment = "\n\n## 微信读书证据补充（2026-06-11）\n\n"
    enrichment += "以下为从微信读书中提取的高价值划线，作为本章论点的独立验证证据：\n\n"
    
    for item in items:
        enrichment += "> **" + item["book"] + "** / " + item["author"] + "（" + item["chapter"] + "）\n"
        enrichment += "> " + item["content"] + "\n"
        if item.get("note"):
            enrichment += "> [我的笔记] " + item["note"] + "\n"
        enrichment += "\n"
    
    content += enrichment
    
    # Write as UTF-8
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"ENRICHED: {filename} +{len(items)} weread extracts")

print("\nDone!")
