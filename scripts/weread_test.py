import requests, json

WEREAD_TOKEN = "wrk-yC_PeQeCQBWIBD7_uFhTwwAA"
BASE = "https://i.weread.qq.com"

headers = {
    "Authorization": f"Bearer {WEREAD_TOKEN}",
    "Content-Type": "application/json"
}

# Test: get bookshelf
r = requests.post(f"{BASE}/api/agent/gateway",
    headers=headers,
    json={"api_name": "/shelf/sync", "skill_version": "3.0.0"})
print("Shelf response code:", r.status_code)
data = r.json()
if "books" in data:
    books = data["books"][:5]
    print(f"Total books: {len(data.get('books',[]))}")
    for b in books:
        title = b.get("title", "?")
        author = b.get("author", "?")
        progress = b.get("progress", 0)
        print(f"  {title} / {author} (progress: {progress}%)")
else:
    print("Response keys:", list(data.keys())[:10])
    print("Sample:", json.dumps(data, ensure_ascii=False)[:300])
