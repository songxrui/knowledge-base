"""
split_theory_practice.py — 从清洁版拆分为理论版和实践版

理论版: 移除所有行动/实操/自检/练习内容
实践版: 提取所有行动内容，重组为独立实践手册
"""

import re

INPUT = r"D:\KnowledgeBase\media\flagship\book-v7\FULL_MANUSCRIPT_CLEAN.md"
THEORY_OUT = r"D:\KnowledgeBase\media\flagship\book-v7\答案之书_理论版.md"
PRACTICE_OUT = r"D:\KnowledgeBase\media\flagship\book-v7\答案之书_实践版.md"

with open(INPUT, "r", encoding="utf-8") as f:
    text = f.read()

lines = text.split("\n")

# ============================================================
# Step 1: Identify action section boundaries
# ============================================================

# Headers that mark the START of an action-only section
action_section_headers = [
    "## 自检与行动",
    "## 可执行操作清单",
    "## 分化练习月 + 进化自察周",
    "## 操作清单",
    "## 跨学科决策检查清单",
    "### 操作1",
    "### 操作2",
    "### 操作3",
    "### 操作4",
    "### 卡耐基的倾听练习",
    "### 费米估算深度实战",
    "### 预验尸在个人决策中的三个实战模板",
    "### 爱因斯坦的问题定义方法论",
    "### 自我分化的四步实操",
    "### 进化心理学的实操含义",
    "## 中国场景下的完整模仿路径",
    "## Buffett/Munger的决策引擎",
]

# Headers that are theory sections (NOT action)
theory_section_headers = [
    "## 七大心理学派的核心工具箱",
    "## 财富的三层定义与新杠杆",
    "## 关系的三条科学定律",
    "## 五人的共同模式",
    "## 解题的通用框架",
    "## 从每个学科",
    "## 作者亲历",
    "# 第",
    "# 序言",
    "# 参考文献",
]

def is_action_header(line):
    """Check if line is an action section header."""
    stripped = line.strip()
    for h in action_section_headers:
        if stripped.startswith(h):
            return True
    return False

def is_theory_header(line):
    """Check if line is a theory/concept section header."""
    stripped = line.strip()
    for h in theory_section_headers:
        if stripped.startswith(h):
            return True
    if re.match(r'^### \d+\.', stripped):  # Numbered subsections like "### 1. CBT"
        return True
    return False

# ============================================================
# Step 2: Mark lines as theory or action
# ============================================================

# We'll track which sections are action-mode
line_mode = []  # 'theory' or 'action' for each line
current_mode = 'theory'
in_action_section = False
action_section_depth = 0  # track ## vs ### nesting

for i, line in enumerate(lines):
    stripped = line.strip()
    
    # Detect action section start
    if is_action_header(stripped) and stripped.startswith("## "):
        current_mode = 'action'
        in_action_section = True
        action_section_depth = 2
    elif is_action_header(stripped) and stripped.startswith("### "):
        current_mode = 'action'
        in_action_section = True
        action_section_depth = 3
    # Detect theory section start (overrides action mode)
    elif is_theory_header(stripped) and stripped.startswith("## "):
        current_mode = 'theory'
        in_action_section = False
        action_section_depth = 0
    elif is_theory_header(stripped) and stripped.startswith("# "):
        current_mode = 'theory'
        in_action_section = False
    
    # Detect action section end: next ## header that's not action
    if stripped.startswith("## ") and not is_action_header(stripped) and in_action_section:
        if action_section_depth >= 2:
            current_mode = 'theory'
            in_action_section = False
    
    line_mode.append(current_mode)

# ============================================================
# Step 3: Additional inline action detection
# ============================================================

# Scan for inline "实操：" blocks within theory sections
# These are embedded action tips we want to extract
inline_action_patterns = [
    (r'^实操[：:].*$', 'inline_action'),
    (r'^关键实操[：:].*$', 'inline_action'),
    (r'^\d+\.\s*\*\*.*练习.*\*\*', 'inline_action'),
]

# ============================================================
# Step 4: Build theory edition (remove action sections)
# ============================================================

theory_lines = []
skipped_lines = []
current_theory_block = []

for i, (line, mode) in enumerate(zip(lines, line_mode)):
    if mode == 'theory':
        theory_lines.append(line)
    else:
        # Keep track of what we removed for practice edition
        if line.strip():
            skipped_lines.append((i+1, line))

# Clean up: remove orphaned blank lines (3+ consecutive blanks → 2)
theory_text = "\n".join(theory_lines)
theory_text = re.sub(r'\n{4,}', '\n\n\n', theory_text)

# ============================================================
# Step 5: Build practice edition (extract action sections)
# ============================================================

practice_parts = []
current_chapter = "序言"

for i, (line, mode) in enumerate(zip(lines, line_mode)):
    stripped = line.strip()
    
    # Track current chapter
    if stripped.startswith("# 第") or stripped.startswith("# 序言"):
        current_chapter = stripped.lstrip("# ").split("：")[0].split("—")[0].strip()
    
    if mode == 'action':
        practice_parts.append((current_chapter, i+1, line))

# Build practice edition text
practice_text = "# 答案之书 v7 — 实践版\n\n"
practice_text += "> 本版为独立实践手册。每章提取自理论版对应章节的末尾行动系统。\n"
practice_text += "> 建议先读完理论版对应章节，再回到这里执行。\n\n"
practice_text += "---\n\n"

current_ch = None
for ch, lineno, line in practice_parts:
    if ch != current_ch:
        current_ch = ch
        practice_text += f"\n# {current_ch}\n\n"
    practice_text += line + "\n"

# ============================================================
# Step 6: Write outputs
# ============================================================

# Theory edition
with open(THEORY_OUT, "w", encoding="utf-8") as f:
    f.write(theory_text)

# Practice edition
with open(PRACTICE_OUT, "w", encoding="utf-8") as f:
    f.write(practice_text)

# Stats
theory_action_lines = sum(1 for m in line_mode if m == 'action')
total_lines = len(lines)

print(f"理论版: {THEORY_OUT}")
print(f"  总行数: {len(theory_lines)} | 移除行动行: {theory_action_lines}/{total_lines}")
print(f"实践版: {PRACTICE_OUT}")
print(f"  行动行数: {sum(1 for m in line_mode if m == 'action')}")
print("Done")
