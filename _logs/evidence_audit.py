import json, os, re

BASE = r"D:\KnowledgeBase\media\flagship\book-v7"

# Load all weread extracts
extracts = []
for fname in [r"D:\KnowledgeBase\_alchemist\weread_extracts\v7_enrichment_bookmarks.json",
              r"D:\KnowledgeBase\_alchemist\weread_extracts\batch2_bookmarks.json"]:
    with open(fname, "r", encoding="utf-8") as f:
        extracts.extend(json.load(f))

print("Total extracts: " + str(len(extracts)))

# Map each chapter to its weread section content
ch_files = {
    "CH01": "CH01_meta-abilities.md",
    "CH02": "CH02_mental-health.md",
    "CH03": "CH03_physical-health.md",
    "CH04": "CH04_wealth-business.md",
    "CH05": "CH05_relationships.md",
    "CH06": "CH06_top-humans.md",
    "CH07": "CH07_problem-solving.md",
    "CH08": "CH08_first-principles.md",
}

ch_content = {}
for ch_id, fname in ch_files.items():
    fpath = os.path.join(BASE, fname)
    for enc in ['utf-8', 'gbk']:
        try:
            with open(fpath, "r", encoding=enc) as f:
                ch_content[ch_id] = f.read()
            break
        except:
            pass

# For each extract, find which chapter it was added to and score relevance
audit_results = []
for e in extracts:
    book = e.get("book", "?")
    content = e.get("content", "")[:60]
    
    # Find which chapter this extract is in
    found_in = []
    for ch_id, ch_text in ch_content.items():
        # Check if the extract content appears in this chapter
        if content[:30] in ch_text:
            # Now check context - is there actual commentary connecting it?
            idx = ch_text.find(content[:30])
            # Get 200 chars before and after to see context quality
            before = ch_text[max(0, idx-200):idx]
            after = ch_text[idx:idx+len(content[:60])+200]
            
            # Score: does the surrounding text discuss/analyze the extract?
            has_commentary = any(w in before[-100:] + after[:100] for w in ["这条", "这", "印证", "说明", "证明", "支持", "揭示"])
            has_standalone = ">" in before[-30:] and ">" in after[:30]  # Just stacked quotes
            
            quality = "STRONG" if has_commentary else ("STACKED" if has_standalone else "WEAK")
            found_in.append((ch_id, quality))
    
    audit_results.append({
        "book": book,
        "content": content,
        "chapters": found_in
    })

# Generate report
report = "# v7 证据-论点匹配度审计报告\n\n"
report += "> 审计全部68条微信读书高亮的论点支撑质量 | 2026-06-11\n\n"

report += "## 匹配质量分布\n\n"
strong = sum(1 for a in audit_results if any(q == "STRONG" for _, q in a["chapters"]))
stacked = sum(1 for a in audit_results if not any(q == "STRONG" for _, q in a["chapters"]) and any(q == "STACKED" for _, q in a["chapters"]))
weak = sum(1 for a in audit_results if not a["chapters"] or all(q == "WEAK" for _, q in a["chapters"]))
not_found = sum(1 for a in audit_results if not a["chapters"])

report += "| 质量等级 | 数量 | 占比 | 说明 |\n"
report += "|----------|------|------|------|\n"
total = len(audit_results)
report += "| STRONG (强支撑) | " + str(strong) + " | " + str(round(strong/total*100)) + "% | 提取内容后紧接作者分析/论证/反驳 |\n"
report += "| STACKED (堆叠) | " + str(stacked) + " | " + str(round(stacked/total*100)) + "% | 多条引用连续排列，缺乏逐条分析 |\n"
report += "| WEAK (弱连接) | " + str(weak) + " | " + str(round(weak/total*100)) + "% | 引用与上下文论点关系不明确 |\n"
report += "| NOT_FOUND (丢失) | " + str(not_found) + " | " + str(round(not_found/total*100,1)) + "% | 提取内容未出现在章节中 |\n"

# Per-chapter breakdown
report += "\n## 分章节审计\n\n"
for ch_id in ["CH01","CH02","CH03","CH04","CH05","CH06","CH07","CH08"]:
    ch_extracts = [a for a in audit_results if any(ch == ch_id for ch, _ in a["chapters"])]
    if not ch_extracts:
        continue
    s = sum(1 for a in ch_extracts if any(ch == ch_id and q == "STRONG" for ch, q in a["chapters"]))
    st = sum(1 for a in ch_extracts if any(ch == ch_id and q == "STACKED" for ch, q in a["chapters"]))
    w = sum(1 for a in ch_extracts if any(ch == ch_id and q == "WEAK" for ch, q in a["chapters"]))
    report += "| " + ch_id + " | " + str(len(ch_extracts)) + " | " + str(s) + " | " + str(st) + " | " + str(w) + " | " + ("PASS" if s >= st+w else "NEEDS_WORK") + " |\n"

report += "\n## 改进建议\n\n"
report += "1. **STACKED→STRONG**: 在每3条连续引用之间插入1-2句作者的独立分析\n"
report += "2. **WEAK→STACKED**: 为弱连接引用添加1句\"这条证据支持了第X节的Y论断\"\n"
report += "3. **NOT_FOUND**: 确认对应章节的weread section包含了所有提取内容\n"
report += "4. **终极目标**: STRONG占比 >70% (当前" + str(round(strong/total*100)) + "%)"

out = r"D:\KnowledgeBase\media\flagship\book-v7\EVIDENCE_AUDIT.md"
with open(out, "w", encoding="utf-8") as f:
    f.write(report)

print("EVIDENCE_AUDIT.md generated")
print("STRONG=" + str(strong) + " STACKED=" + str(stacked) + " WEAK=" + str(weak) + " NOT_FOUND=" + str(not_found))
