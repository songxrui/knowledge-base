import re, os

CSS = """body{font-family:Georgia,"Times New Roman","Songti SC","Noto Serif CJK SC",SimSun,serif;font-size:16px;line-height:1.92;color:#242424;max-width:680px;margin:0 auto;padding:34px 24px;background:#fff;}h1{font-size:28px;line-height:1.28;font-weight:700;text-align:left;margin:42px 0 28px;color:#111;}h2{font-size:22px;line-height:1.35;font-weight:700;margin:52px 0 18px;color:#111;}h3{font-size:18px;line-height:1.45;font-weight:700;margin:34px 0 12px;color:#333;}p{margin:15px 0;line-height:1.92;}blockquote{margin:28px 0;padding:0 0 0 22px;border-left:3px solid #242424;color:#444;font-size:17px;line-height:1.86;font-style:italic;}ul{margin:15px 0;padding-left:24px;}li{margin:8px 0;line-height:1.9;}strong{font-weight:800;color:#111;}code{font-family:"SFMono-Regular",Consolas,"Liberation Mono",Menlo,monospace;background:#f2f2f2;color:#222;padding:2px 6px;border-radius:3px;font-size:14px;}pre{background:#f2f2f2;color:#222;padding:14px 16px;overflow:auto;font-size:14px;line-height:1.6;}pre code{background:none;padding:0;}hr{border:none;border-top:1px solid #d8d8d8;margin:40px auto;width:34%;}"""

def convert_bold(text):
    return re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', text)

def md_body_to_html(body):
    lines = body.strip().split('\n')
    result = []
    in_list = False
    in_blockquote = False

    for line in lines:
        stripped = line.strip()

        if stripped == '---':
            if in_list:
                result.append('</ul>')
                in_list = False
            if in_blockquote:
                result.append('</blockquote>')
                in_blockquote = False
            result.append('<hr>')
            continue

        if stripped.startswith('### ') or stripped.startswith('## '):
            if in_list:
                result.append('</ul>')
                in_list = False
            if in_blockquote:
                result.append('</blockquote>')
                in_blockquote = False
            heading = convert_bold(stripped[3:] if stripped.startswith('## ') else stripped[4:])
            result.append(f'<h3>{heading}</h3>')
            continue

        if stripped.startswith('> '):
            if in_list:
                result.append('</ul>')
                in_list = False
            if not in_blockquote:
                result.append('<blockquote>')
                in_blockquote = True
            result.append(f'<p>{convert_bold(stripped[2:])}</p>')
            continue

        if in_blockquote:
            result.append('</blockquote>')
            in_blockquote = False

        if stripped.startswith('- '):
            if not in_list:
                result.append('<ul>')
                in_list = True
            result.append(f'<li>{convert_bold(stripped[2:])}</li>')
            continue

        if in_list and stripped != '':
            result.append('</ul>')
            in_list = False

        if stripped == '':
            continue

        result.append(f'<p>{convert_bold(stripped)}</p>')

    if in_list:
        result.append('</ul>')
    if in_blockquote:
        result.append('</blockquote>')

    return '\n'.join(result)

def extract_body(filepath):
    with open(filepath, 'r', encoding='utf-8-sig') as f:
        content = f.read()

    lines = content.split('\n')
    title = ''
    body_start = 0

    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith('# ') and not stripped.startswith('## '):
            title = stripped[2:]
        if stripped == '## 正文':
            body_start = i + 1
            break

    body_lines = lines[body_start:]
    body_end = len(body_lines)
    for i, line in enumerate(body_lines):
        if line.strip().startswith('## 发布信息'):
            body_end = i
            break

    body = '\n'.join(body_lines[:body_end]).strip()
    return title, body

def build_html(title, body_html):
    return f'''<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{title} - 微信公众号版</title>
<style>
{CSS}
</style>
</head>
<body>

<h1>{title}</h1>

{body_html}

</body>
</html>'''

base = r'D:\KnowledgeBase\01-内容生产\进行中'
files = [
    ('公众号文章_交易员思维迁移.md', 'html/交易员思维迁移.html'),
    ('公众号文章_个人品牌方法论.md', 'html/个人品牌方法论.html'),
]

for md_name, html_name in files:
    md_path = os.path.join(base, md_name)
    html_path = os.path.join(base, html_name)

    title, body = extract_body(md_path)
    body_html = md_body_to_html(body)
    html = build_html(title, body_html)

    os.makedirs(os.path.dirname(html_path), exist_ok=True)
    with open(html_path, 'w', encoding='utf-8-sig') as f:
        f.write(html)
    print(f'OK: {html_path}')
    print(f'   Title: {title}')
    print(f'   Body elements: {body_html.count("<h3>")} h3, {body_html.count("<hr>")} hr, {body_html.count("<strong>")} strong')


