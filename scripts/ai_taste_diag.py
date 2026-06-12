# ai-taste-check: 诊断 v7 PREFACE.md
with open(r"D:\KnowledgeBase\media\flagship\book-v7\PREFACE.md", "r", encoding="gbk") as f:
    content = f.read()

lines = [l.strip() for l in content.split("\n") if l.strip()]
print(f"Total meaningful lines: {len(lines)}")

# 病征1: 对称与排比成瘾 - 检查连续3句长度接近
similar_count = 0
for i in range(len(lines) - 2):
    l1, l2, l3 = len(lines[i]), len(lines[i+1]), len(lines[i+2])
    if abs(l1 - l2) < 5 and abs(l2 - l3) < 5 and l1 > 10:
        similar_count += 1
        if similar_count <= 3:
            print(f"  排比嫌疑 L{i+1}: {lines[i][:50]}... ({l1})")
            print(f"           L{i+2}: {lines[i+1][:50]}... ({l2})")
            print(f"           L{i+3}: {lines[i+2][:50]}... ({l3})")

print(f"\n排比嫌疑段: {similar_count}")

# 病征2: 空泛升华结尾
last_lines = lines[-5:]
print("\n结尾5行:")
for l in last_lines:
    print(f"  {l[:80]}")
sublimation_words = ["让我们", "归根结底", "说到底", "拥抱", "迎接", "走向"]
hits = [w for w in sublimation_words if any(w in l for l in last_lines)]
print(f" 升华词命中: {hits if hits else '无'}")

# 病征3: 强行中立
hedge_words = ["但也要看到", "另一方面", "不可否认", "然而也要", "当然也要"]
hedges = sum(1 for w in hedge_words if w in content)
print(f"\n中立对冲词: {hedges}次")

# 病征4: 列举式空洞
bullet_count = sum(1 for l in lines if l.startswith("- ") or l.startswith("* ") or l.startswith("1. "))
number_start = sum(1 for l in lines if l[0].isdigit() and ". " in l[:4])
print(f"\n列表项: -/*={bullet_count}, 数字列表={number_start}")

# 病征5: 过度加粗
bold_pairs = content.count("**")
print(f"加粗对: {bold_pairs} (约{bold_pairs//2}处)")

# 病征6: 禁用词
banned = ["赋能","抓手","闭环","综上所述","众所周知","值得注意的是","在这个时代","底层逻辑","本质上"]
for w in banned:
    if w in content:
        print(f"⚠️ 禁用词: {w}")

# 总体诊断
print(f"\n=== 诊断汇总 ===")
print(f"总行数: {len(lines)}")
print(f"排比: {similar_count}段 | 升华结尾: {'有' if hits else '无'} | 对冲词: {hedges}")
print(f"列表: {bullet_count+number_start}项 | 加粗: {bold_pairs//2}处")
