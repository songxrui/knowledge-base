"""
reformat_book.py — 按中文书籍排版规范重排答案之书

规则（基于 GB/T 9704 + 中信/机工社商业书版规范）:
1. [N] 独立行标记 → 融合到前段末尾
2. --- → * * * 或两空行
3. 块引用 > → 引用段+右对齐出处
4. **粗体** → 适度保留（核心概念突出）
5. 元数据行（核心问题/覆盖X个学派）→ 转为自然段首导入
6. 微信读书引用行 → 清理为自然引用
7. 参考文献节 → 格式统一
8. 段落空行 → 控制节奏
"""

import re

INPUT = r"D:\KnowledgeBase\media\flagship\book-v7\答案之书_理论版.md"
OUTPUT = r"D:\KnowledgeBase\media\flagship\book-v7\答案之书_理论版.md"

with open(INPUT, "r", encoding="utf-8") as f:
    text = f.read()

# ============================================================
# Step 1: Merge standalone [N] markers into preceding paragraph
# ============================================================

lines = text.split("\n")
merged = []
i = 0
while i < len(lines):
    line = lines[i]
    stripped = line.strip()
    
    # If current line is a bare [N] marker
    if re.match(r'^\[\d+\]$', stripped):
        ref_num = stripped
        # Find the preceding non-empty content line
        j = len(merged) - 1
        while j >= 0 and not merged[j].strip():
            j -= 1
        if j >= 0:
            # Check if previous line ends with punctuation — append before any trailing spaces
            prev = merged[j].rstrip()
            if prev and prev[-1] in '。！？）)」』'':':
                merged[j] = prev + ref_num
            else:
                merged[j] = prev + ref_num
            # Drop the blank lines between them
            while merged and not merged[-1].strip():
                merged.pop()
        i += 1
        continue
    
    merged.append(line)
    i += 1

text = "\n".join(merged)

# ============================================================
# Step 2: Clean section dividers
# ============================================================

# Replace isolated --- with * * * (except chapter boundary ---)
# Keep --- before # 第X章 headers (chapter boundaries)
text = re.sub(r'\n---\n(?!\n# |\n\s*# )', '\n\n* * *\n\n', text)

# ============================================================  
# Step 3: Clean blockquote citations
# ============================================================

# Pattern: "> "Quote text." — Book / Author" 
# Convert to: indented quote + right-aligned attribution
def clean_blockquote(match):
    quote = match.group(0)
    # Extract: remove >, clean up
    quote = re.sub(r'^>\s*', '', quote, flags=re.MULTILINE)
    quote = quote.strip()
    # If it has "— Book / Author" pattern, split
    if '—' in quote or '——' in quote:
        parts = re.split(r'[—]{1,2}', quote, maxsplit=1)
        if len(parts) == 2:
            body = parts[0].strip().strip('"').strip('"').strip()
            attr = parts[1].strip()
            return f'> {body}\n>\n> ——{attr}'
    return f'> {quote}'

text = re.sub(r'(?:^> .*\n)+', clean_blockquote, text, flags=re.MULTILINE)

# ============================================================
# Step 4: Clean metadata headers into natural prose
# ============================================================

# "> 核心问题：XXX" → "本章试图回答一个问题：XXX"
text = re.sub(
    r'>\s*核心问题[：:]\s*(.+?)(?:\n>.*?覆盖.*?)?\n',
    r'> 本章试图回答一个问题：\1\n\n',
    text
)

# Remove "> 覆盖X个..." lines
text = re.sub(r'>\s*覆盖[^\n]+\n', '', text)

# ============================================================
# Step 5: Clean 微信读书 citation lines  
# ============================================================

# "> **书名** / 作者（?）" → cleaned attribution
text = re.sub(r'> \*\*(.+?)\*\*\s*/\s*(.+?)(?:\s*（\?）)?\s*$', r'> ——\2《\1》', text, flags=re.MULTILINE)

# ============================================================
# Step 6: Normalize whitespace
# ============================================================

# Max 2 consecutive blank lines
text = re.sub(r'\n{3,}', '\n\n', text)

# Remove trailing whitespace
text = re.sub(r'[ \t]+$', '', text, flags=re.MULTILINE)

# ============================================================
# Step 7: Clean references section formatting  
# ============================================================

# Split at 参考文献
parts = text.split("# 参考文献")
if len(parts) >= 2:
    body = parts[0].rstrip()
    refs = parts[1]
    
    # Clean reference entries: ensure consistent format
    # [N] text → [N] text
    refs = re.sub(r'^\[(\d+)\]\s*', r'[\1] ', refs, flags=re.MULTILINE)
    
    # Rebuild
    text = body + "\n\n* * *\n\n# 参考文献\n\n" + refs.strip()

# ============================================================
# Step 8: Final pass
# ============================================================
text = re.sub(r'\n{4,}', '\n\n\n', text)

with open(OUTPUT, "w", encoding="utf-8") as f:
    f.write(text)

print(f"重排完成: {OUTPUT}")
print(f"  {len(text)} chars, {len(text.splitlines())} lines")
