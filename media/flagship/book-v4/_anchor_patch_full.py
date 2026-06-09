# anchor_patcher_full.py
filepath = r"D:\KnowledgeBase\media\flagship\book-v4\FULL_MANUSCRIPT.md"
with open(filepath, "r", encoding="utf-8") as f:
    content = f.read()

reps = [
    # S1-S3: Karpicke g=0.50 / interval g=0.60 / Maye SMD=0.78
    (
        "**[S] Karpicke\u7efc\u5408\u56de\u987e(Purdue 2025):\u68c0\u7d22\u7ec3\u4e60\u6548\u5e94\u91cfg=0.50,\u4f18\u4e8e81%\u5bf9\u7167\u6761\u4ef6\uff0c\u4f18\u4e8e81%\u7684\u5bf9\u7167\u6761\u4ef6\u3002[S] \u95f4\u9694+\u68c0\u7d22\u8054\u5408\u6548\u5e94\u91cfg=0.60\u3002[S] \u533b\u5b66\u6559\u80b2\u4e2d\u95f4\u9694\u91cd\u590dSMD=0.78(Maye 2026,14\u9879\u7814\u7a76/21,415\u540d\u5b66\u4e60\u8005)",
        "**[S] Karpicke\u7efc\u5408\u56de\u987e(Purdue 2025):\u68c0\u7d22\u7ec3\u4e60\u6548\u5e94\u91cfg=0.50,\u4f18\u4e8e81%\u5bf9\u7167\u6761\u4ef6\u3002[S] \u95f4\u9694+\u68c0\u7d22\u8054\u5408\u6548\u5e94\u91cfg=0.60\u3002[S] \u533b\u5b66\u6559\u80b2\u4e2d\u95f4\u9694\u91cd\u590dSMD=0.78(Maye 2026,14\u9879\u7814\u7a76/21,415\u540d\u5b66\u4e60\u8005)\u3002 `\u6765\u6e90:: Rowland (2014) Psych Bull 159studies g=0.50; Maye et al. (2026) Clin Teach SMD=0.78 DOI:10.1111/tct.70353`"
    ),
    # S4: JAMA CBT 375 RCTs
    (
        "**[S] \u53cc\u76f8\u969c\u7887/\u7cbe\u795e\u5206\u88c2\u75c7 g=0.3-0.5(\u5c0f\u5230\u4e2d)\uff08\u5c0f\u5230\u4e2d\uff09\u3002** \u4f5c\u4e3a\u5bf9\u6bd4",
        "**[S] \u53cc\u76f8\u969c\u7887/\u7cbe\u795e\u5206\u88c2\u75c7 g=0.3-0.5(\u5c0f\u5230\u4e2d)\u3002** `\u6765\u6e90:: Cuijpers et al. (2025) JAMA Psychiatry 375RCTs/32,968pts PTSD SMD=1.27 dep=0.84` \u4f5c\u4e3a\u5bf9\u6bd4"
    ),
    # S5: Gloster ACT g=0.56
    (
        "**[S] Gloster et al.2023\u5143\u5206\u6790(32\u9879RCT):ACT\u5bf9\u6291\u90c1\u75c7g=0.56\uff08g=0.56\uff09\u3001\u7126\u8651\u75c7\uff08g=0.51\uff09\u3001\u6162\u6027\u75bc\u75db\uff08g=0.45\uff09\u5747\u6709\u6548\uff0c\u4e0eCBT\u6548\u679c\u65e0\u663e\u8457\u5dee\u5f02\u3002**",
        "**[S] Gloster et al.2023\u5143\u5206\u6790(32\u9879RCT):ACT\u5bf9\u6291\u90c1\u75c7g=0.56\u3001\u7126\u8651\u75c7g=0.51\u3001\u6162\u6027\u75bc\u75dbg=0.45\u5747\u6709\u6548\uff0c\u4e0eCBT\u65e0\u663e\u8457\u5dee\u5f02\u3002** `\u6765\u6e90:: Gloster et al(2020)J Context Behav Sci \u7efc\u8ff020\u7bc7\u5143\u5206\u6790/133\u7814\u7a76/12477\u4eba dep g=0.33-0.76 \u6ce8:2023\u5e7432RCT\u5f85\u786e\u8ba4`"
    ),
    # S6: Kern PERMA r=0.52
    (
        "**[S] Kern et al.2023\u5143\u5206\u6790(38\u9879\u7814\u7a76):PERMA\u4e0e\u751f\u6d3b\u6ee1\u610f\u5ea6r=0.52\u4e94\u7ef4\u5ea6\u4e0e\u751f\u6d3b\u6ee1\u610f\u5ea6(r=0.52)\u3001\u5fc3\u7406\u7e41\u8363(r=0.61)\u548c\u66f4\u4f4e\u7684\u6291\u90c1\u75c7\u72b6(r=-0.42)\u663e\u8457\u76f8\u5173\u3002**",
        "**[S] Kern et al.2023\u5143\u5206\u6790(38\u9879\u7814\u7a76):PERMA\u4e0e\u751f\u6d3b\u6ee1\u610f\u5ea6(r=0.52)\u3001\u5fc3\u7406\u7e41\u8363(r=0.61)\u3001\u66f4\u4f4e\u6291\u90c1\u75c7\u72b6(r=-0.42)\u663e\u8457\u76f8\u5173\u3002** `\u6765\u6e90:: Kern et al(2014)Psych; Butler&Kern(2016)PERMA-Profiler \u6ce8:38\u9879\u7814\u7a762023\u5f85\u786e\u8ba4`"
    ),
    # S7/S9: Bishop 2025 mindfulness
    (
        "[S] Bishop et al.(2025)353\u9879\u7814\u7a76, 5,973\u540d\u53c2\u4e0e\u8005, 2025\uff09\u63d0\u4f9b\u4e86\u7cbe\u786e\u6570\u636e\uff1a",
        "[S] Bishop et al.(2025)353\u9879\u7814\u7a76/5,973\u4eba) `\u6765\u6e90::\u5f85\u6838 \u641c\u7d22\u672a\u627e\u5230\u7cbe\u786e\u5339\u914d \u53c2\u8003:Goldberg et al(2022)44\u7bc7\u6b63\u5ff5\u5143\u5206\u6790\u7efc\u8ff0` \u63d0\u4f9b\u4e86\u7cbe\u786e\u6570\u636e\uff1a"
    ),
    # S8: Healthcare 2024 habit formation
    (
        "([S] Healthcare 2024\u5143\u5206\u6790(20\u9879\u7814\u7a76,2,601\u4eba):SMD=0.69\uff0c\u4e60\u60ef\u5f62\u6210\u7684\u4e2d\u4f4d\u65f6\u95f4\u7ea6\u4e3a59-66\u5929\uff0c\u4f46\u8303\u56f4\u6781\u5927\uff084-335\u5929\uff09\u3002",
        "([S] Healthcare 2024\u5143\u5206\u6790(20\u9879\u7814\u7a76/2,601\u4eba):SMD=0.69\u3002 `\u6765\u6e90::\u5f85\u6838 \u53c2\u7167:Lally et al(2009)Eur J Soc Psychol 96\u4eba/12\u5468 \u4e2d\u4f4d66\u5929(18-254)`"
    ),
    # A1: Frankl Costin & Vignoles
    (
        "**[A] Costin & Vignoles(2022):24\u56fd7,000+\u6837\u672c\u8bc1\u5b9e\uff1a\u751f\u547d\u610f\u4e49\u611f\u662f\u5fc3\u7406\u5065\u5eb7\u7684\u6700\u5f3a\u72ec\u7acb\u9884\u6d4b\u56e0\u5b50\u4e4b\u4e00\u2014\u2014\u5f3a\u4e8e\u793e\u4f1a\u7ecf\u6d4e\u5730\u4f4d\u3001\u793e\u4f1a\u652f\u6301\u7f51\u7edc\u548c\u8eab\u4f53\u5065\u5eb7\u3002**",
        "**[A] Costin & Vignoles(2022):24\u56fd7,000+\u6837\u672c\u8bc1\u5b9e\uff1a\u751f\u547d\u610f\u4e49\u611f\u662f\u5fc3\u7406\u5065\u5eb7\u6700\u5f3a\u72ec\u7acb\u9884\u6d4b\u56e0\u5b50\u4e4b\u4e00\u3002** `\u6765\u6e90:: Costin & Vignoles(2022)J Happiness Stud 24\u56fd/7000+\u4eba \u5f85\u786e\u8ba4DOI`"
    ),
    # A2: Harvard Grant Study
    (
        "**[A] Harvard Grant Study(\u8ffd\u8e2a724\u4eba80+\u5e74,Waldinger 2015)\u7684\u7ed3\u8bba\u6781\u5176\u6e05\u6670\uff1a**",
        "**[A] Harvard Grant Study(\u8ffd\u8e2a724\u4eba80+\u5e74,Waldinger 2015)\u7684\u7ed3\u8bba\u6781\u5176\u6e05\u6670\uff1a** `\u6765\u6e90:: Waldinger(2015)TED 29.7M views; Waldinger&Schulz(2023)The Good Life \u59cb\u4e8e1938 724\u7537\u6027+\u914d\u5076`"
    ),
    # A3: Lancet PURE grip strength
    (
        "\uff082015\u5e74[A] Lancet PURE(2015)14.2\u4e07\u4eba,17\u56fd, 17\u56fd\uff09\u3002",
        "\uff082015\u5e74[A] Lancet PURE(2015)14.2\u4e07\u4eba/17\u56fd\uff09\u3002 `\u6765\u6e90:: Leong et al(2015)Lancet 386:266-273 142861\u4eba/17\u56fd HRper5kg=1.16 DOI:10.1016/S0140-6736(14)62000-6`"
    ),
    # A4: TREAT RCT year fix
    (
        "2024\u5e74\u7684\u5927\u578bRCT\uff08[A] TREAT RCT(2024)105\u540d\u8d85\u91cd\u6210\u4eba\uff09",
        "2020\u5e74\u7684\u5927\u578bRCT\uff08[A] TREAT RCT(2020)105\u540d\u8d85\u91cd\u6210\u4eba\uff09 `\u6765\u6e90:: Lowe et al(2020)JAMA Intern Med 180:1491-9 TREvsCMT -0.26kg p=0.63 \u6ce8:v3\u8bef\u68072024\u5b9e\u4e3a2020`"
    ),
    # S: CBT 375 RCTs inside v3\u9510\u5ea6
    (
        "CBT\u662f\u5b9e\u8bc1\u6700\u5f3a\u7684\u5fc3\u7406\u6cbb\u7597([S]375 RCTs),\u4f46\u81ea\u52a9CBT\u6548\u679c\u663e\u8457\u4f4e\u4e8e\u6cbb\u7597\u5e08\u6307\u5bfc(\u6548\u5e94\u91cf\u51cf\u53bb0.15-0.25)\u3002",
        "CBT\u662f\u5b9e\u8bc1\u6700\u5f3a\u7684\u5fc3\u7406\u6cbb\u7597([S]375 RCTs),\u4f46\u81ea\u52a9CBT\u6548\u679c\u663e\u8457\u4f4e\u4e8e\u6cbb\u7597\u5e08\u6307\u5bfc(\u6548\u5e94\u91cf\u51cf\u53bb0.15-0.25)\u3002 `\u6765\u6e90:: Cuijpers et al(2025)JAMA Psychiatry 375RCTs/32968pts`"
    ),
]

applied = 0
for i, (old, new) in enumerate(reps):
    if old in content:
        content = content.replace(old, new)
        applied += 1
    else:
        key = old[:20]
        for ln, line in enumerate(content.split("\n"), 1):
            if key in line:
                print(f"PARTIAL at L{ln}: {line[:80]}")
                break
        else:
            print(f"MISS[{i}]: key={key}")

with open(filepath, "w", encoding="utf-8") as f:
    f.write(content)
print(f"Applied {applied}/{len(reps)}. Size={len(content)}")
