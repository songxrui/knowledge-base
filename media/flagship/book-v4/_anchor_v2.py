filepath = r"D:\KnowledgeBase\media\flagship\book-v4\FULL_MANUSCRIPT.md"
with open(filepath, "r", encoding="utf-8") as f:
    lines = f.readlines()

# Anchor text to append after each marker
# Key: unique keyword to detect the marker, Value: anchor text
anchors = {
    "Maye 2026,14": " `来源:: Rowland (2014) Psych Bull g=0.50 159studies; Maye et al. (2026) Clin Teach SMD=0.78 DOI:10.1111/tct.70353`",
    "\u53cc\u76f8\u969c\u7887/\u7cbe\u795e\u5206\u88c2\u75c7 g=0.3-0.5": " `来源:: Cuijpers et al. (2025) JAMA Psychiatry 375RCTs/32968pts PTSD SMD=1.27 dep=0.84`",
    "Gloster et al.2023\u5143\u5206\u6790(32\u9879RCT)": " `来源:: Gloster et al.(2020) J Context Behav Sci 20\u7bc7\u5143\u5206\u6790/133\u7814\u7a76/12477\u4eba dep g=0.33-0.76 \u6ce8:2023\u5e7432RCT\u5f85\u786e\u8ba4`",
    "Kern et al.2023\u5143\u5206\u6790(38\u9879\u7814\u7a76)": " `来源:: Kern et al.(2014) Psych; Butler&Kern(2016) PERMA-Profiler \u6ce8:38\u9879\u7814\u7a762023\u5f85\u786e\u8ba4`",
    "Bishop et al.(2025)353": " `来源::\u5f85\u6838 \u53c2\u8003:Goldberg et al.(2022)44\u7bc7\u6b63\u5ff5\u5143\u5206\u6790\u7efc\u8ff0 \u964d\u7ea7\u4e3a[B]`",
    "Healthcare 2024\u5143\u5206\u6790(20\u9879\u7814\u7a76)": " `来源::\u5f85\u6838 \u53c2\u7167:Lally et al.(2009)Eur J Soc Psychol 96\u4eba median 66days(18-254)`",
    "Costin & Vignoles(2022):24\u56fd": " `来源:: Costin & Vignoles(2022) J Happiness Stud 24\u56fd/7000+\u4eba \u5f85\u786e\u8ba4DOI`",
    "Harvard Grant Study(\u8ffd\u8e2a724\u4eba80+\u5e74,Waldinger 2015)": " `来源:: Waldinger(2015) TED 29.7M views; Waldinger&Schulz(2023) The Good Life \u59cb\u4e8e1938`",
    "Lancet PURE(2015)14.2\u4e07\u4eba,17\u56fd": " `来源:: Leong et al.(2015) Lancet 386:266-273 142861\u4eba/17\u56fd HRper5kg=1.16 DOI:10.1016/S0140-6736(14)62000-6`",
    "TREAT RCT(2024)105": " `来源:: Lowe et al.(2020) JAMA Intern Med 180:1491-9 TREvsCMT -0.26kg p=0.63 \u6ce8:v3\u8bef\u68072024\u5b9e\u4e3a2020`",
    "([S]375 RCTs),\u4f46\u81ea\u52a9CBT": " `来源:: Cuijpers et al.(2025) JAMA Psychiatry 375RCTs/32968pts`",
    "Lampis et al.(2025)\u5206\u5316\u4f9d\u9644": " `来源::\u5f85\u6838 \u964d\u7ea7\u4e3a[B] \u57fa\u4e8eBowen(1978)\u81ea\u6211\u5206\u5316\u7406\u8bba&Schnarch(1997)\u4eb2\u5bc6\u5173\u7cfb\u7ecf\u5178`",
    "Philip [A] Tetlock(2015)Superforecasting": " `来源:: Tetlock&Gardner(2015) Superforecasting ISBN 978-0804136693 IARPA ACE 20000+ forecasters`",
}

modified = []
new_lines = []
for i, line in enumerate(lines):
    new_lines.append(line)
    for keyword, anchor in anchors.items():
        if keyword in line and keyword not in modified:
            # Append anchor to the end of this line (before newline)
            new_lines[-1] = line.rstrip('\n\r') + anchor + '\n'
            modified.append(keyword)
            print(f"L{i+1}: anchored [{keyword[:40]}]")
            break

with open(filepath, "w", encoding="utf-8") as f:
    f.writelines(new_lines)

print(f"\nAnchored {len(modified)}/{len(anchors)} markers")