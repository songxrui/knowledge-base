import json

with open(r"D:\KnowledgeBase\_alchemist\weread_extracts\v7_enrichment_bookmarks.json", "r", encoding="utf-8") as f:
    extracts = json.load(f)

# Build new ledger entries
new_entries = []
for e in extracts:
    book = e["book"]
    author = e["author"]
    text = e["content"][:60].replace("|", "/")
    ch = e["relevance"].split("/")[0].strip()
    new_entries.append("| " + book + " / " + author + " | A | 微信读书划线 | " + text + "... | 待核 | " + ch + " |")

# Update EVIDENCE_LEDGER
ledger_path = r"D:\KnowledgeBase\media\flagship\book-v7\EVIDENCE_LEDGER.md"
content = ""
for enc in ['utf-8', 'gbk']:
    try:
        with open(ledger_path, "r", encoding=enc) as f:
            content = f.read()
        break
    except:
        pass

if "微信读书补充20260611" not in content:
    addon = "\n\n## 微信读书补充（2026-06-11）\n\n"
    addon += "| 论点来源 | 等级 | 锚点类型 | 锚点内容（节选） | 验证状态 | 关联章节 |\n"
    addon += "|----------|------|----------|-----------------|----------|----------|\n"
    addon += "\n".join(new_entries)
    addon += "\n"
    content += addon
    with open(ledger_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("EVIDENCE_LEDGER enriched: +" + str(len(new_entries)) + " entries")

# Update FULL_MANUSCRIPT
ms_path = r"D:\KnowledgeBase\media\flagship\book-v7\FULL_MANUSCRIPT.md"
ms = ""
for enc in ['utf-8', 'gbk']:
    try:
        with open(ms_path, "r", encoding=enc) as f:
            ms = f.read()
        break
    except:
        pass

if "微信读书67本" not in ms and "微信读书66本" in ms:
    ms = ms.replace("微信读书66本在架书籍、1,346条划线", 
                     "微信读书67本在架书籍、1,378条划线（2026-06-11新增32条）")
    ms = ms.replace("~130本去重名著", "~134本去重名著（新增4本: 认知觉醒/驱动/成瘾/少有人走的路）")
    with open(ms_path, "w", encoding="utf-8") as f:
        f.write(ms)
    print("FULL_MANUSCRIPT updated")

print("Done!")
