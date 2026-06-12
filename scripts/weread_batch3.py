import json, os, time, requests

WEREAD_TOKEN = "wrk-yC_PeQeCQBWIBD7_uFhTwwAA"
BASE = "https://i.weread.qq.com"
headers = {"Authorization": "Bearer " + WEREAD_TOKEN, "Content-Type": "application/json"}

r = requests.post(BASE + "/api/agent/gateway", headers=headers,
    json={"api_name": "/user/notebooks", "skill_version": "3.0.0"})
books = sorted(r.json().get("books", []), key=lambda b: b.get("noteCount", 0), reverse=True)

already_done = ["33628204", "40649986", "3300054893", "33800862"]
new_extracts = []

for b in books:
    book_info = b.get("book", {})
    book_id = str(book_info.get("bookId", ""))
    if book_id in already_done:
        continue
    
    title = book_info.get("title", "?")
    note_count = b.get("noteCount", 0)
    if note_count < 25:
        continue
    
    try:
        r2 = requests.post(BASE + "/api/agent/gateway", headers=headers,
            json={"api_name": "/book/bestbookmarks", "bookId": book_id, "count": 8, "skill_version": "3.0.0"})
        bm = r2.json()
        items = bm.get("items", [])
        
        for item in items[:5]:
            new_extracts.append({
                "book": title,
                "author": str(book_info.get("author", "?")),
                "content": str(item.get("markText", ""))[:150]
            })
        
        print(title + ": " + str(len(items[:5])) + " extracts")
        time.sleep(0.3)
    except Exception as e:
        print(title + ": SKIP (PDF/no items)")
    
    if len(new_extracts) >= 35:
        break

out = r"D:\KnowledgeBase\_alchemist\weread_extracts\batch2_bookmarks.json"
os.makedirs(os.path.dirname(out), exist_ok=True)
with open(out, "w", encoding="utf-8") as f:
    json.dump(new_extracts, f, ensure_ascii=False, indent=2)

book_names = list(set(e["book"] for e in new_extracts))
print("\nBatch 2: " + str(len(new_extracts)) + " extracts from " + str(len(book_names)) + " books")
for bn in book_names:
    print("  - " + bn)
