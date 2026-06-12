import re
with open(r"D:\KnowledgeBase\media\BRAND_VOICE_PROFILE.md", "r", encoding="utf-8", errors="ignore") as f:
    content = f.read()
bad_words = ["赋能","抓手","闭环","底层逻辑","本质上","综上所述","众所周知","值得注意的是","总而言之","换句话说"]
sections = content.split("##")
found_any = False
for i, section in enumerate(sections):
    if "禁止词" in section or "黑名单" in section or "不用什么" in section:
        continue
    for bw in bad_words:
        if bw in section:
            print(f"FOUND '{bw}' in section {i}: {section[:100]}...")
            found_any = True
if not found_any:
    print("All bad words are in blacklist sections only - FALSE POSITIVE. File is clean.")
