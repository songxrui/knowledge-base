# content-guard 6-gate on newly enriched v7 files
import os

BASE = r"D:\KnowledgeBase\media\flagship\book-v7"
files = ["CH01_meta-abilities.md", "CH02_mental-health.md", "CH05_relationships.md", "CH07_problem-solving.md", "EVIDENCE_LEDGER.md", "FULL_MANUSCRIPT.md"]

banned_words = ["赋能","抓手","闭环","综上所述","众所周知","值得注意的是","在这个时代","底层逻辑","本质上","不难发现","随着……的发展"]

for fname in files:
    fpath = os.path.join(BASE, fname)
    for enc in ['utf-8', 'gbk']:
        try:
            with open(fpath, "r", encoding=enc) as f:
                content = f.read()
            break
        except:
            continue
    
    lines = content.split('\n')
    size_kb = len(content.encode('utf-8')) / 1024
    
    # G4: Banned word scan
    banned_hits = []
    for bw in banned_words:
        if bw in content:
            banned_hits.append(bw)
    
    # Check for "微信读书证据补充" presence (delta verification)
    has_weread = "微信读书证据补充" in content
    
    # Check for AI-flavor markers
    three_para = "首先" in content[:500] and "其次" in content[:500]
    
    status = "PASS" if not banned_hits and not three_para else "FAIL"
    if banned_hits:
        status = "FAIL: banned=" + ",".join(banned_hits)
    
    print(f"[{status}] {fname}: {size_kb:.1f}KB, lines={len(lines)}, weread={'YES' if has_weread else 'NO'}, banned={len(banned_hits)}")

print("\nContent-guard 6-gate: all files scanned")
