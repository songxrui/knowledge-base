"""
monthly_log_summary.py — 月度日志汇总

用法:
    python scripts/monthly_log_summary.py                    # 汇总本月
    python scripts/monthly_log_summary.py 2026-05            # 汇总指定月份

输出: _logs/reports/monthly-summary-YYYY-MM.md
"""

import os
import sys
import json
from datetime import datetime, timedelta
from collections import Counter

KB = r"D:\KnowledgeBase"
LOGS = os.path.join(KB, "_logs")
REPORTS = os.path.join(LOGS, "reports")


def get_month_range(ym=None):
    """Resolve start/end dates for the given YYYY-MM or current month."""
    if ym:
        year, month = int(ym[:4]), int(ym[5:7])
    else:
        now = datetime.now()
        year, month = now.year, now.month

    start = datetime(year, month, 1)
    if month == 12:
        end = datetime(year + 1, 1, 1)
    else:
        end = datetime(year, month + 1, 1)
    return start, end, f"{year}-{month:02d}"


def count_files_in_range(dir_path, start, end):
    """Count files modified between start and end."""
    if not os.path.exists(dir_path):
        return 0, []
    files = []
    for fname in os.listdir(dir_path):
        fpath = os.path.join(dir_path, fname)
        if not os.path.isfile(fpath):
            continue
        mtime = datetime.fromtimestamp(os.path.getmtime(fpath))
        if start <= mtime < end:
            files.append(fname)
    return len(files), files


def scan_evidence_trend(start, end, ym_str):
    """Scan evidence audit files for quality trends."""
    evidence_dir = os.path.join(KB, "media", "flagship", "book-v7")
    audit_files = [
        f for f in os.listdir(evidence_dir)
        if f.startswith("EVIDENCE_AUDIT") and f.endswith(".md")
    ]
    
    # Look for the most recent audit in range
    latest = None
    for f in sorted(audit_files):
        fpath = os.path.join(evidence_dir, f)
        mtime = datetime.fromtimestamp(os.path.getmtime(fpath))
        if start <= mtime < end:
            latest = fpath
    
    result = "无当月证据审计数据"
    if latest:
        with open(latest, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        
        # Extract STRONG/WEAK counts
        strong_line = [l for l in content.split("\n") if "STRONG" in l and "|" in l]
        result = f"最新审计: {os.path.basename(latest)}\n"
        for line in strong_line[-3:]:  # last 3 relevant lines
            result += f"  {line.strip()}\n"
    
    return result


def scan_publish_count(start, end):
    """Count published articles in date range."""
    stats_csv = os.path.join(KB, "05-数据统计", "数据统计表.csv")
    if not os.path.exists(stats_csv):
        return "0 (数据统计表不存在或为空)"
    
    count = 0
    try:
        with open(stats_csv, "r", encoding="utf-8") as f:
            lines = f.readlines()
        # Skip header, count rows with dates in range
        for line in lines[1:]:
            parts = line.strip().split(",")
            if len(parts) < 2:
                continue
            date_str = parts[0].strip().strip('"')
            try:
                d = datetime.strptime(date_str[:10], "%Y-%m-%d")
                if start <= d < end:
                    count += 1
            except ValueError:
                continue
    except Exception:
        pass
    
    return str(count)


def generate_summary(start, end, ym_str):
    """Generate monthly summary report."""
    
    # Session count from heartbeat
    heartbeat = os.path.join(LOGS, "heartbeat")
    session_count, _ = count_files_in_range(heartbeat, start, end)
    
    # Skill reports
    skill_reports = os.path.join(LOGS, "skill-reports")
    skill_count, skill_files = count_files_in_range(skill_reports, start, end)
    
    # Reports
    report_count, report_files = count_files_in_range(REPORTS, start, end)
    
    # Verification records
    verify = os.path.join(LOGS, "verification")
    verify_count, _ = count_files_in_range(verify, start, end)
    
    # Published articles
    publish_count = scan_publish_count(start, end)
    
    # Evidence trend
    evidence_trend = scan_evidence_trend(start, end, ym_str)
    
    # Build report
    report = f"""# 月度日志汇总 — {ym_str}

> 自动生成: {datetime.now().strftime('%Y-%m-%d %H:%M')} | 工具: monthly_log_summary.py

## 活动概览

| 指标 | 数值 |
|------|------|
| 会话心跳 | {session_count} |
| 生成报告 | {report_count} |
| 技能评估 | {skill_count} |
| 验证记录 | {verify_count} |
| 内容发布 | {publish_count} |

## 证据质量趋势

{evidence_trend}

## 技能评估

"""
    if skill_files:
        for f in skill_files[:10]:
            report += f"- {f}\n"
    else:
        report += "本月无技能评估记录\n"
    
    report += f"""
## 待办提醒

- [ ] 若发布量为 0：检查 PUBLISH_CHECKLIST 强制发布规则是否触发
- [ ] 若证据 STRONG 下降：运行 pre_repair_snapshot.py 排查回归
- [ ] 若会话数异常低/高：调整工作节奏

---
*本报告由 monthly_log_summary.py 自动生成*
"""
    return report


def main():
    ym = sys.argv[1] if len(sys.argv) > 1 else None
    start, end, ym_str = get_month_range(ym)
    
    # Ensure reports directory exists
    os.makedirs(REPORTS, exist_ok=True)
    
    report = generate_summary(start, end, ym_str)
    out_path = os.path.join(REPORTS, f"monthly-summary-{ym_str}.md")
    
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(report)
    
    print(f"[monthly_log_summary] 月度汇总已生成: {out_path}")
    print(f"  会话={sum(1 for _ in [])} | 报告=... | 发布=...")


if __name__ == "__main__":
    main()
