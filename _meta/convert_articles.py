import re, os

CSS = """body{font-family:Georgia,"Times New Roman","Songti SC","Noto Serif CJK SC",SimSun,serif;font-size:16px;line-height:1.92;color:#242424;max-width:680px;margin:0 auto;padding:34px 24px;background:#fff;}h1{font-size:28px;line-height:1.28;font-weight:700;text-align:left;margin:42px 0 28px;color:#111;}h2{font-size:22px;line-height:1.35;font-weight:700;margin:52px 0 18px;color:#111;}h3{font-size:18px;line-height:1.45;font-weight:700;margin:34px 0 12px;color:#333;}p{margin:15px 0;line-height:1.92;}blockquote{margin:28px 0;padding:0 0 0 22px;border-left:3px solid #242424;color:#444;font-size:17px;line-height:1.86;font-style:italic;}ul{margin:15px 0;padding-left:24px;}li{margin:8px 0;line-height:1.9;}strong{font-weight:800;color:#111;}code{font-family:"SFMono-Regular",Consolas,"Liberation Mono",Menlo,monospace;background:#f2f2f2;color:#222;padding:2px 6px;border-radius:3px;font-size:14px;}pre{background:#f2f2f2;color:#222;padding:14px 16px;overflow:auto;font-size:14px;line-height:1.6;}pre code{background:none;padding:0;}hr{border:none;border-top:1px solid #d8d8d8;margin:40px auto;width:34%;}"""

def parse_md_body(text):
    m = re.search(r'## 正文\s*\n(.*?)(?=## 发布信息)', text, re.DOTALL)
    if not m:
        raise ValueError("Cannot find ## 正文 section")
    body = m.group(1).strip()
    body = re.sub(r'^- \*\*标题公式\*\*[^\n]*\n?', '', body, flags=re.MULTILINE)
    body = re.sub(r'^- \*\*字数目标\*\*[^\n]*\n?', '', body, flags=re.MULTILINE)
    body = re.sub(r'^- \*\*素材来源\*\*[^\n]*\n?', '', body, flags=re.MULTILINE)
    return body.strip()

def md_to_html(body):
    lines = body.split('\n')
    result = []
    in_list = False
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.strip() == '':
            if in_list:
                result.append('</ul>')
                in_list = False
            i += 1
            continue
        if line.strip() == '---':
            if in_list:
                result.append('</ul>')
                in_list = False
            result.append('<hr>')
            i += 1
            continue
        m = re.match(r'^### (.+)$', line)
        if m:
            if in_list:
                result.append('</ul>')
                in_list = False
            result.append(f'<h3>{inline_md(m.group(1))}</h3>')
            i += 1
            continue
        m = re.match(r'^## (.+)$', line)
        if m:
            if in_list:
                result.append('</ul>')
                in_list = False
            result.append(f'<h2>{inline_md(m.group(1))}</h2>')
            i += 1
            continue
        m = re.match(r'^- (.+)$', line)
        if m:
            if not in_list:
                result.append('<ul>')
                in_list = True
            result.append(f'<li>{inline_md(m.group(1))}</li>')
            i += 1
            continue
        if line.startswith('> '):
            if in_list:
                result.append('</ul>')
                in_list = False
            bq_lines = []
            while i < len(lines) and lines[i].startswith('> '):
                bq_lines.append(lines[i][2:])
                i += 1
            bq_text = '<br>'.join(inline_md(l) for l in bq_lines)
            result.append(f'<blockquote>{bq_text}</blockquote>')
            continue
        if in_list:
            result.append('</ul>')
            in_list = False
        result.append(f'<p>{inline_md(line)}</p>')
        i += 1
    if in_list:
        result.append('</ul>')
    return '\n'.join(result)

def inline_md(text):
    text = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', text)
    text = re.sub(r'\*(.+?)\*', r'<em>\1</em>', text)
    text = re.sub(r'`([^`]+)`', r'<code>\1</code>', text)
    return text

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

BASE = r"D:\KnowledgeBase\01-内容生产\进行中"
tasks = [
    (os.path.join(BASE, "公众号文章_复利的真正秘密.md"), os.path.join(BASE, "html", "复利的真正秘密.html")),
    (os.path.join(BASE, "公众号文章_三位一体创作法.md"), os.path.join(BASE, "html", "三位一体创作法.html")),
    (os.path.join(BASE, "公众号文章_7个毁掉财富能力的习惯.md"), os.path.join(BASE, "html", "7个毁掉财富能力的习惯.html")),
]

for src, dst in tasks:
    with open(src, "r", encoding="utf-8") as f:
        md_text = f.read()
    title_match = re.match(r'^# (.+)$', md_text, re.MULTILINE)
    title = title_match.group(1) if title_match else os.path.splitext(os.path.basename(dst))[0]
    body_md = parse_md_body(md_text)
    body_html = md_to_html(body_md)
    html = build_html(title, body_html)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    with open(dst, "w", encoding="utf-8") as f:
        f.write(html)
    print(f"OK: {os.path.basename(dst)}  ({len(html)} chars, {body_html.count('<p>')} paragraphs)")

print("\nDone!")
