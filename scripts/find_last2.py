import json
with open(r"D:\KnowledgeBase\_meta\skill_gate_scan.json", "r", encoding="utf-8") as f:
    results = json.load(f)
missing = [r["name"] for r in results if r["gates"] == 4]
print("Remaining 2 missing G2:")
for m in missing:
    print(f"  - {m}")
