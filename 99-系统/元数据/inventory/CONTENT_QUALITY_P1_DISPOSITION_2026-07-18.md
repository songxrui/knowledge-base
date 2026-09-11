# 内容质量 P1 处置台账

> 日期：2026-07-19  
> 状态：active-remediation-ledger

## 结论

- 当前 P0：0。
- 当前 P1：1；该条为已接受但仍阻断发布的未核验产品假设。
- 其中 1 条是主动阻断的 199 产品假设；其余为待来源核验或身份修正的精确数字。
- 机器门禁通过不代表这些数字已被证实。

## 分类

| 分类 | 数量 | 默认处置 |
|---|---:|---|
| other-active | 0 | source-verify-or-qualify |
| reference-or-historical | 0 | archive-or-label-reference |
| business-finance | 0 | source-verify-or-rewrite-as-hypothesis |
| active-draft | 0 | fix-before-publication |
| content-system | 0 | trace-to-source-unit-or-remove |
| health-psychology | 0 | source-verify-or-remove |
| media-product | 0 | source-or-parameter-audit |
| blocked-product | 1 | accept-blocked-until-real-validation |

## 文件

- 明细：`CONTENT_QUALITY_P1_DISPOSITION_2026-07-18.csv`
- CSV SHA-256：`957CFF0D31CF3FB94A96AAE13ACC2FA6EAAF735ECCB65ABDC27EB7A55FC9B701`
- 来源快照：`CONTENT_QUALITY_GATE_LATEST.csv`
- 健康/心理批次：13 条无来源精确数字已删除或改为明确个人实验/待核验表述；映射：`CONTENT_QUALITY_HEALTH_P1_FIX_2026-07-19.csv`，SHA-256 `1983ED3E704822677B5B0BE7926FF798F39790858B951CA9E75A798B24ED54AB`。
- active-draft 批次：15 条未经本人确认的经历、目标或设计数字已删除或改为占位/待验证示例；其中 11 条证据仍在活动稿，4 条证据随故事稿归档且哈希保持一致。映射：`CONTENT_QUALITY_ACTIVE_DRAFT_P1_FIX_2026-07-19.csv`，SHA-256 `279A70F71EAFCE07297EC03EB696E3440DB5A38E1FEEF8039DE39FC2F24D48A0`。
- 媒体故事归档批次：3 份含未核验第一人称经历、身份或结果数字的媒体稿已完整归档，清单：UNVERIFIED_MEDIA_STORY_ARCHIVE_MANIFEST_2026-07-19.csv，SHA-256 EB73F6DD4EE954FCB71D7F4AF8336D124486BBD21BD39F6A4D179E74B48CED68。
- 产品假设与设计参数批次：6 条社群价格表述已标记 product-hypothesis，1 份视频设计稿已标记 production-design-spec / design-parameter；清单：PRODUCT_HYPOTHESIS_AND_DESIGN_P1_FIX_2026-07-19.csv，SHA-256 92FD27FC99E994B6A86F4DBA8E4525FB81CC617036D2C65BD8A25EA398B63946。
- 财富卡数字资格化批次：`C3-2_杠铃策略` 与 `C3-4_复利不是数学公式` 共 23 处比例、预算、时长和成长数字已改为解释示例或个人待验证参数；清单：`CONTENT_QUALITY_WEALTH_P1_FIX_2026-07-19.csv`，SHA-256 `465E0872D1FD6AB47E832A0CBEF2B5E091DA64F9C034356EE1A962DD69038CE0`。
- 交易与复利草稿批次：交易卡和公众号复利稿共 16 处金额、时间、次数、数学数字和未确认故事已改为个人安全阈值、解释示例或作者补入边界；清单：`CONTENT_QUALITY_TRADING_DRAFT_P1_FIX_2026-07-19.csv`，SHA-256 `68788AA68EC4F33EFDE4FC242541299000547EE8AFEE70EDBADDA78451A64DDB`。
- 形象卡批次：12 条身体数据、个人经历和比较倍数已改为作者补入占位、私有记录确认、非量化经验或编辑内部记录；清单：`CONTENT_QUALITY_APPEARANCE_P1_FIX_2026-07-19.csv`，SHA-256 `85C3313792A5185B9D913DA130123DFFB6D8BB8DEFBAD2DABB4DA7B0BCF04BC0`。`C6-2_P0单一主线` 9 条个人指标和算术示例已改为待记录的指标示例；清单：`CONTENT_QUALITY_P0_CARD_P1_FIX_2026-07-19.csv`，SHA-256 `25E53F94681C53B958DFD1720DCC610F3B27C587B0A11827346A949BB789E911`。
- 注意力与内容单元批次：`C4-4_注意力是第一资产`、`UNIT-032_8020法则`、`UNIT-042_四层答疑过滤` 共 12 处粉丝规模、比较倍数、经营结果和分配比例已改为结构示例、运行日志要求或作者补入边界；清单：`CONTENT_QUALITY_ATTENTION_UNITS_P1_FIX_2026-07-19.csv`，SHA-256 `088665F35DEE5B12CE48B4160CB2AB226122ED29273D7FCB0A870EBBE54DC47E`。

- 内容系统批次：案例标题、关系研究阈值、P0/MVS/MVP 参数共 5 条已改为准入规则、待原文核实或实验参数；清单：`CONTENT_QUALITY_CONTENT_SYSTEM_P1_FIX_2026-07-20.csv`，SHA-256 `D2A994A5DCF2B8F3AEF36FBFFF7F3235A88E6A890C2BD4A7BA5252A8323AFC8C`；基线方法为 `reverse-exact-patch`。
- 领域摘录批次：4 份原子领域笔记的 22 条外部书摘已标记 `来源摘录`，防止把书中数字或第一人称误当作者主张；清单：`CONTENT_QUALITY_DOMAIN_EXCERPTS_P1_FIX_2026-07-20.csv`，SHA-256 `0BF1622AC6C4C17C353ECFC059A02C767EACCAC4BBE4D4FEC349567B967E07B7`。
## 关闭规则
- 杠杆框架批次：`C7-3_反脆弱`、`T4-01_8020法则`、`UNIT-009_杠铃策略` 共 12 处比例和收益表述已改为框架/排程示例；清单：`CONTENT_QUALITY_LEVERAGE_P1_FIX_2026-07-20.csv`，SHA-256 `14E31DBC1F17A911D24C8D65194023B9F1C7E328495475EB3F55E20C125CC3CE`。
- 个人杠杆批次：`C5-2_形象管理`、`C4-5_发布不是终点`、`C2-1_先避毁灭再求收益` 共 27 处个人画像、增长门槛、来源边界、财务风险和交易参数已改为作者确认、作者推断或实验参数；清单：`CONTENT_QUALITY_PERSONAL_LEVERAGE_P1_FIX_2026-07-20.csv`，SHA-256 `A019ED2E07BED0D5AC737A2E0AB847E2470F43F262B01AB3A674931423723F6F`。

1. `fixed`：删除伪精确数字、补齐同段可定位来源，或改为明确示例/实验参数。
2. `accepted-blocked`：文档保持 blocked 且不进入发布、旗舰或事实台账。
3. `archived`：有哈希清单和映射后移入 `90-归档/`。
4. 每次关闭后重跑门禁并更新本 CSV；不得只改状态字段。














































