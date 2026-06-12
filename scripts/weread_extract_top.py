import requests, json, os, time

WEREAD_TOKEN = "wrk-yC_PeQeCQBWIBD7_uFhTwwAA"
BASE = "https://i.weread.qq.com"
headers = {"Authorization": f"Bearer {WEREAD_TOKEN}", "Content-Type": "application/json"}

# Step 1: Get notebooks (books with notes)
r = requests.post(f"{BASE}/api/agent/gateway", headers=headers,
    json={"api_name": "/user/notebooks", "skill_version": "3.0.0"})
data = r.json()
books = data.get("books", [])

# Sort by note count descending
books_sorted = sorted(books, key=lambda b: b.get("noteCount", 0) + b.get("highlightCount", 0), reverse=True)

print(f"Top books by notes:")
extracts_all = []
for b in books_sorted[:8]:
    book_info = b.get("book", {})
    title = book_info.get("title", "Unknown")
    author = book_info.get("author", "Unknown")
    book_id = book_info.get("bookId", "")
    note_count = b.get("noteCount", 0)
    highlight_count = b.get("highlightCount", 0)
    total = note_count + highlight_count
    print(f"  {title} / {author}: {total} items ({highlight_count}H + {note_count}N) [ID: {book_id}]")
    
    # Get highlights for this book
    try:
        r2 = requests.post(f"{BASE}/api/agent/gateway", headers=headers,
            json={"api_name": "/book/bestbookmarks", "bookId": book_id, "count": 15, "skill_version": "3.0.0"})
        bm_data = r2.json()
        
        if "bookmarks" in bm_data:
            bms = bm_data["bookmarks"]
            print(f"    Bookmarks returned: {len(bms)}")
            for bm in bms[:5]:
                content = bm.get("markText", "")[:80]
                chapter = bm.get("chapterName", "?")
                print(f"    [{chapter}] {content}...")
                extracts_all.append({
                    "book": title, "author": author, "chapter": chapter,
                    "content": bm.get("markText", ""),
                    "bookmarkId": bm.get("bookmarkId", "")
                })
        else:
            print(f"    Response keys: {list(bm_data.keys())[:5]}")
    except Exception as e:
        print(f"    Error: {e}")
    
    time.sleep(0.5)

# Save extracts
out_path = r"D:\KnowledgeBase\_alchemist\weread_extracts\top_bookmarks.json"
os.makedirs(os.path.dirname(out_path), exist_ok=True)
with open(out_path, "w", encoding="utf-8") as f:
    json.dump(extracts_all, f, ensure_ascii=False, indent=2)

print(f"\nSaved {len(extracts_all)} extracts to {out_path}")
