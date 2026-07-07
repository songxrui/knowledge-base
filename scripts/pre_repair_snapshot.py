"""
pre_repair_snapshot.py — 证据审计防回归快照

用途：在任何批量修复操作（批量替换、证据重连、内容重构）之前拍摄证据审计快照。
修复后对比快照，STRONG 数不得下降，WEAK 数不得上升。

使用：
    python pre_repair_snapshot.py snapshot    # 修复前：拍摄快照
    python pre_repair_snapshot.py compare      # 修复后：对比快照，判定是否通过
    python pre_repair_snapshot.py              # 等价于 compare

快照存储位置: media/flagship/book-v7/EVIDENCE_SNAPSHOT.json
"""

import json
import os
import sys
import subprocess
from datetime import datetime

BASE = r"D:\KnowledgeBase\media\flagship\book-v7"
SNAPSHOT_FILE = os.path.join(BASE, "EVIDENCE_SNAPSHOT.json")


def run_evidence_audit():
    """Run evidence_audit.py and parse its output counts."""
    audit_script = os.path.join(os.path.dirname(__file__), "evidence_audit.py")
    
    result = subprocess.run(
        [sys.executable, audit_script],
        capture_output=True,
        text=True,
        cwd=os.path.dirname(__file__)
    )
    
    output = result.stdout + result.stderr
    
    # Parse the last line: STRONG=X STACKED=Y WEAK=Z NOT_FOUND=W
    counts = {}
    for part in output.split():
        if "=" in part:
            key, val = part.split("=")
            if key in ("STRONG", "STACKED", "WEAK", "NOT_FOUND"):
                counts[key] = int(val)
    
    if len(counts) != 4:
        print(f"ERROR: Failed to parse evidence_audit.py output. Got: {counts}")
        print(f"Full output:\n{output}")
        sys.exit(1)
    
    return counts


def cmd_snapshot():
    """Take a snapshot before repair."""
    print("[pre_repair_snapshot] Taking pre-repair evidence snapshot...")
    
    counts = run_evidence_audit()
    
    snapshot = {
        "timestamp": datetime.now().isoformat(),
        "counts": counts,
        "note": "Pre-repair snapshot. Run 'compare' after repair to validate."
    }
    
    with open(SNAPSHOT_FILE, "w", encoding="utf-8") as f:
        json.dump(snapshot, f, indent=2, ensure_ascii=False)
    
    print(f"[pre_repair_snapshot] Snapshot saved to {SNAPSHOT_FILE}")
    print(f"  STRONG={counts['STRONG']} STACKED={counts['STACKED']} "
          f"WEAK={counts['WEAK']} NOT_FOUND={counts['NOT_FOUND']}")
    print(f"[pre_repair_snapshot] You may now proceed with repair. "
          f"After repair, run: python pre_repair_snapshot.py compare")


def cmd_compare():
    """Compare post-repair state against snapshot."""
    if not os.path.exists(SNAPSHOT_FILE):
        print(f"ERROR: No snapshot found at {SNAPSHOT_FILE}")
        print("Run 'snapshot' first before repair.")
        sys.exit(1)
    
    with open(SNAPSHOT_FILE, "r", encoding="utf-8") as f:
        snapshot = json.load(f)
    
    print(f"[pre_repair_snapshot] Comparing against snapshot from {snapshot['timestamp']}")
    
    current_counts = run_evidence_audit()
    prev_counts = snapshot["counts"]
    
    # Gate checks
    failures = []
    
    # STRONG must not decrease
    if current_counts["STRONG"] < prev_counts["STRONG"]:
        failures.append(
            f"STRONG decreased: {prev_counts['STRONG']} → {current_counts['STRONG']} "
            f"(-{prev_counts['STRONG'] - current_counts['STRONG']})"
        )
    
    # WEAK must not increase
    if current_counts["WEAK"] > prev_counts["WEAK"]:
        failures.append(
            f"WEAK increased: {prev_counts['WEAK']} → {current_counts['WEAK']} "
            f"(+{current_counts['WEAK'] - prev_counts['WEAK']})"
        )
    
    # NOT_FOUND must not increase
    if current_counts["NOT_FOUND"] > prev_counts["NOT_FOUND"]:
        failures.append(
            f"NOT_FOUND increased: {prev_counts['NOT_FOUND']} → {current_counts['NOT_FOUND']} "
            f"(+{current_counts['NOT_FOUND'] - prev_counts['NOT_FOUND']})"
        )
    
    # Print summary
    print(f"\n  Before: STRONG={prev_counts['STRONG']} STACKED={prev_counts['STACKED']} "
          f"WEAK={prev_counts['WEAK']} NOT_FOUND={prev_counts['NOT_FOUND']}")
    print(f"  After:  STRONG={current_counts['STRONG']} STACKED={current_counts['STACKED']} "
          f"WEAK={current_counts['WEAK']} NOT_FOUND={current_counts['NOT_FOUND']}")
    
    if failures:
        print(f"\n[pre_repair_snapshot] ❌ REGRESSION DETECTED — {len(failures)} failure(s):")
        for f in failures:
            print(f"  - {f}")
        print(f"\n  ACTION REQUIRED: Roll back the repair or fix the regression before proceeding.")
        sys.exit(1)
    else:
        print(f"\n[pre_repair_snapshot] ✅ PASS — No evidence quality regression detected.")
        print(f"  STRONG maintained or improved, WEAK/NOT_FOUND did not increase.")
        
        # Clean up snapshot on success
        os.remove(SNAPSHOT_FILE)
        print(f"  Snapshot cleared.")


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "snapshot":
        cmd_snapshot()
    else:
        cmd_compare()
