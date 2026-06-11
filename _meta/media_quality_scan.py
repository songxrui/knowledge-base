import os, re

BASE = r"D:\KnowledgeBase\media"
BAD_WORDS = ["赋能","抓手","闭环","底层逻辑","本质上","综上所述","众所周知","不难发现","值得注意的是","总而言之","换句话说","首先.*其次.*最后","一方面.*另一方面","在这个.*的时代"]
AI_OPENINGS = ["首先","其次","最后","随着","在这个"]

def scan_file(filepath):
    try:
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
    except:
        return None
    
    size = len(content)
    if size < 500:
        return None
    
    # AI味检测
    bad_hits = []
    for bw in BAD_WORDS:
        matches = re.findall(bw, content)
        if matches:
            bad_hits.extend(matches)
    
    # 数字密度
    numbers = len(re.findall(r'\d+', content))
    
    # 引用/来源
    citations = len(re.findall(r'《.+》|来源|引用|摘自|原文', content))
    
    # 第一人称
    first_person = len(re.findall(r'我[觉得为认会觉知道发现试判断]', content))
    
    # Skill链
    has_skill_chain = "Skill链" in content or "产出Skill" in content
    
    # 质量分
    score = 10
    score -= min(5, len(bad_hits))  # 每个禁用词-1
    if numbers < 5: score -= 2
    if citations < 1: score -= 1
    if first_person < 2: score -= 1  # 缺少个人判断
    if not has_skill_chain: score -= 0  # 大部分没有，不扣分
    
    return {
        "file": os.path.relpath(filepath, BASE)[:60],
        "size": size,
        "bad_count": len(bad_hits),
        "bad_words": bad_hits[:5],
        "numbers": numbers,
        "citations": citations,
        "first_person": first_person,
        "score": max(0, score)
    }

# Scan W-series and C-series
results = []
for f in os.listdir(BASE):
    if not f.endswith(".md"): continue
    fp = os.path.join(BASE, f)
    r = scan_file(fp)
    if r:
        results.append(r)

# Also scan wechat subdirectory
wx_dir = os.path.join(BASE, "wechat_2026-06-07")
if os.path.exists(wx_dir):
    for f in os.listdir(wx_dir):
        if not f.endswith(".md"): continue
        fp = os.path.join(wx_dir, f)
        r = scan_file(fp)
        if r:
            r["file"] = "wechat/" + r["file"]
            results.append(r)

# Sort by score (worst first)
results.sort(key=lambda x: x["score"])

print(f"=== Media Content Quality Scan ({len(results)} files) ===")
print(f"{'Score':>5} {'Bad':>4} {'#Num':>5} {'#Cite':>5} {'#Me':>4} {'File'}")
print("-" * 80)

for r in results[:30]:  # Top 30 worst
    print(f"{r['score']:>5} {r['bad_count']:>4} {r['numbers']:>5} {r['citations']:>5} {r['first_person']:>4} {r['file']}")

# Show best files too
print(f"\n--- Top 5 Best ---")
for r in results[-5:]:
    print(f"{r['score']:>5} {r['bad_count']:>4} {r['numbers']:>5} {r['citations']:>5} {r['first_person']:>4} {r['file']}")

# Stats
avg = sum(r["score"] for r in results) / len(results)
bad_any = sum(1 for r in results if r["bad_count"] > 0)
print(f"\nAvg score: {avg:.1f} | Files with AI味: {bad_any}/{len(results)} | Score<7: {sum(1 for r in results if r['score']<7)}")
