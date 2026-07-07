# EVIDENCE_PATCH.md — CH02/CH05 证据补强（库外验证）

> 生成: 2026-06-20 | 基于 exa/Google Scholar 库外独立验证
> 关联: EVIDENCE_LEDGER.md → 4条待核声明交叉验证结果

---

## 验证结果汇总

| 声明 | 原状态 | 验证结果 | 处置 |
|------|--------|---------|------|
| S5: ACT Gloster g=0.56 (32 RCTs) | 待核 | ❌ 作者/年份/RCT数全错 | **降级 + 修正引用** |
| S7: Bishop 2025 正念 353研究 | 待核 | ❌ 论文不存在 | **降级为 [B] 或移除** |
| A1: Costin 2022 24国 7000+人 | 待核 | ❌ 数字张冠李戴 | **修正数字** |
| A5: Lampis 2025 分化依附 | 待核 | ✅ 论文存在 | **补全理论溯源** |

---

## 详细修正

### S5: ACT 元分析 → 降级修正

**原声明**: Gloster et al.(2023) 元分析(32项RCT): g=0.56

**库外验证**: 实际论文为 **A-Tjak, J.G.L. et al. (2015)**. `Psychotherapy and Psychosomatics`, 84(1), 30-36. DOI: 10.1159/000365764.
- RCT数: **39** (不是 32)
- 患者数: **1,821**
- 效应量: Hedges' g = **0.57** (不是 0.56；0.56 是 process measures，不是 depression/anxiety)
- Gloster et al. (2020) 是综述（回顾 20 篇已有元分析），不是原始元分析

**处置**:
```
[S] → 降级为 [A]，修正引用:
A-Tjak, J.G.L., Davis, M.L., Morina, N., Powers, M.B., Smits, J.A.J., & Emmelkamp, P.M.G. (2015).
"A meta-analysis of the efficacy of acceptance and commitment therapy for clinically relevant
mental and physical health problems." Psychotherapy and Psychosomatics, 84(1), 30–36.
39 RCTs, 1,821 patients, g=0.57 (overall). DOI: 10.1159/000365764.
```

**对 CH02 文本的影响**: 替换所有 "Gloster 2023 元分析" 为 "A-Tjak et al. (2015) 元分析"，修正数字。


### S7: Bishop 2025 正念 → 无法验证，降级

**原声明**: Bishop 2025 正念元分析 353研究/5,973人

**库外验证**: Google Scholar 搜索 "Bishop" + "mindfulness" + "meta-analysis" + "353 studies" + "2025" 零匹配。
- "353 studies" 在其他系统综述中出现，但**不是正念元分析**，而是搜索返回数
- "5,973 participants" 在正念元分析搜索中零匹配
- Bishop et al. (2018) 存在但关于 FKBP5 甲基化与 MBSR（PTSD 治疗），不是正念元分析
- **没有找到任何 Bishop 领衔的 2025 年正念元分析**

**处置**:
```
[S]/[A] → 降级为 [B]，标记为"无法独立验证"
如果 CH02 正文引用了此声明，改为引用可验证的正念元分析，例如:
Goldberg, S.B. et al. (2022). "Mindfulness-based interventions for psychiatric disorders:
A systematic review and meta-analysis." Clinical Psychology Review, 91, 102134.
44 篇元分析综述。
```


### A1: Costin 2022 生命意义 → 修正数字

**原声明**: Costin & Vignoles (2022) 24国, 7,000+ participants

**库外验证**: 实际 Costin & Vignoles (2022) 论文:
- Costin, V., & Vignoles, V.L. (2022). "What do people find most meaningful?" *Journal of Personality*, 90(4), 541–558.
- 样本: **~610 人（US MTurk 208 + UK 学生 106 + UK Prolific 296）**，仅 2 个国家

**24 国 7,000+ 人的真实来源**: Vignoles, V.L. et al. (2016). "Beyond the 'east-west' dichotomy." *J Exp Psychol Gen*, 145(8), 966–1000. 33 国 55 文化群体，7,000+ 人——**但这是关于文化自我模型的，不是生命意义，Costin 不是作者**。

**处置**:
```
[A] → 修正数字为 ~610 participants (US/UK), 2 countries
或改为引用 Vignoles et al. (2016) 的大样本数据（但需标注研究主题不同）
```


### A5: Lampis 2025 分化依附 → 确认，补全溯源

**原声明**: Lampis et al.(2025) 分化依附双维

**库外验证**: ✅ 论文存在
- Lampis, J., Busonera, A., & Tommasi, M. (2025). "Parental bonding and dyadic adjustment: the mediating role of the differentiation of self." *Contemporary Family Therapy*. Springer.

**理论溯源修正**: 
- **第一来源**: **Bowen, M. (1978)**. *Family Therapy in Clinical Practice*. Jason Aronson. — 自我分化理论创始人
- **第二来源**: Schnarch, D. (1997). *Passionate Marriage*. Norton. — 将分化应用于性亲密关系

Lampis 2025 是 Bowen 理论的当代实证验证。Scharch 是应用延伸，不是理论创始人。

**处置**:
```
[A] → 保持，补充理论溯源: "基于 Bowen (1978) 自我分化理论 → Schnarch (1997) 亲密关系应用 → Lampis et al. (2025) 当代验证"
```

---

## CH02 证据质量最终评分

| 声明 | 修正后等级 | 可靠性 |
|------|-----------|--------|
| S4: CBT Cuijpers 2025 | [S] 已核 ✅ | ★★★★★ 精确匹配 |
| S5: ACT A-Tjak 2015 | [A] 修正引用 | ★★★★ 数据正确但引用错 |
| S6: PERMA Kern | [A] 待核 | ★★★ 数据合理但无法精确验证 |
| S7: Bishop 正念 | [B] 降级 | ★★ 无法验证 |
| A1: Costin 生命意义 | [A] 修正数字 | ★★★ 数字张冠李戴 |
| A2: Harvard Grant Study | [A] 已核 ✅ | ★★★★★ 精确匹配 |

**CH02 证据改善**: 消除 1 处虚构引用 (S7)，修正 2 处引用错误 (S5, A1)，保留 2 处已核实 + 1 处合理待核。

---

## CH05 证据质量最终评分

| 声明 | 修正后等级 | 可靠性 |
|------|-----------|--------|
| A5: Lampis 2025 | [A] 确认 + 溯源 | ★★★★ 论文存在，补充理论根基 |
| B1: Bowen 自我分化 | [B] 教科书级 | ★★★★★ 经典不可置疑 |
| B2: Schnarch 亲密 | [B] 经典著作 | ★★★★★ 经典不可置疑 |
| B3: Buss 进化心理学 | [B] 教科书 | ★★★★★ 第7版可查 |

**CH05 证据改善**: 确认 A5 论文存在，补充从 Bowen→Schnarch→Lampis 的理论谱系，提升论证深度。

---

## 待执行动作

1. **[高优先]** 在 CH02 正文中修正 S5 引用: Gloster 2023 → A-Tjak et al. (2015)
2. **[高优先]** 移除或替换 CH02 中的 S7 Bishop 2025 正念声明
3. **[中优先]** 修正 CH02 中 A1 Costin 的样本数字
4. **[中优先]** 在 CH05 中补充 Bowen→Schnarch→Lampis 理论溯源路径
5. **[低优先]** 在 EVIDENCE_LEDGER.md 中更新上述 4 条声明的状态
