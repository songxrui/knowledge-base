"""
rebuild_practice.py — 重建结构化实践版
"""

import re

CLEAN = r"D:\KnowledgeBase\media\flagship\book-v7\FULL_MANUSCRIPT_CLEAN.md"
PRACTICE_OUT = r"D:\KnowledgeBase\media\flagship\book-v7\答案之书_实践版.md"

with open(CLEAN, "r", encoding="utf-8") as f:
    text = f.read()

# ============================================================
# Manually defined action blocks (line ranges from clean manuscript)
# Based on the parallel scan results
# ============================================================

# chapter_name: [(start_line, end_line, section_title)]
action_blocks = {
    "第2章：心理健康": [
        (384, 456, "反脆弱的七个实操原则 + 阶段练习"),
        (457, 495, "自检与行动"),
    ],
    "第3章：身体健康": [
        (890, 945, "自检与行动"),
    ],
    "第4章：财富商业": [
        (1129, 1175, "自检与行动"),
        (1320, 1345, "实操：三层财富决策"),
        (1377, 1420, "操作清单（Buffett/Munger）"),
    ],
    "第5章：人际关系": [
        (1552, 1555, "关系四层架构 — 行动清单"),
        (1609, 1613, "卡耐基的倾听练习"),
        (1615, 1626, "操作1：联结邀请觉察周"),
        (1628, 1634, "操作2：非暴力沟通延时发送"),
        (1642, 1648, "自检与行动"),
        (1857, 1892, "分化练习月 + 进化自察周"),
        (1773, 1816, "自我分化的四步实操"),
    ],
    "第6章：顶级人类": [
        (2055, 2058, "四条模仿路径"),
        (2114, 2123, "自检与行动"),
        (2302, 2340, "中国场景完整模仿路径"),
    ],
    "第7章：问题解决": [
        (2564, 2606, "可执行操作清单"),
        (2617, 2629, "费米估算五个生活案例"),
        (2631, 2655, "预验尸三个实战模板"),
        (2687, 2695, "自检与行动"),
        (2738, 2750, "爱因斯坦问题定义方法论"),
        (2756, 2759, "诊断问题三问"),
    ],
    "第8章：第一性模型": [
        (2983, 2994, "跨学科决策检查清单"),
        (2995, 3017, "可执行操作清单"),
        (3023, 3031, "自检与行动"),
        (3149, 3173, "三个决策工具（贝叶斯/预验尸/决策日志）"),
    ],
}

lines = text.split("\n")

# Build practice edition
output = []
output.append("# 答案之书 — 实践版")
output.append("")
output.append("> 独立实践手册。每章提取自理论版对应章节。")
output.append("> 建议先读完理论版对应章节，再回到这里执行。")  
output.append("> 不要试图一次做完所有练习——一次只做一章，做完稳定后再进入下一章。")
output.append("")
output.append("---")

for chapter, blocks in action_blocks.items():
    output.append("")
    output.append(f"# {chapter}")
    output.append("")
    
    for start, end, title in blocks:
        # Extract lines (0-indexed)
        block_lines = lines[start-1:end]
        
        # Clean up the block
        block_text = "\n".join(block_lines)
        
        # Remove reference tables within action sections
        block_text = re.sub(r'\|.*\|.*\|.*\|.*\|.*\|\n(\|[-|]+\n)?(\|.*\n)*', '', block_text)
        
        # Remove duplicate blank lines
        block_text = re.sub(r'\n{4,}', '\n\n\n', block_text)
        
        if block_text.strip():
            output.append(block_text)
            output.append("")

# Join
practice_text = "\n".join(output)

# Final cleanup
practice_text = re.sub(r'\n{4,}', '\n\n\n', practice_text)

with open(PRACTICE_OUT, "w", encoding="utf-8") as f:
    f.write(practice_text)

print(f"实践版: {PRACTICE_OUT}")
print(f"  {len(practice_text)} chars, {len(practice_text.splitlines())} lines")
print(f"  {sum(1 for b in action_blocks.values() for _ in b)} action blocks across {len(action_blocks)} chapters")
