import os

KB = r"D:\KnowledgeBase"
BANNED = ["赋能","抓手","闭环","综上所述","众所周知","值得注意的是","在这个时代","底层逻辑","本质上"]

wechat_dirs = ["media/wechat_2026-06-07", "media/wechat_reconstructed", "media/wechat_2026-06-07_dbs"]
wechat_files = []
for d in wechat_dirs:
    dp = os.path.join(KB, d)
    if os.path.exists(dp):
        for f in os.listdir(dp):
            if f.endswith('.md'):
                wechat_files.append(os.path.join(dp, f))

# Sample scan 30 wechat files
import random
sample = random.sample(wechat_files, min(30, len(wechat_files)))
banned_count = 0
for fpath in sample:
    for enc in ['utf-8','gbk']:
        try:
            with open(fpath, 'r', encoding=enc) as f:
                content = f.read(3000)
            break
        except:
            continue
    hits = [w for w in BANNED if w in content]
    if hits:
        banned_count += 1

pct = round(banned_count / len(sample) * 100)
print("WeChat sample: " + str(len(sample)) + "/" + str(len(wechat_files)))
print("Banned hits: " + str(banned_count) + " files (" + str(pct) + "%)")

# Count weread references in wechat
weread_count = 0
for fpath in sample:
    for enc in ['utf-8','gbk']:
        try:
            with open(fpath, 'r', encoding=enc) as f:
                content = f.read(3000)
            break
        except:
            continue
    if "微信读书" in content or "《" in content:
        weread_count += 1

print("With book refs: " + str(weread_count) + " files (" + str(round(weread_count/len(sample)*100)) + "%)")

with open(r"D:\KnowledgeBase\_logs\wechat_audit.txt", "w", encoding="utf-8") as f:
    f.write("WeChat total: " + str(len(wechat_files)) + "\n")
    f.write("Banned rate: " + str(pct) + "%\n")
    f.write("Book ref rate: " + str(round(weread_count/len(sample)*100)) + "%\n")
print("\nDone")
