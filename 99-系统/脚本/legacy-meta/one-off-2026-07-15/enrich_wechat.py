import os, json, re

KB = r"D:\KnowledgeBase"
WEREAD_JSON = os.path.join(KB, "_alchemist", "weread_extracts", "v7_enrichment_bookmarks.json")

# Load weread extracts pool
with open(WEREAD_JSON, "r", encoding="utf-8") as f:
    extracts = json.load(f)

# Also load batch2
batch2_path = os.path.join(KB, "_alchemist", "weread_extracts", "batch2_bookmarks.json")
with open(batch2_path, "r", encoding="utf-8") as f:
    extracts.extend(json.load(f))

print("Extract pool: " + str(len(extracts)))

# Find wechat articles without book refs
wechat_dirs = [
    os.path.join(KB, "media", "wechat_2026-06-07"),
    os.path.join(KB, "media", "wechat_reconstructed"),
]

no_ref_files = []
for d in wechat_dirs:
    if not os.path.exists(d):
        continue
    for fname in os.listdir(d):
        if not fname.endswith('.md'):
            continue
        fpath = os.path.join(d, fname)
        for enc in ['utf-8','gbk']:
            try:
                with open(fpath, 'r', encoding=enc) as f:
                    content = f.read()
                break
            except:
                continue
        
        # Check for book references
        has_ref = bool(re.search(r'《[^》]+》', content))
        if not has_ref:
            no_ref_files.append((fpath, content))

print("Articles without book refs: " + str(len(no_ref_files)))

# Match extracts to articles by keyword overlap
import random
random.shuffle(no_ref_files)

enriched = 0
for fpath, content in no_ref_files[:15]:  # Process 15 articles
    # Extract keywords from article (first 2000 chars)
    sample = content[:2000]
    
    # Score each extract for relevance
    best_extract = None
    best_score = 0
    
    for e in extracts:
        e_text = e.get("content", "")
        # Simple keyword overlap scoring
        score = 0
        keywords = ["自律","痛苦","快乐","多巴胺","耐心","价值","成长","财富","复利","注意","关系","成熟","安全感","自由","决策","元认知","专注"]
        for kw in keywords:
            if kw in sample and kw in e_text:
                score += 1
        if score > best_score:
            best_score = score
            best_extract = e
    
    if best_extract and best_score >= 2:
        # Add citation block at end of file
        citation = "\n\n---\n## 微信读书证据\n\n"
        citation += "> **" + best_extract.get("book", "") + "** / " + best_extract.get("author", "")
        citation += "\n> " + best_extract.get("content", "")[:200]
        citation += "\n\n*[2026-06-11 自动匹配补充]*\n"
        
        content += citation
        with open(fpath, "w", encoding="utf-8") as f:
            f.write(content)
        enriched += 1
        fname = os.path.basename(fpath)
        print("ENRICHED: " + fname[:60] + " -> " + best_extract.get("book", "") + " (score=" + str(best_score) + ")")

print("\nEnriched: " + str(enriched) + "/15 articles with weread citations")
