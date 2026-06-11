import json, os

with open(r"D:\KnowledgeBase\_alchemist\weread_extracts\v7_enrichment_bookmarks.json", "r", encoding="utf-8") as f:
    extracts = json.load(f)

# Read EVIDENCE_LEDGER
ledger_path = r"D:\KnowledgeBase\media\flagship\book-v7\EVIDENCE_LEDGER.md"
try:
    with open(ledger_path, "r", encoding="utf-8") as f:
        ledger = f.read()
except:
    with open(ledger_path, "r", encoding="gbk") as f:
        ledger = f.read()

# Count existing entries
existing_count = ledger.count("| 已核 |") + ledger.count("| 待核 |")
print(f"Existing evidence entries: ~{existing_count}")

# Build new entries
new_entries = []
for e in extracts:
    book = e["book"]
    author = e["author"]
    text = e["content"][:60]
    ch = e["relevance"].split("/")[0].strip()
    new_entries.append(f"| {book} / {author} | A | 微信读书划线 | {text}... | 待核 | {ch} |")

# Append to ledger
if "微信读书补充20260611" not in ledger:
    addon = "\n\n## 微信读书补充（2026-06-11）\n\n"
    addon += "| 论点来源 | 等级 | 锚点类型 | 锚点内容（节选） | 验证状态 | 关联章节 |\n"
    addon += "|----------|------|----------|-----------------|----------|----------|\n"
    addon += "\n".join(new_entries)
    addon += "\n"
    
    ledger += addon
    with open(ledger_path, "w", encoding="utf-8") as f:
        f.write(ledger)
    print(f"EVIDENCE_LEDGER: +{len(new_entries)} weread entries")
else:
    print("EVIDENCE_LEDGER: already updated")

# Also update the FULL_MANUSCRIPT.md evidence count at the top
manuscript_path = r"D:\KnowledgeBase\media\flagship\book-v7\FULL_MANUSCRIPT.md"
try:
    with open(manuscript_path, "r", encoding="utf-8") as f:
        ms = f.read()
except:
    with open(manuscript_path, "r", encoding="gbk") as f:
        ms = f.read()

# Update the evidence count if present
if "微信读书66本" in ms:
    ms = ms.replace("微信读书66本在架书籍、1,346条划线", 
                     "微信读书67本在架书籍、1,346+32条划线（2026-06-11新增32条）")
    ms = ms.replace("~130本去重名著", "~130本去重名著 + 4本新手补证据（认知觉醒/驱动/成瘾/少有人走的路）")
    with open(manuscript_path, "w", encoding="utf-8") as f:
        f.write(ms)
    print("FULL_MANUSCRIPT: evidence count updated")
except:
    print("FULL_MANUSCRIPT: pattern not found")

print("\nDone: Evidence ledger + manuscript updated")
