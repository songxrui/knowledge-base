import os, re

p = r'D:\KnowledgeBase\01-内容生产\dontbesilent 聊赚钱  （每天更新）'

def extract_body_text(filepath):
    """Extract body text between ## 视频转写文本 and next ## section"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all ## headers
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
        if start and i > start:
            # Skip empty lines at the very beginning
            if not text_lines and not stripped:
                continue
            if stripped and not stripped.startswith('---'):
                # Remove timestamp markers like **[00:00 - 00:04]**
                clean = re.sub(r'\*\*\[\d{2}:\d{2} - \d{2}:\d{2}\]\*\*\s*', '', stripped)
                if clean.strip():
                    text_lines.append(clean.strip())
    
    return '\n'.join(text_lines)

# Extract Chapter 1 sources
ch1_keywords = [
    ('2025-05-12', '内耗 = 心理资本'),
    ('2026-06-06', '内耗.*伪命题|内耗.*误会'),
    ('2026-04-29', '50万.*停用|50 万.*停用'),
    ('2025-02-02', '过度总结'),
    ('2026-01-15', '不内耗的赚钱方式'),
]

files = os.listdir(p)
for date_kw, name_kw in ch1_keywords:
    matches = [f for f in files if date_kw in f and re.search(name_kw, f)]
    if matches:
        f = matches[0]
        text = extract_body_text(os.path.join(p, f))
        cn = len(re.findall(r'[\u4e00-\u9fff]', text))
        print(f'=== {f[:60]} ({cn} chars) ===')
        # Print full text up to 2000 chars
        print(text[:2000])
        if len(text) > 2000:
            print(f'\n... [{cn - 2000} more chars]')
        print('\n')
