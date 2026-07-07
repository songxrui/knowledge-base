import os, re

p = r'D:\KnowledgeBase\01-内容生产\dontbesilent 聊赚钱  （每天更新）'

def extract_text(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    lines = content.split('\n')
    start = None
    text_lines = []
    for i, line in enumerate(lines):
        stripped = line.strip()
        if '完整转写文本' in stripped and stripped.startswith('##'):
            start = i + 1
            continue
        if start and stripped.startswith('## ') and '时间戳' in stripped and i > start + 5:
            break
        if start and i >= start:
            if stripped and not stripped.startswith('---'):
                clean = re.sub(r'\*\*\[\d{2}:\d{2} - \d{2}:\d{2}\]\*\*\s*', '', stripped)
                if clean.strip():
                    text_lines.append(clean.strip())
    return '\n'.join(text_lines)

files = os.listdir(p)

# Chapter-to-source mapping
chapter_map = {
    1: [('2025-05-12', '内耗.*心理资本'), ('2026-06-06', '内耗.*伪命题|内耗.*误会'),
        ('2026-04-29', '50万.*停用'), ('2025-02-02', '过度总结'), ('2026-01-15', '不内耗')],
    2: [('2025-10-02', '认知.*关系'), ('2025-03-05', '执行力'),
        ('2025-01-20', '赚钱.*时间'), ('2025-10-15', '能量游戏')],
    3: [('2024-12-14', '自媒体底层'), ('2025-01-13', '涨粉.*变现'),
        ('2025-02-20', '内容变现'), ('2026-04-29', '50万.*停用')],
    4: [('2025-01-13', '涨粉.*变现'), ('2026-01-30', '一人公司')],
    5: [('2026-02-05', '上班.*赚钱|赚不到钱.*上班')],
    6: [('2026-05-06', '擅长.*付费'), ('2026-01-28', '情绪.*生产力')],
    7: [('2025-02-02', '过度总结')],
    8: [('2026-02-05', '三重正反馈|上班.*赚钱'), ('2026-01-30', '一人公司')],
    9: [],  # DBS skill philosophy
    10: [],  # DBS skill philosophy
    11: [('2026-02-08', 'AI.*范式'), ('2025-04-04', 'AI.*干掉|AI.*知识博主'), ('2025-05-20', 'AI.*赚钱')],
    12: [('2025-05-20', 'AI.*赚钱'), ('2025-04-04', 'AI.*干掉')],
    13: [('2026-06-25', '高端客户|定价')],
    14: [('2026-01-30', '一人公司')],
    15: [],  # DBS skill philosophy
    16: [],  # Original
}

total_extracted = 0
for ch_num, sources in sorted(chapter_map.items()):
    ch_total = 0
    for date_kw, name_kw in sources:
        matches = [f for f in files if date_kw in f and re.search(name_kw, f)]
        for f in matches:
            text = extract_text(os.path.join(p, f))
            cn = len(re.findall(r'[\u4e00-\u9fff]', text))
            ch_total += cn
    total_extracted += ch_total
    print(f'Ch{ch_num}: {ch_total} source chars ({len(sources)} source groups)')

print(f'\nTotal source chars extractable: {total_extracted}')
