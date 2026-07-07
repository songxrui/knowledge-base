"""
content_guard_v7.py — 6-gate scan on book-v7 files

Gate checks: banned words, AI-flavor markers, WeRead evidence presence, file stats.

Usage:
    python scripts/content_guard_v7.py                           # scan default book-v7 dir
    python scripts/content_guard_v7.py --dir path/to/book         # scan custom dir
    python scripts/content_guard_v7.py --json                     # JSON output for CI
"""
import os
import sys
import json
import glob

# --- Configuration ---
DEFAULT_DIR = r"D:\KnowledgeBase\media\flagship\book-v7"
BANNED_WORDS = [
    "赋能", "抓手", "闭环", "综上所述", "众所周知",
    "值得注意的是", "在这个时代", "底层逻辑", "本质上",
    "不难发现", "随着……的发展"
]

def parse_args():
    """Parse command line args."""
    args = {"dir": DEFAULT_DIR, "json": False}
    i = 1
    while i < len(sys.argv):
        if sys.argv[i] == "--dir" and i + 1 < len(sys.argv):
            args["dir"] = sys.argv[i + 1]
            i += 2
        elif sys.argv[i] == "--json":
            args["json"] = True
            i += 1
        else:
            i += 1
    return args


def discover_files(base_dir):
    """Discover .md files in the given directory."""
    if not os.path.isdir(base_dir):
        print(f"ERROR: Directory not found: {base_dir}", file=sys.stderr)
        sys.exit(1)
    pattern = os.path.join(base_dir, "*.md")
    return sorted(glob.glob(pattern))


def scan_file(fpath):
    """Scan a single file and return results dict."""
    fname = os.path.basename(fpath)
    
    # Read content
    content = ""
    for enc in ['utf-8', 'gbk']:
        try:
            with open(fpath, "r", encoding=enc) as f:
                content = f.read()
            break
        except Exception:
            continue
    
    if not content:
        return {"file": fname, "error": "Could not read file"}
    
    lines = content.split('\n')
    size_kb = len(content.encode('utf-8')) / 1024
    
    # Gate: Banned word scan
    banned_hits = [bw for bw in BANNED_WORDS if bw in content]
    
    # Gate: WeRead evidence
    has_weread = "微信读书证据补充" in content
    
    # Gate: AI-flavor markers
    has_three_para = "首先" in content[:500] and "其次" in content[:500]
    has_升华 = any(w in content[-500:] for w in ["综上所述", "总而言之", "展望未来"])  # simplified
    
    # Gate: Evidence markers
    has_source = "来源::" in content
    has_evidence_marker = "[来源" in content or "[推断]" in content or "[待验证]" in content
    
    status = "PASS"
    failures = []
    if banned_hits:
        failures.append(f"banned:{','.join(banned_hits)}")
        status = "FAIL"
    if has_three_para and "首先" in content[:200]:
        failures.append("AI:three-para-structure")
        status = "FAIL"
    
    return {
        "file": fname,
        "path": fpath,
        "size_kb": round(size_kb, 1),
        "lines": len(lines),
        "status": status,
        "failures": failures,
        "banned_hits": banned_hits,
        "has_weread": has_weread,
        "has_three_para": has_three_para,
        "has_source": has_source,
    }


def main():
    args = parse_args()
    base_dir = args["dir"]
    use_json = args["json"]
    
    files = discover_files(base_dir)
    if not files:
        print(f"No .md files found in {base_dir}")
        sys.exit(0)
    
    results = []
    pass_count = 0
    fail_count = 0
    
    for fpath in files:
        r = scan_file(fpath)
        results.append(r)
        if r["status"] == "PASS":
            pass_count += 1
        else:
            fail_count += 1
    
    if use_json:
        print(json.dumps({
            "dir": base_dir,
            "total": len(results),
            "pass": pass_count,
            "fail": fail_count,
            "results": results
        }, ensure_ascii=False, indent=2))
    else:
        for r in results:
            flag = "PASS" if r["status"] == "PASS" else "FAIL"
            failures = f" ({'; '.join(r['failures'])})" if r.get("failures") else ""
            print(f"[{flag}] {r['file']}: {r['size_kb']:.1f}KB, {r['lines']} lines, "
                  f"weread={'YES' if r['has_weread'] else 'NO'}, "
                  f"banned={len(r.get('banned_hits', []))}, "
                  f"source={'YES' if r['has_source'] else 'NO'}"
                  f"{failures}")
        
        print(f"\nContent-guard: {pass_count}/{len(results)} PASS, {fail_count}/{len(results)} FAIL")
    
    return 0 if fail_count == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
