import requests, json, os

WEREAD_TOKEN = "wrk-yC_PeQeCQBWIBD7_uFhTwwAA"
BASE = "https://i.weread.qq.com"
headers = {"Authorization": f"Bearer {WEREAD_TOKEN}", "Content-Type": "application/json"}

# Get books with highlights (notebooks)
r = requests.post(f"{BASE}/api/agent/gateway", headers=headers,
    json={"api_name": "/user/notebooks", "skill_version": "3.0.0"})
data = r.json()
print("Notebooks keys:", list(data.keys())[:10] if data else "empty")

if "books" in data:
    books = data["books"]
    print(f"Books with notes: {len(books)}")
    for b in books[:8]:
        title = b.get("book", {}).get("title", "?")
        author = b.get("book", {}).get("author", "?")
        note_count = b.get("noteCount", 0)
        highlight_count = b.get("highlightCount", 0)
        print(f"  {title} / {author}: {highlight_count} highlights, {note_count} notes")
elif "notebooks" in data:
    print(f"Notebooks count: {len(data['notebooks'])}")
    for nb in data['notebooks'][:5]:
        print(f"  {nb.get('book',{}).get('title','?')}")
else:
    print("Raw:", json.dumps(data, ensure_ascii=False)[:500])
