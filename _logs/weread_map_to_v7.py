import json, os

# Load extracts
with open(r"D:\KnowledgeBase\_alchemist\weread_extracts\v7_enrichment_bookmarks.json", "r", encoding="utf-8") as f:
    extracts = json.load(f)

# Map to chapters
chapter_map = {
    "CH01-元能力": [],
    "CH02-心理": [],
    "CH03-身体健康": [],
    "CH05-关系": [],
    "CH07-问题解决": [],
}

for e in extracts:
    rel = e["relevance"]
    for ch in ["CH01-元能力", "CH02-心理", "CH03-身体健康", "CH05-关系", "CH07-问题解决"]:
        if ch in rel:
            chapter_map[ch].append(e)

# Build enrichment markdown for each chapter
BASE_PATH = r"D:\KnowledgeBase\media\flagship\book-v7"

for ch, items in chapter_map.items():
    if not items:
        continue
    
    ch_file_map = {
        "CH01-元能力": "CH01_meta-abilities.md",
        "CH02-心理": "CH02_mental-health.md",
        "CH03-身体健康": "CH03_physical-health.md",
        "CH05-关系": "CH05_relationships.md",
        "CH07-问题解决": "CH07_problem-solving.md",
    }
    
    filename = ch_file_map.get(ch)
    if not filename:
        continue
    
    filepath = os.path.join(BASE_PATH, filename)
    
    # Read file with GBK
    try:
        with open(filepath, "r", encoding="gbk") as f:
            content = f.read()
    except:
        try:
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()
        except:
            print(f"Cannot read {filename}")
            continue
    
    # Create enrichment section
    enrichment = "\n\n## 🔖 微信读书证据补充（2026-06-11）\n\n"
    enrichment += "以下为从微信读书书中提取的高价值划线，作为本章论点的独立证据：\n\n"
    
    for item in items:
        book = item["book"]
        author = item["author"]
        chapter = item["chapter"]
        text = item["content"]
        note = item.get("note", "")
        
        enrichment += f"> **{book}** / {author} ({chapter})\n"
        enrichment += f"> {text}\n"
        if note:
            enrichment += f"> 📝 我的笔记：{note}\n"
        enrichment += "\n"
    
    # Append to file
    if "微信读书证据补充" not in content:
        content += enrichment
        with open(filepath, "w", encoding="gbk") as f:
            f.write(content)
        print(f"Enriched {filename}: +{len(items)} extracts from weread")
    else:
        print(f"{filename}: already has weread enrichment")

print("\nDone: Weread extracts mapped to v7 chapters")
