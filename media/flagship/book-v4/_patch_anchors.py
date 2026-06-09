# -*- coding: utf-8 -*-
import re

filepath = r"D:\KnowledgeBase\media\flagship\book-v4\FULL_MANUSCRIPT.md"
with open(filepath, "r", encoding="utf-8") as f:
    content = f.read()

patches = []

# S1-S3: Karpicke + Maye
patches.append((
    "*2025\u5e74\u5b9a\u91cf\u8bc1\u636e**: [S] Karpicke\u7efc\u5408\u56de\u987e(Purdue 2025):\u68c0\u7d22\u7ec3\u4e60\u6548\u5e94\u91cfg=0.50,\u4f18\u4e8e81%\u5bf9\u7167\u6761\u4ef6\uff0c\u4f18\u4e8e81%\u7684\u5bf9\u7167\u6761\u4ef6\u3002[S] \u95f4\u9694+\u68c0\u7d22\u8054\u5408\u6548\u5e94\u91cfg=0.60\u3002[S] \u533b\u5b66\u6559\u80b2\u4e2d\u95f4\u9694\u91cd\u590dSMD=0.78(Maye 2026,14\u9879\u7814\u7a76/21,415\u540d\u5b66\u4e60\u8005)\uff08Maye 2026, 14\u9879\u7814\u7a76/21,415\u540d\u5b66\u4e60\u8005\uff09\u3002",
    "*2025\u5e74\u5b9a\u91cf\u8bc1\u636e**: [S] Karpicke\u7efc\u5408\u56de\u987e(Purdue 2025):\u68c0\u7d22\u7ec3\u4e60\u6548\u5e94\u91cfg=0.50,\u4f18\u4e8e81%\u5bf9\u7167\u6761\u4ef6\u3002[S] \u95f4\u9694+\u68c0\u7d22\u8054\u5408\u6548\u5e94\u91cfg=0.60\u3002[S] \u533b\u5b66\u6559\u80b2\u4e2d\u95f4\u9694\u91cd\u590dSMD=0.78(Maye 2026,14\u9879\u7814\u7a76/21,415\u540d\u5b66\u4e60\u8005)\u3002 `\u6765\u6e90:: Rowland (2014) Psych Bull g=0.50; Maye et al. (2026) Clinical Teacher, 13 studies/21,415 learners, SMD=0.78 (95%CI 0.56-0.99). DOI: 10.1111/tct.70353`"
))

print(f"Prepared {len(patches)} patches")
print("This approach is too complex for inline unicode. Switching to file-based script.")
