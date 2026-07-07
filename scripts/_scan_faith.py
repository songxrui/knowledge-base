# faith-humanizer v3.1 scan for FULL_MANUSCRIPT.md
import re

with open('D:\\KnowledgeBase\\media\\flagship\\book-v7\\FULL_MANUSCRIPT.md', 'r', encoding='utf-8') as f:
    content = f.read()
    lines = content.split('\n')

print(f'Total lines: {len(lines)}')
print(f'Total chars: {len(content)}')

# === C1 短句分行检测 ===
short_count = 0
short_samples = []
for i, l in enumerate(lines):
    stripped = l.strip()
    # Skip blank lines, headers, list markers, code blocks, tables, blockquotes
    if not stripped:
        continue
    if any(stripped.startswith(p) for p in ['- ', '* ', '#', '|', '[', '>', '{', '`', '**', '---']):
        continue
    if len(stripped) < 40:
        short_count += 1
        if len(short_samples) < 15:
            short_samples.append((i+1, stripped[:60]))

print(f'\nC1 短行(<40字): {short_count}')
for ln, txt in short_samples:
    print(f'  L{ln}: "{txt}"')

# === C2 列表 ===
bullets = len(re.findall(r'^- ', content, re.MULTILINE))
nums = len(re.findall(r'^\d+\. ', content, re.MULTILINE))
print(f'\nC2 列表: {bullets} bullet + {nums} numbered')

# === C3 内嵌标题列表 ===
c3 = re.findall(r'\*\*[^*]+\*\*:', content)
print(f'\nC3 内嵌标题列表: {len(c3)}')

# === A类 固定句式 ===
a_finds = []
a_patterns = [
    ('三段论', r'首先[^。]*其次[^。]*最后'),
    ('模板转折', r'值得注意的是|不可否认的是|从某种意义上说'),
    ('负平行', r'不仅仅是[^，]*更是|不仅在于[^，]*更在于'),
    ('路标宣告', r'让我们[来深探探讨看]|下面我们'),
    ('权威腔', r'真正的问题是|本质上是|核心在于|说到底，'),
    ('挑战希望模板', r'尽管[^，]*挑战[^。]*但[^。]*希望'),
    ('开放式结尾', r'未来[^。]*充满希望|前路光明|让我们一起期待'),
    ('知识截止', r'据目前可获得的资料|在我最后更新'),
    ('chat残留', r'希望这对你有帮助|当然！'),
    ('过热腔', r'这是一个非常好的问题|你说得非常对'),
]
for name, pat in a_patterns:
    m = re.findall(pat, content)
    if m:
        a_finds.append((name, len(m)))
        for match_text in m[:3]:
            print(f'A类 {name}: "{match_text[:50]}"')

if not a_finds:
    print('\nA类固定句式: 未检出')

# === D类 空话泛话 ===
d_finds = []
d_patterns = [
    ('模糊语', r'在某种程度上|根据具体情况|从这个角度来说'),
    ('无主语句', r'需要更多的研究|应该引起重视|被广泛认为'),
    ('叠床架屋', r'可能[^。]*也许[^。]*或许'),
    ('fillers', r'in order to|due to the fact|at this point in time'),
]
for name, pat in d_patterns:
    m = re.findall(pat, content)
    if m:
        d_finds.append((name, len(m)))

if not d_finds:
    print('\nD类空话泛话: 未检出')

print('\n=== 扫描完成 ===')
