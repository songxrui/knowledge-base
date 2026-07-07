# -*- coding: utf-8 -*-
"""Generate WeChat Reader PDF for 姜胡说之书"""
import re, os, glob

from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
for path, name in [(r'C:\Windows\Fonts\simsun.ttc', 'SimSun'), (r'C:\Windows\Fonts\msyh.ttc', 'Microsoft YaHei')]:
    if os.path.exists(path):
        pdfmetrics.registerFont(TTFont(name, path, subfontIndex=0) if path.endswith('.ttc') else TTFont(name, path))
        body_font = name
        print(f'Font: {name}')
        break

from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import cm
from reportlab.lib.colors import HexColor
from reportlab.lib.enums import TA_CENTER
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer, HRFlowable, PageBreak)

# Combine chapters
base = r'D:\KnowledgeBase\01-内容生产\姜胡说之书\chapters'
chapters = sorted(glob.glob(os.path.join(base, '*.md')))
lines = []
for f in chapters:
    content = open(f, 'r', encoding='utf-8').read()
    content = re.sub(r'^> 上一章.*\n> 本章.*\n> 下一章.*\n', '', content, flags=re.MULTILINE)
    lines.append(content)
full_md = '\n\n'.join(lines)

styles = {
    'cover_title': ParagraphStyle('ct', fontName=body_font, fontSize=26, leading=38, alignment=TA_CENTER, spaceAfter=20, textColor=HexColor('#1a1a1a')),
    'cover_sub': ParagraphStyle('cs', fontName=body_font, fontSize=14, leading=22, alignment=TA_CENTER, spaceAfter=8, textColor=HexColor('#666')),
    'toc_title': ParagraphStyle('tt', fontName=body_font, fontSize=22, leading=34, alignment=TA_CENTER, spaceAfter=30, textColor=HexColor('#111')),
    'toc_item': ParagraphStyle('ti', fontName=body_font, fontSize=12, leading=22, spaceAfter=4, textColor=HexColor('#333')),
    'h1': ParagraphStyle('h1', fontName=body_font, fontSize=18, leading=30, spaceAfter=16, spaceBefore=30, textColor=HexColor('#111')),
    'h2': ParagraphStyle('h2', fontName=body_font, fontSize=14, leading=24, spaceAfter=10, spaceBefore=20, textColor=HexColor('#222')),
    'h3': ParagraphStyle('h3', fontName=body_font, fontSize=12, leading=20, spaceAfter=8, spaceBefore=14, textColor=HexColor('#333')),
    'body': ParagraphStyle('body', fontName=body_font, fontSize=11, leading=20, spaceAfter=6, spaceBefore=2, firstLineIndent=22, textColor=HexColor('#333')),
    'quote': ParagraphStyle('quote', fontName=body_font, fontSize=10, leading=17, spaceAfter=8, spaceBefore=8, leftIndent=24, textColor=HexColor('#555'), backColor=HexColor('#f8f8f8')),
}

def proc(text):
    return re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', text)

story, toc_entries = [], []

# COVER
story.append(Spacer(1, 6*cm))
story.append(Paragraph('姜胡说', styles['cover_title']))
story.append(Paragraph('之书', styles['cover_title']))
story.append(Spacer(1, 1.5*cm))
story.append(HRFlowable(width='30%', thickness=1, color=HexColor('#999')))
story.append(Spacer(1, 1*cm))
story.append(Paragraph('思考 · 行动 · 成长', styles['cover_sub']))
story.append(PageBreak())

# TOC
story.append(Spacer(1, 2*cm))
story.append(Paragraph('目  录', styles['toc_title']))
story.append(Spacer(1, 0.5*cm))

# BODY
blocks = full_md.split('\n')
i = 0
while i < len(blocks):
    line = blocks[i].rstrip()
    if not line.strip(): i += 1; continue
    if line.startswith('# ') and not line.startswith('## '):
        title = proc(line[2:])
        toc_entries.append((1, title))
        story.append(Paragraph(title, styles['h1']))
        story.append(HRFlowable(width='100%', thickness=1.5, color=HexColor('#333')))
        story.append(Spacer(1, 6))
        i += 1; continue
    if line.startswith('## '):
        title = proc(line[3:])
        toc_entries.append((2, title))
        story.append(Paragraph(title, styles['h2']))
        i += 1; continue
    if line.startswith('### '):
        title = proc(line[4:])
        toc_entries.append((3, title))
        story.append(Paragraph(title, styles['h3']))
        i += 1; continue
    if line.strip() == '---':
        story.append(Spacer(1, 10))
        story.append(HRFlowable(width='40%', thickness=0.5, color=HexColor('#ddd')))
        story.append(Spacer(1, 10))
        i += 1; continue
    if line.startswith('> '):
        qlines = []
        while i < len(blocks) and blocks[i].startswith('> '):
            qlines.append(blocks[i][2:].strip()); i += 1
        story.append(Paragraph('<br/>'.join(proc(l) for l in qlines), styles['quote']))
        continue
    if line.strip():
        story.append(Paragraph(proc(line.strip()), styles['body']))
    i += 1

# Insert TOC
toc_start = 6
for level, title in toc_entries:
    indent = '    ' if level > 1 else ''
    story.insert(toc_start, Paragraph(f'{indent}{title}', styles['toc_item']))
    toc_start += 1
story.insert(toc_start, PageBreak())

# Page numbering
def on_page(canvas, doc):
    canvas.saveState()
    canvas.setFont(body_font, 8)
    canvas.setFillColor(HexColor('#999'))
    canvas.drawCentredString(A4[0]/2, 1.5*cm, f'- {canvas.getPageNumber()} -')
    canvas.restoreState()

def on_cover(canvas, doc): pass

pdf_file = r'D:\KnowledgeBase\01-内容生产\姜胡说之书\姜胡说之书.pdf'
doc = SimpleDocTemplate(pdf_file, pagesize=A4, rightMargin=2.5*cm, leftMargin=2.5*cm, topMargin=2.5*cm, bottomMargin=2.5*cm,
                         title='姜胡说之书', author='姜胡说')
doc.build(story, onFirstPage=on_cover, onLaterPages=on_page)

try:
    from pikepdf import Pdf
    pdf = Pdf.open(pdf_file, allow_overwriting_input=True)
    with pdf.open_outline() as outline:
        for level, title in toc_entries:
            outline.add(re.sub(r'[<>]', '', title)[:60], 0)
    pdf.save(pdf_file)
    print(f'Bookmarks: {len(toc_entries)}')
except Exception as e:
    print(f'Bookmarks skipped: {e}')

size_kb = os.path.getsize(pdf_file) // 1024
cn = len(re.findall(r'[\u4e00-\u9fff]', full_md))
print(f'PDF: {size_kb}KB, {cn} chars, {len(toc_entries)} sections')
