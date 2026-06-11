import requests, json, os, sys, io, time

APP_ID = "cli_aa95650c3a78dbb5"
APP_SECRET = "zSBeXipBt5s1bRoXW20SIe3MGozCryWR"
BASE = "https://open.feishu.cn"
doc_id = "OXQNdVbJ6ooKvJxPwBPcg0dGnhh"

r = requests.post(f"{BASE}/open-apis/auth/v3/tenant_access_token/internal",
    json={"app_id": APP_ID, "app_secret": APP_SECRET})
token = r.json()["tenant_access_token"]
headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

test_blocks = [
    {"block_type": 2, "text": {"elements": [{"text_run": {"content": "v7答案之书v7同步测试"}}], "style": {}}},
    {"block_type": 2, "text": {"elements": [{"text_run": {"content": "滴滴实习已修正为哈啰实习 2026-06-11"}}], "style": {}}},
]

body = {"children": test_blocks, "index": 0}
r2 = requests.post(
    f"{BASE}/open-apis/docx/v1/documents/{doc_id}/blocks/{doc_id}/children",
    headers=headers, json=body
)
resp = r2.json()
if resp.get("code") == 0:
    for child in resp["data"]["children"]:
        r3 = requests.get(f"{BASE}/open-apis/docx/v1/documents/{doc_id}/blocks/{child['block_id']}", headers=headers)
        block = r3.json().get("data", {}).get("block", {})
        if block.get("block_type") == 2:
            for elem in block.get("text", {}).get("elements", []):
                content = elem.get("text_run", {}).get("content", "")
                with open(r"D:\KnowledgeBase\_logs\feishu_v.txt", "a", encoding="utf-8") as f:
                    f.write(f"HEX: {content.encode('utf-8').hex()}\nCONTENT: {content}\n\n")
