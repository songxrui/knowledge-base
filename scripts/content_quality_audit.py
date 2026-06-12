import os, re

# Define quality markers
BAD_WORDS = ["赋能","抓手","闭环","底层逻辑","本质上","综上所述","众所周知","不难发现","随着","值得注意的是","总而言之","换句话说","首先其次最后"]
AI_PATTERNS = [r"首先.*其次.*最后", r"一方面.*另一方面", r"在这个.*的时代"]

def check_quality(filepath):
    try:
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
    except:
        return None
    
    size = len(content)
    if size < 100:
        return None
    
    # Count specific nouns/numbers
    numbers = len(re.findall(r'\d+', content))
    # Count citations
    citations = len(re.findall(r'来源|引用|摘自|《.+》|\[.+\]', content))
    # Count bad words
    bad_hits = [w for w in BAD_WORDS if w in content]
    # Count AI patterns
    ai_hits = [p for p in AI_PATTERNS if re.search(p, content)]
    # Check for evidence markers
    evidence = len(re.findall(r'数据|实验|研究|调查|案例|例如|比如|具体', content))
    
    quality_score = min(10, 
        (2 if numbers > 20 else (1 if numbers > 5 else 0)) +
        (2 if citations >= 2 else (1 if citations >= 1 else 0)) +
        (2 if len(bad_hits) == 0 else (1 if len(bad_hits) <= 2 else 0)) +
        (2 if len(ai_hits) == 0 else (1 if len(ai_hits) <= 1 else 0)) +
        (2 if evidence >= 3 else (1 if evidence >= 1 else 0))
    )
    
    return {
        "file": os.path.basename(filepath)[:40],
        "size": size,
        "numbers": numbers,
        "citations": citations,
        "bad_words": bad_hits,
        "ai_patterns": ai_hits,
        "evidence": evidence,
        "score": quality_score
    }

# Sample content files
base = r"D:\KnowledgeBase"
samples = []

# 1. Flagship manuscript
for f in ["media/flagship/book-v7/FULL_MANUSCRIPT.md", "media/flagship/book-v7/PREFACE.md"]:
    p = os.path.join(base, f)
    if os.path.exists(p):
        samples.append(p)

# 2. Some book summaries from _alchemist
alch = os.path.join(base, "_alchemist")
books = ["认知觉醒_周岭.md", "纳瓦尔宝典.md", "少有人走的路.md", "被讨厌的勇气.md", "富爸爸穷爸爸.md", "流量的本质与暴力_Stanley.md"]
for b in books:
    p = os.path.join(alch, b)
    if os.path.exists(p):
        samples.append(p)

# 3. Some WeChat articles
wx = os.path.join(base, "media/wechat_2026-06-07")
if os.path.exists(wx):
    for f in os.listdir(wx)[:3]:
        if f.endswith(".md"):
            samples.append(os.path.join(wx, f))

# 4. Cards
cards = os.path.join(base, "cards/topics")
if os.path.exists(cards):
    for f in os.listdir(cards)[:3]:
        if f.endswith(".md"):
            samples.append(os.path.join(cards, f))

print("=== Content Quality Audit ===")
print(f"{'File':<40} {'Size':>6} {'#Num':>5} {'#Cite':>5} {'BadW':>4} {'AIP':>3} {'Evid':>4} {'Score':>5}")
print("-" * 80)

total_score = 0
count = 0
for sp in samples:
    r = check_quality(sp)
    if r:
        bad_count = len(r["bad_words"])
        ai_count = len(r["ai_patterns"])
        print(f"{r['file']:<40} {r['size']:>6} {r['numbers']:>5} {r['citations']:>5} {bad_count:>4} {ai_count:>3} {r['evidence']:>4} {r['score']:>5}")
        total_score += r["score"]
        count += 1

if count > 0:
    print(f"\nAverage Quality Score: {total_score/count:.1f}/10 ({count} files)")
