import os, re

KB = r"D:\KnowledgeBase"

# Find actual wechat files
wechat_dirs = [
    os.path.join(KB, "media", "wechat_2026-06-07"),
    os.path.join(KB, "media", "wechat_reconstructed"),
    os.path.join(KB, "media", "wechat_2026-06-07_dbs"),
]

wechat_files = []
for d in wechat_dirs:
    if os.path.exists(d):
        for f in os.listdir(d):
            if f.endswith('.md'):
                wechat_files.append(os.path.join(d, f))

print("WeChat files found: " + str(len(wechat_files)))

# Check cards with banned words
BANNED = ["赋能","抓手","闭环","综上所述","众所周知","值得注意的是","在这个时代","底层逻辑","本质上"]

cards_dir = os.path.join(KB, "cards")
banned_files = []
for root, dirs, files in os.walk(cards_dir):
    for f in files:
        if not f.endswith('.md'):
            continue
        fpath = os.path.join(root, f)
        for enc in ['utf-8','gbk']:
            try:
                with open(fpath, 'r', encoding=enc) as fh:
                    content = fh.read()
                break
            except:
                continue
        hits = [w for w in BANNED if w in content]
        if hits:
            banned_files.append((fpath.replace(KB, ''), hits))

print("\nBanned word hits in cards:")
for fpath, hits in banned_files[:10]:
    rel = fpath.replace('\\', '/')
    print("  " + rel + ": " + ",".join(hits))

# Quick fix: replace banned words in affected cards
fixed = 0
for fpath, hits in banned_files:
    for enc in ['utf-8','gbk']:
        try:
            with open(os.path.join(KB, fpath.lstrip('\\')), 'r', encoding=enc) as fh:
                content = fh.read()
            break
        except:
            continue
    
    replacements = {
        "赋能": "赋予能力",
        "闭环": "循环",
        "底层逻辑": "基本原理",
    }
    for old, new in replacements.items():
        if old in content:
            content = content.replace(old, new)
    
    with open(os.path.join(KB, fpath.lstrip('\\')), 'w', encoding='utf-8') as fh:
        fh.write(content)
    fixed += 1

print("\nFixed: " + str(fixed) + " card files")
