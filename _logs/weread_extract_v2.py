import requests, json, os, time

WEREAD_TOKEN = "wrk-yC_PeQeCQBWIBD7_uFhTwwAA"
BASE = "https://i.weread.qq.com"
headers = {"Authorization": f"Bearer {WEREAD_TOKEN}", "Content-Type": "application/json"}

# Get notebooks
r = requests.post(f"{BASE}/api/agent/gateway", headers=headers,
    json={"api_name": "/user/notebooks", "skill_version": "3.0.0"})
data = r.json()
books = sorted(data.get("books", []), key=lambda b: b.get("noteCount", 0), reverse=True)

extracts_all = []
# Target books most relevant to v7 chapters
target_books = [
    (33628204, "认知觉醒", "周岭", "CH01-元能力/CH02-心理"),
    (40649986, "认知驱动", "周岭", "CH01-元能力/CH07-问题解决"),
    (3300054893, "成瘾", "安娜·伦布克", "CH02-心理健康"),
    (33800862, "少有人走的路", "M.斯科特·派克", "CH02-心理/CH05-关系"),
]

for book_id, title, author, relevance in target_books:
    print(f"\n=== {title} / {author} → {relevance} ===")
    try:
        r2 = requests.post(f"{BASE}/api/agent/gateway", headers=headers,
            json={"api_name": "/book/bestbookmarks", "bookId": str(book_id), "count": 10, "skill_version": "3.0.0"})
        bm = r2.json()
        
        items = bm.get("items", [])
        chapters = {c["chapterUid"]: c["title"] for c in bm.get("chapters", [])}
        
        for item in items[:8]:
            chap_uid = str(item.get("chapterUid", ""))
            chapter = chapters.get(chap_uid, "?")
            mark_text = item.get("markText", "")[:100]
            abstract = item.get("abstract", "")[:60]
            create_time = item.get("createTime", 0)
            
            line = f"  [{chapter}] {mark_text}"
            if abstract:
                line += f" [注: {abstract}]"
            print(line)
            
            extracts_all.append({
                "book": title, "author": author, "relevance": relevance,
                "chapter": chapter, "content": item.get("markText", ""),
                "note": item.get("abstract", ""),
                "bookmarkId": item.get("bookmarkId", "")
            })
        time.sleep(0.5)
    except Exception as e:
        print(f"  Error: {e}")

out_path = r"D:\KnowledgeBase\_alchemist\weread_extracts\v7_enrichment_bookmarks.json"
os.makedirs(os.path.dirname(out_path), exist_ok=True)
with open(out_path, "w", encoding="utf-8") as f:
    json.dump(extracts_all, f, ensure_ascii=False, indent=2)

print(f"\n\nTotal extracts saved: {len(extracts_all)}")
print(f"Output: {out_path}")
