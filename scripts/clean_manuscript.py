"""
clean_manuscript.py — 答案之书 v7 去脚手架 + 提取参考文献 + faith-humanizer

处理流程:
1. 扫描并提取所有来源标注 → 附录参考文献
2. 移除工程痕迹 (来源::, EVIDENCE_LEDGER, exa/weread标签, 版本注释, 验证标记)
3. 应用 faith-humanizer 规则 (固定句式/虚假深度/排版脚手架)
4. 输出清洁版 FULL_MANUSCRIPT_CLEAN.md
"""

import re
import os
from datetime import datetime

INPUT = r"D:\KnowledgeBase\media\flagship\book-v7\FULL_MANUSCRIPT.md"
OUTPUT = r"D:\KnowledgeBase\media\flagship\book-v7\FULL_MANUSCRIPT_CLEAN.md"

# ============================================================
# Step 1: Read manuscript
# ============================================================
with open(INPUT, "r", encoding="utf-8") as f:
    text = f.read()

original_lines = text.split("\n")
print(f"原始: {len(text)} 字符, {len(original_lines)} 行")

# ============================================================
# Step 2: Extract all evidence/reference data for appendix
# ============================================================
references = []
ref_counter = [0]  # mutable counter

def extract_ref(match, label=""):
    ref_counter[0] += 1
    num = ref_counter[0]
    full_text = match.group(0)
    references.append(f"[{num}] {full_text.strip()}  {label}")
    return f"[{num}]"

# ---- 2a: Extract 来源:: blocks (full line until next paragraph break) ----
def extract_sources(text):
    """Extract full 来源:: annotation lines and replace with [N] markers."""
    result_lines = []
    i = 0
    lines = text.split("\n")
    while i < len(lines):
        line = lines[i]
        # Check if line contains 来源:: 
        if "来源::" in line:
            # Collect the full annotation (may span multiple indented/continuation lines)
            annotation_parts = [line]
            j = i + 1
            while j < len(lines) and (
                lines[j].strip().startswith("来源::") or 
                lines[j].strip().startswith("补充:") or
                (lines[j].strip() and not lines[j].strip().startswith("#") and not lines[j].strip().startswith(">") and not lines[j].strip().startswith("-") and not lines[j].strip().startswith("|") and lines[j].strip() != "---" and len(lines[j].strip()) > 20 and (
                    "DOI" in lines[j] or "ISBN" in lines[j] or "exa" in lines[j] or "weread" in lines[j] or "验证" in lines[j] or "LEDGER" in lines[j]
                ))
            ):
                annotation_parts.append(lines[j])
                j += 1
            
            full_annotation = " ".join(annotation_parts)
            ref_counter[0] += 1
            num = ref_counter[0]
            references.append(f"[{num}] {full_annotation.strip()}")
            result_lines.append(f"[{num}]")
            i = j
        else:
            result_lines.append(line)
            i += 1
    
    return "\n".join(result_lines)

text = extract_sources(text)

# ---- 2b: Extract EVIDENCE_LEDGER/PATCH references ----
text = re.sub(
    r'见\s*EVIDENCE_LEDGER\.md\s+[A-Z]\d+\.?\s*',
    lambda m: extract_ref(m, "(证据台账)"),
    text
)
text = re.sub(
    r'见\s*EVIDENCE_PATCH\.md\s+[A-Z]\d+\.?\s*',
    lambda m: extract_ref(m, "(证据补丁)"),
    text
)
# Also clean standalone references
text = re.sub(r'详见EVIDENCE_LEDGER\.md[^。\n]*[。]?', '', text)

# ---- 2c: Extract DOI references ----
text = re.sub(
    r'DOI:\s*10\.\d{4,}/[^\s,，。]+',
    lambda m: extract_ref(m, "(DOI)"),
    text
)

# ============================================================
# Step 3: Remove engineering scaffolding
# ============================================================

# ---- 3a: Remove version notes ----
text = re.sub(r'注:\s*v\d[^。\n]*[。\n]?', '', text)
text = re.sub(r'经库外验证修正[。]?', '', text)
text = re.sub(r'★外部独立验证通过[^。\n]*[。]?', '', text)

# ---- 3b: Remove status markers ----
text = re.sub(r'待核[，,]?\s*', '', text)
text = re.sub(r'已核[，,]?\s*', '', text)
text = re.sub(r'保留\[B\][，,]?\s*', '', text)
text = re.sub(r'降级待定[。]?', '', text)
text = re.sub(r'数据合理但需精确引用[。]?', '', text)

# ---- 3c: Clean exa/weread labels from blockquotes ----
# "— Book / Author / exa" → "— Book / Author"
text = re.sub(r'\s*/\s*exa-fetch\b', '', text)
text = re.sub(r'\s*/\s*exa\b(?!m)', '', text)  # avoid "example" 
text = re.sub(r'\s*/\s*weread\b', '', text)

# ---- 3d: Remove standalone " / exa" at end of lines ----
text = re.sub(r'\s*/\s*exa\s*$', '', text, flags=re.MULTILINE)
text = re.sub(r'\s*/\s*weread\s*$', '', text, flags=re.MULTILINE)

# ---- 3e: Clean 🔗 cross-chapter annotations (keep the link text, remove emoji+bold) ----
text = re.sub(r'🔗\s*\*\*与CH\d+[^*]*\*\*[：:]?\s*', '> ', text)

# ---- 3f: Clean "> 第X章补充来源" headers ----
text = re.sub(r'>\s*第\d+章补充来源[：:][^\n]*\n?', '', text)

# ---- 3g: Clean reference tables (exa/weread columns) ----
# Remove "exa" and "weread" from table cells
text = re.sub(r'\|\s*exa\s*\|', '| — |', text)
text = re.sub(r'\|\s*weread\s*\|', '| — |', text)

# ---- 3h: Clean "来源：" inline annotations (not 来源::) ----
text = re.sub(r'来源[：:]\s*[^\n]*?/\s*exa\s*', '', text)

# ---- 3i: Clean "（微信读书·X条笔记）" parenthetical stats ----
text = re.sub(r'（微信读书[·\d]*条笔记）', '', text)
text = re.sub(r'（微读[·\d]*条笔记）', '', text)

# ---- 3j: Remove "v3声称/v3误标" remaining fragments ----
text = re.sub(r'v\d[^。\n，,]*?(?:声称|误标|错误|标注)[^。\n]*[。]?', '', text)

# ---- 3k: Clean multi-blank lines ----
text = re.sub(r'\n{4,}', '\n\n\n', text)

# ============================================================
# Step 4: Apply faith-humanizer voice rules
# ============================================================

# ---- 4a: A类固定句式 ----
# A3: "不仅仅是X，更是Y" → "是Y"
text = re.sub(r'不仅仅是[^，,]*[，,]\s*更是', '是', text)
# A5: "真正的问题是" → 直接说
text = re.sub(r'真正的问题是[：:]?\s*', '', text)

# ---- 4b: B类虚假深度 ----
# B1: 空泛高频词
for word in ['至关重要的', '深刻的', '重大的', '不可否认的是']:
    text = text.replace(word, '')
# B7: "serves as/stands as" → 直接用"是" (in Chinese: "作为"→"是")
# (Chinese version: not much to do here as the text is already in Chinese)

# ---- 4c: C类排版脚手架 ----
# C6: emoji removal (but keep section markers)
text = re.sub(r'[🚩⚠️✅❌🔴🟡🟢🟠⚪]', '', text)

# ---- 4d: D类空话 ----
# D2: 过度"可能/也许" → (keep first instance check done manually)

# ---- 4e: Clean up orphaned punctuation ----
text = re.sub(r'，\s*，', '，', text)
text = re.sub(r'。\s*。', '。', text)
text = re.sub(r'\s+。', '。', text)

# ============================================================
# Step 5: Build appendix
# ============================================================
appendix = "\n\n---\n\n# 参考文献\n\n"
appendix += "> 以下为全书引用的证据来源，按正文出现顺序排列。\n\n"
for i, ref in enumerate(references):
    appendix += f"{ref}\n\n"

# ============================================================
# Step 6: Write output
# ============================================================
output_text = text.rstrip() + appendix

# Update header timestamp
output_text = output_text.replace(
    "> 生成时间:",
    f"> 清洁版生成: {datetime.now().strftime('%Y-%m-%d %H:%M')} | 原始版本:"
)

with open(OUTPUT, "w", encoding="utf-8") as f:
    f.write(output_text)

print(f"清洁版: {len(output_text)} 字符, {len(output_text.split(chr(10)))} 行")
print(f"提取参考文献: {len(references)} 条")
print(f"输出: {OUTPUT}")
