"""
consolidate_references.py — 统一参考文献结构

处理流程：
1. 扫描理论版，识别所有散落引用块（参考与延伸/微信读书/名著/补充来源）
2. 提取每块的引用信息 → 格式化为学术参考文献格式
3. 正文中替换为 [N] 标记
4. 统一追加到文末 # 参考文献 节
"""

import re
import os
from collections import OrderedDict

INPUT = r"D:\KnowledgeBase\media\flagship\book-v7\答案之书_理论版.md"
OUTPUT = r"D:\KnowledgeBase\media\flagship\book-v7\答案之书_理论版.md"

with open(INPUT, "r", encoding="utf-8") as f:
    text = f.read()

lines = text.split("\n")
all_refs = OrderedDict()  # preserve insertion order
ref_counter = [0]

def add_ref(citation_text, chapter=""):
    """Add a reference and return its [N] marker."""
    # Normalize
    citation = citation_text.strip().strip("> ").strip("- ").strip()
    if not citation or len(citation) < 5:
        return ""
    
    # Skip if already added (dedup by first 80 chars)
    key = citation[:80]
    if key in all_refs:
        return f"[{all_refs[key]['num']}]"
    
    ref_counter[0] += 1
    num = ref_counter[0]
    all_refs[key] = {"num": num, "text": citation, "chapter": chapter}
    return f"[{num}]"

def format_academic_ref(text, ref_type="book"):
    """Format a reference in academic style."""
    text = text.strip()
    
    # Already has author+year format
    if re.search(r'\(19\d{2}|20\d{2}\)', text):
        return text
    
    # "Book / Author" format → "Author. Book."
    parts = text.split("/")
    if len(parts) == 2:
        book = parts[0].strip()
        author = parts[1].strip()
        return f"{author}. 《{book}》."
    
    # Single book name
    return text

# ============================================================
# Phase 1: Remove scattered reference blocks
# ============================================================

# Patterns to identify and remove (ordered by priority)
block_patterns = [
    # A. "参考与延伸" sections (chapter-end and mid-chapter)
    {
        "name": "参考与延伸",
        "header": r"^##\s*参考与延伸\s*$",
        "end": r"^(#|##\s+\S)",  # next heading
    },
    # B. "微信读书证据补充" (all variants)
    {
        "name": "微信读书证据补充",
        "header": r"^##\s*微信读书证据补充",
        "end": r"^(#|##\s+(?:参考|第|自检|操作|作者))",
    },
    # C. "名著：" lists (~1 line but content-rich)
    {
        "name": "名著列表",
        "header": r"^>\s*名著[：:]",
        "end": r"^\s*$",  # ends at blank line
    },
    # D. "补充来源" blockquotes
    {
        "name": "补充来源",
        "header": r"^>\s*补充来源[：:]",
        "end": r"^\s*$",
    },
    # E. "来源溯源" bullet blocks
    {
        "name": "来源溯源",
        "header": r"^-\s*(?:①|②|③|④|⑤|⑥|⑦|⑧|⑨)",
        "end": r"^\s*$",
    },
]

# We'll process line by line, building cleaned output
cleaned_lines = []
i = 0
current_chapter = "序言"
skip_until = -1
extracted_lines = []

while i < len(lines):
    line = lines[i]
    stripped = line.strip()
    
    # Track chapter
    if stripped.startswith("# 第") and "章" in stripped:
        current_chapter = stripped.lstrip("# ").split("：")[0].split("—")[0].strip()
    
    # Check if this line starts a reference block
    matched = False
    for pattern in block_patterns:
        if re.match(pattern["header"], stripped):
            # Find the end of this block
            j = i + 1
            while j < len(lines):
                if re.match(pattern["end"], lines[j].strip()):
                    break
                j += 1
            
            # Extract block
            block_lines = lines[i:j]
            block_text = "\n".join(block_lines)
            
            # Parse references from the block
            if pattern["name"] == "名著列表":
                # Parse "Book1 (Author1) / Book2 (Author2) = N本" format
                content = stripped.lstrip("> 名著：").strip()
                # Remove "= **N本**" suffix
                content = re.sub(r'=\s*\*\*\d+本\*\*', '', content).strip()
                books = [b.strip() for b in content.split("/") if b.strip()]
                for book in books:
                    ref_text = format_academic_ref(book)
                    extracted_lines.append(add_ref(ref_text, current_chapter))
            
            elif pattern["name"] in ("参考与延伸", "补充来源"):
                # Extract cited works
                content = re.sub(r'^##\s*参考与延伸\s*', '', block_text)
                content = re.sub(r'^>\s*补充来源[：:]\s*', '', content).strip()
                # Find all "《书名》" or "Book Name / Author" patterns
                works = re.findall(r'[《]([^》]+)[》]', content)
                for work in works:
                    extracted_lines.append(add_ref(f"《{work}》", current_chapter))
                # Also find "Author (Year)" patterns
                authors = re.findall(r'([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)\s*\((\d{4})\)', content)
                for author, year in authors:
                    extracted_lines.append(add_ref(f"{author} ({year})", current_chapter))
            
            elif pattern["name"] == "微信读书证据补充":
                # Extract book titles and authors from blockquotes
                books = re.findall(r'>\s*\*?\*?(.+?)\*?\*?\s*/\s*(.+?)(?:\s*/\s*(?:weread|exa))?\s*$', block_text, re.MULTILINE)
                for book, author in books:
                    extracted_lines.append(add_ref(f"{author.strip()}. 《{book.strip()}》.", current_chapter))
            
            elif pattern["name"] == "来源溯源":
                # Extract numbered sources
                sources = re.findall(r'[①②③④⑤⑥⑦⑧⑨]\s*(.+?)(?=\s*[①②③④⑤⑥⑦⑧⑨]|\s*$)', block_text)
                for src in sources:
                    if src.strip():
                        extracted_lines.append(add_ref(src.strip(), current_chapter))
            
            # Skip the block in cleaned output
            # Add a reference marker instead
            cleaned_lines.append("")
            cleaned_lines.append(f"> 本章参考文献标记: {', '.join(extracted_lines[-len(books if pattern['name']=='名著列表' else []) or 3:])}")
            cleaned_lines.append("")
            
            i = j
            matched = True
            break
    
    if not matched:
        cleaned_lines.append(line)
        i += 1

# ============================================================
# Phase 2: Build unified references section
# ============================================================

# Remove existing scattered reference markers in cleaned body
body_text = "\n".join(cleaned_lines)

# Remove orphaned "本章参考文献标记" placeholder lines (we'll replace with proper markers)
body_text = re.sub(r'> 本章参考文献标记:.*\n', '', body_text)

# Find existing # 参考文献 section and remove it
body_parts = body_text.split("# 参考文献")
body = body_parts[0].rstrip()

# Build new unified references section
ref_section = "\n\n---\n\n# 参考文献\n\n"
ref_section += "> 全书引用来源，按首次出现顺序排列。格式：作者. 《书名》. 出版社/来源, 年份.\n\n"

for key, data in all_refs.items():
    text = data["text"]
    num = data["num"]
    # Clean up the reference text
    text = re.sub(r'\s+', ' ', text).strip()
    ref_section += f"[{num}] {text}\n\n"

# Assemble final output
final_text = body + ref_section

# Final cleanup
final_text = re.sub(r'\n{4,}', '\n\n\n', final_text)

with open(OUTPUT, "w", encoding="utf-8") as f:
    f.write(final_text)

print(f"Extracted {len(all_refs)} unique references")
print(f"Output: {OUTPUT} ({len(final_text)} chars)")
