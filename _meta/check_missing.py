import json
with open(r"D:\KnowledgeBase\_meta\skill_gate_scan.json", "r", encoding="utf-8") as f:
    results = json.load(f)
missing_g2 = [r for r in results if not r["g2"]]
print(f"=== Still missing G2 ({len(missing_g2)}) ===")
for r in missing_g2:
    print(f"  {r['name']} | gates={r['gates']} | g3={r['g3']} | g4={r['g4']}")
missing_d7 = [r for r in results if not r["d7"]]
print(f"\n=== Missing D7 ({len(missing_d7)}) ===")
for r in missing_d7:
    print(f"  {r['name']}")
