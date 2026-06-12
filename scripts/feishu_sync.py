import requests, json, os, sys, io, time

APP_ID = "cli_aa95650c3a78dbb5"
APP_SECRET = "zSBeXipBt5s1bRoXW20SIe3MGozCryWR"
BASE = "https://open.feishu.cn"
BASE_PATH = r"D:\KnowledgeBase\media\flagship\book-v7"
LOG_PATH = r"D:\KnowledgeBase\_logs\feishu_sync_v7.log"

DOC_MAP = {
    "PREFACE.md": "OXQNdVbJ6ooKvJxPwBPcg0dGnhh",
    "CH01_meta-abilities.md": "Z4nSd0uIPoELRfxHZ98cl76JnWl",
    "CH02_mental-health.md": "CLXqdP4iiotr4GxSrm1cU8Anndg",
    "CH03_physical-health.md": "RwP1dUDF3ohjqGxBvexcbts2n1f",
    "CH04_wealth-business.md": "Ae5tdFQnjokMyKxyWg7coFNInQh",
    "CH05_relationships.md": "OFazdIE2doPo9xxTAHDcBI0knwe",
    "CH06_top-humans.md": "W4YUdI2Yaot32pxIbBncToXJnyg",
    "CH07_problem-solving.md": "Z1dBdrhFToAGJ0xrxBocpzS3nQf",
    "CH08_first-principles.md": "SRR5dvUKzoKVSUx70qict72znOc",
}

def log(msg):
    with open(LOG_PATH, "a", encoding="utf-8") as f:
        f.write(f"[{time.strftime('%H:%M:%S')}] {msg}\n")
    print(msg)

# Auth
r = requests.post(f"{BASE}/open-apis/auth/v3/tenant_access_token/internal",
    json={"app_id": APP_ID, "app_secret": APP_SECRET})
token = r.json()["tenant_access_token"]
headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
log(f"Auth OK, token: {token[:20]}...")

def read_file(path):
    for enc in ['gbk', 'utf-8', 'gb2312']:
        try:
            with open(path, 'r', encoding=enc) as f:
                return f.read()
        except:
            continue
    return None

def clear_document(doc_id):
    """Delete all children blocks from a document"""
    r = requests.get(
        f"{BASE}/open-apis/docx/v1/documents/{doc_id}/blocks/{doc_id}/children",
        headers=headers, params={"document_revision_id": -1}
    )
    data = r.json()
    if data.get("code") != 0:
        return False, f"get children failed: {data.get('code')}"
    
    items = data.get("data", {}).get("items", [])
    if not items:
        return True, "no children to delete"
    
    del_body = {
        "document_revision_id": -1,
        "start_index": 0,
        "end_index": len(items) - 1
    }
    r2 = requests.delete(
        f"{BASE}/open-apis/docx/v1/documents/{doc_id}/blocks/{doc_id}/children/batch_delete",
        headers=headers, json=del_body
    )
    resp = r2.json()
    if resp.get("code") == 0:
        return True, f"deleted {len(items)} blocks"
    return False, f"delete failed: {resp.get('code')} {resp.get('msg')}"

def add_content_blocks(doc_id, content):
    """Add content as blocks to a document"""
    lines = content.split('\n')
    blocks = []
    
    for line in lines:
        stripped = line.strip()
        if not stripped:
            continue
        
        is_heading = stripped.startswith('#')
        
        if is_heading:
            level = 0
            for ch in stripped:
                if ch == '#':
                    level += 1
                else:
                    break
            heading_text = stripped[level:].strip()
            if not heading_text:
                continue
            blocks.append({
                "block_type": 3,
                "heading1": {
                    "elements": [{"text_run": {"content": heading_text}}],
                    "style": {"heading_level": min(level, 9)}
                }
            })
        else:
            blocks.append({
                "block_type": 2,
                "text": {
                    "elements": [{"text_run": {"content": stripped}}],
                    "style": {}
                }
            })
    
    total_added = 0
    batch_size = 50
    
    for i in range(0, len(blocks), batch_size):
        batch = blocks[i:i+batch_size]
        body = {"children": batch, "index": i}
        r = requests.post(
            f"{BASE}/open-apis/docx/v1/documents/{doc_id}/blocks/{doc_id}/children",
            headers=headers, json=body
        )
        resp = r.json()
        if resp.get("code") == 0:
            total_added += len(resp["data"]["children"])
        else:
            return total_added, f"batch {i} failed: {resp.get('code')} {resp.get('msg')}"
        time.sleep(0.5)
    
    return total_added, "ok"

# Main sync loop
results = []
for filename, doc_id in DOC_MAP.items():
    log(f"\nProcessing {filename}...")
    
    content = read_file(os.path.join(BASE_PATH, filename))
    if not content:
        log(f"  SKIP: cannot read file")
        results.append(f"SKIP: {filename}")
        continue
    
    log(f"  Read {len(content)} chars")
    
    # Clear existing content
    ok, msg = clear_document(doc_id)
    if not ok:
        log(f"  ERR clearing: {msg}")
        results.append(f"ERR_CLEAR: {filename} - {msg}")
        continue
    log(f"  Clear: {msg}")
    
    time.sleep(0.3)
    
    # Add new content
    added, msg = add_content_blocks(doc_id, content)
    if msg != "ok":
        log(f"  WARN: added {added} blocks, {msg}")
        results.append(f"PARTIAL: {filename} - {added} blocks, {msg}")
    else:
        log(f"  SYNCED: {added} blocks")
        results.append(f"SYNCED: {filename} - {added} blocks ({len(content)} chars)")
    
    time.sleep(1.0)  # Rate limiting between docs

log(f"\n=== SYNC SUMMARY ===")
synced = 0
for r in results:
    log(r)
    if r.startswith("SYNCED") or r.startswith("PARTIAL"):
        synced += 1
log(f"Total: {synced}/{len(DOC_MAP)} docs synced")
