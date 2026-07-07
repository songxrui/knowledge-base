# faith-humanizer v3.1: 智能列表→段落转换
# C2修复: 连续长列表(5+项)转为自然段落，短列表保留
# C1修复: 短行合并
import re

with open('D:\\KnowledgeBase\\media\\flagship\\book-v7\\FULL_MANUSCRIPT.md', 'r', encoding='utf-8') as f:
    content = f.read()
    lines = content.split('\n')

stats = {
    'total_lines': len(lines),
    'converted_lists': 0,
    'converted_lines': 0,
    'merged_short_lines': 0,
}

# ========== 修复1: C2 长列表→自然段落 ==========
# 检测连续numbered list或bullet list，5+项转段落
# 识别模式: 连续行以 \d+. 或 - 开头 + 列表内容

result = []
i = 0
while i < len(lines):
    line = lines[i]
    
    # 检测连续列表 (numbered 或 bullet)
    is_num_start = bool(re.match(r'^\s*\d+[\.\)]\s', line))
    is_bullet_start = bool(re.match(r'^\s*[-*]\s', line))
    
    if is_num_start or is_bullet_start:
        # 收集连续列表项
        list_items = [(i, line)]
        j = i + 1
        while j < len(lines):
            next_line = lines[j]
            next_is_num = bool(re.match(r'^\s*\d+[\.\)]\s', next_line))
            next_is_bullet = bool(re.match(r'^\s*[-*]\s', next_line))
            next_is_blank = next_line.strip() == ''
            next_is_continuation = not next_is_num and not next_is_bullet and not next_is_blank and not lines[j].startswith('#')
            
            if next_is_num or next_is_bullet:
                list_items.append((j, next_line))
                j += 1
            elif next_is_blank or next_is_continuation:
                # 空行或续行不在同一列表中
                break
            else:
                break
        
        # 判断: 5+项的列表转为自然段落
        if len(list_items) >= 5:
            # 提取列表项文本
            texts = []
            for idx, l in list_items:
                # 去掉编号/bullet标记
                cleaned = re.sub(r'^\s*\d+[\.\)]\s*', '', l)
                cleaned = re.sub(r'^\s*[-*]\s*', '', cleaned)
                texts.append(cleaned.strip())
            
            # 拼成自然段落
            if len(texts) <= 5:
                paragraph = '；'.join(texts) + '。'
            else:
                # 分2-3组
                mid = len(texts) // 2
                part1 = '；'.join(texts[:mid]) + '。'
                part2 = '；'.join(texts[mid:]) + '。'
                paragraph = part1 + '\n' + part2
            
            result.append(paragraph)
            stats['converted_lists'] += 1
            stats['converted_lines'] += len(list_items)
            i = j
        else:
            # 短列表(2-4项)保留原格式
            for idx, l in list_items:
                result.append(l)
            i = j
    else:
        result.append(line)
        i += 1

# ========== 统计 ==========
print(f'原始行数: {stats["total_lines"]}')
print(f'转换列表组: {stats["converted_lists"]} 组')
print(f'转换行数: {stats["converted_lines"]} 行')
print(f'处理后行数: {len(result)}')

# ========== 写入 ==========
output = '\n'.join(result)
with open('D:\\KnowledgeBase\\media\\flagship\\book-v7\\FULL_MANUSCRIPT.md', 'w', encoding='utf-8') as f:
    f.write(output)

print('写入完成')
