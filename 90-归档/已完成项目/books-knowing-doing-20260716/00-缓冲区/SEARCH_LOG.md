# SEARCH LOG：检索与访问记录

> 记录原则：搜索结果是导航，不是证据。只有实际打开的原论文、作者稿、出版社章节、机构报告或明确标注的摘要，才进入 `SOURCE_LEDGER.md`。

## 2026-07-12：本地素材检索

### 范围

项目约定的 `structured-content/02-内容单元库/` 在当前工作区不存在，因此按项目说明回退到现有 `03-资源/素材库/`。

### 实际读取

| 文件 | 访问范围 | 可复用内容 | 需警惕 |
| --- | --- | --- | --- |
| `知行合一.md` | 相关章节与信源索引 | 环境、动作定义、反馈的初始框架 | 三重脑、神经元比例、运行速度等表述未经原文支持，不复用 |
| `deep-research-知行合一-v2.md` | 执行意向、必要难度、知行鸿沟与信源部分 | `d=0.65` 线索；“谈论替代行动”线索 | “越轻松长期记忆越差”是过度概括；组织案例不能直接外推个人 |
| `deep-research-知行合一-v3.md` | 全文 | 已有的因果降级和边界写法；个人实验框架 | 仍需回到原论文核验样本与效应 |
| `deep-research-知行合一-v3-10场景.md` | 买书不读场景及共同模式 | 合成人物的欲望与自我辩护线索 | 精确藏书数和30天结果是模拟，不得伪装成真实案例；多巴胺解释过强 |
| `deep-research-知行合一-v4-系统构建.md` | 全文 | 环境、脚本、记录、恢复、更新五层 | 五层是作者整合，不是单一研究验证模型 |

### 本地检索结论

本地材料足以提供问题语言和实践框架，但不足以回答书籍篇幅、叙事价值、媒介差异、知识压缩或AI学习。旧稿中的若干神经科学说法将作为反面样本，不进入终稿事实层。

## 2026-07-12：工具可用性

| 工具 | 结果 | 处理 |
| --- | --- | --- |
| Firecrawl Search | 无密钥免费额度达到速率上限 | 不降低来源要求，改用 Exa 定位原文 |
| Exa Search / Fetch | 初期可定位，后期多次超时 | 只把已成功结果用于定位；改由 Crossref、PubMed/PMC、NCBI E-utilities、出版商和作者稿读取原文 |
| Firecrawl Research Paper Reader | 工具存在但受密钥/额度限制 | 未把不可访问结果计入全文；不依据 paper ID 摘要写结论 |
| 本地 Git | 仓库与工作目录匹配 | 所有成果限定在本项目目录 |

## 2026-07-12：学习科学、元认知与迁移

### 查询组 L1：重读、主动提取与测试效应

查询：`retrieval practice rereading delayed retention original experiment Roediger Karpicke 2006`；`testing effect meta-analysis feedback delayed retention`；`retrieval practice concept mapping science text original study`。

- Roediger & Karpicke (2006) 全文用于即时与延迟表现逆转，保留5分钟优势和一周结果，不把短说明文外推成整书行为研究。
- Rowland (2014) 与 Pan & Rickard (2018) 用于总体测试效应和迁移边界；综述承担平均效应，不替代原实验的样本与任务。
- Karpicke & Blunt (2011) 比较提取练习与概念图，但只用于“生成过程可能重要”，没有写成“概念图无效”。

### 查询组 L2：流畅性、元认知与交错

查询：`Koriat Bjork illusions competence asymmetric associations full text`；`interleaved practice blocked practice induction Kornell Bjork original experiment`；`spacing interleaving boundary conditions meta-analysis`。

- Koriat & Bjork (2005) 原文明确否定普遍过度自信，因此终稿把错觉限定为“学习时答案可见、测试时需生成”等条件。
- Kornell & Bjork (2008) 既有交错优于集中，也有填词任务中集中更好的反例；用于拒绝“交错永远更好”。
- Cepeda 等 (2006) 说明最佳间隔随保持期变化，不能替“两天+一周”提供固定科学处方；终稿把该日程标为可执行起点。

### 查询组 L3：语境、例题、叙事与统计证据

查询：`contextual prerequisites understanding recall Bransford Johnson 1972`；`worked examples problem solving algebra Sweller Cooper 1985`；`narrative transportation persuasion Green Brock 2000`；`statistical versus narrative evidence meta-analysis beliefs intention behavior`。

- Bransford & Johnson 使用刻意含混短文，只能说明编码前语境有时参与理解，不能证明长篇天然更深。
- Sweller & Cooper 的完整例题优势限于初学代数及结构相近问题，不为所有案例背书。
- Green & Brock 支持即时故事一致信念；Zebregs 等的健康传播元分析中统计证据在信念上有小优势，叙事对行为意图仅边缘显著且未测实际行为。二者成对纳入，排除“故事普遍胜过数据”的版本。

### 原文访问路线

优先顺序为期刊HTML/XML、作者稿或可核PDF；DOI和Crossref只核元数据。扫描PDF由本地 Poppler 转文本并对关键页做视觉复核。搜索页标题与摘要不承担效应数字。

## 2026-07-12：行为科学、习惯与书目疗法

### 查询组 B1：意图—行为差距与实施意图

查询：`intention behavior gap meta-analysis experimental change Webb Sheeran 2006`；`implementation intentions meta-analysis 94 tests d .65`；`implementation intentions physical activity systematic review meta-analysis reinforcement`；`vaccination date time prompt randomized field experiment`。

- Webb & Sheeran (2006) 只纳入确实改变意图的实验，用于比较意图与行为效应，不转述成“意图没用”。
- Gollwitzer & Sheeran (2006) 的 `d=.65` 不转成“成功率提高65%”；Silva 等 (2018) 的成人体力活动 `SMD=.15, 95% CI [-.01,.31]` 作为领域反证。
- Milkman 等 (2011) 现场试验保留日期单独不显著、日期+时间增加4.2个百分点的差别，并限制在免费、单次疫苗行为。

### 查询组 B2：自动化、监测与反馈

查询：`habit formation real world Lally 66 days 18 254 original study`；`goal progress monitoring meta-analysis 138 studies Harkin`；`behavior feedback social support goal conflict review`。

- Lally 等 (2010) 核对96名招募、39名良好曲线拟合和18—254天范围；排除“人人66天形成习惯”。
- Harkin 等 (2016) 研究的是促进进度监测，不是一般“反馈”。引用手术已把终稿标签改正。
- 本轮没有找到能把社会支持、摩擦、目标冲突和阅读统一放进同一因果试验的来源；这些只进入瓶颈模型，不报告统一效应量。

### 查询组 B3：失眠、抑郁与自助书边界

查询：`bibliotherapy insomnia CBT self-help book therapist guidance randomized trial Jernelov`；`guided self-help CBT depression primary care randomized trial Williams`；`self-guided treatment depressive symptoms no therapist contact meta-analysis book internet`；`positive self-statements low self-esteem experiment`。

- Jernelöv 等 (2012) 三臂试验是“书可参与下游改变”的关键反证；同时保留开放标签、自报、教育程度和指导增益并非所有结局稳定的限制。
- Williams 等 (2013) 核对四个月结果与十二个月正文 `p=.14`；摘要把十二个月写成显著，终稿以正文为准。
- Cuijpers 等 (2011) 七项完全无接触干预只有一项书本且效果约零，其余主要为互联网；排除“纯读书已被证明治疗抑郁”。
- Wood 等 (2009) 的积极自我陈述对低自尊参与者可能不利，作为“同一建议依读者状态不同”的反常证据，不外推为全部自助书效果。

### 临床安全处理

书目疗法论文只支持筛选人群、结构化材料和研究时点内的平均结果。自伤风险、严重功能损害、共病、禁忌和专业转介边界不由本研究协议替代。终稿不用临床研究给一般励志书背书。

## 2026-07-12：出版、长篇与书籍来源

### 查询组 A：出版经济与篇幅

查询：`academic research trade nonfiction book length publishing economics commercial incentives self-help publishing industry page count`

初筛结果：

- Franssen & Velthuis (2014)，荷兰小说市场 1980—2009，访谈加约8万本书的价格数据。摘要与正文片段显示页数、装帧和尺寸参与定价，编辑会在损益表中调整页数等物质属性。它能支持“页数与价格/市场惯例共同形成”，不能支持“出版商普遍要求作者注水”。
- Markou (2025) 博士论文，英国贸易非虚构 2001—2015 的 Nielsen BookScan 数据与访谈。可用于前台书/后台书、货架寿命和零售注意竞争，不直接回答单本书为何写长。
- Thompson (2010/2012)《文化商人》，Google Books 有限预览、作者公开讲座与出版社页可访问。可用于出版场域、头部书和营销窗口，不能把“Big Books”误解为物理篇幅很大。

检索判断：目前没有找到“商业畅销非虚构的长度主要由填充造成”的直接研究。该说法暂不成立，保留为待核实问题。

### 查询组 B：文学为什么不应只按行动验收

查询：`Rita Felski Uses of Literature chapter Recognition PDF full text author manuscript`

初筛结果：

- Felski (2008)《文学之用》官方 DOI、目录与章节首页可访问；提出识别、沉醉、知识、震撼四种参与方式。它是文学理论论证，不是行为效果实验。
- Blum (2020)《自助冲动》出版社书介与目录可访问；论证现代文学与商业建议并非绝对对立。当前只读出版社材料，不把书介写成作者完整论证。

### 查询组 C：一本书改变人的可核验个案

查询：`Gandhi autobiography The Magic Spell of a Book Unto This Last full text chapter`

已读取 Gandhi 原著在线章节 `The Magic Spell of a Book`。他写到在约翰内斯堡到德班的火车上读 Ruskin 的 *Unto This Last*，一夜未眠，并决定依书中理想改变生活；他随后将其译成古吉拉特语，书名为 *Sarvodaya*。这是自述证据，能证明 Gandhi 如何解释自己的转变，不能单独证明书籍是后续生活变化的唯一原因。

Ruskin 的 *Unto This Last* 已定位到 Project Gutenberg eBook #36541；此前一次抓取误用了 #25095，返回无关小说，已排除且不计入来源。

### 查询组 D：自助书与知识消费的文化批评

查询：`Micki McGee Self-Help Inc Makeover Culture American Life Google Books preview`

已读取作者网站提供的导论节选。McGee 将自助消费放在就业不稳定、个人责任化和持续自我改造的社会背景中。导论中的历史销售数字来自更早行业来源，若终稿使用，需要分别核验；文化解释不能证明某个读者购买书籍就是逃避行动。

### 查询组 E：知行鸿沟与深度阅读书籍

查询：`The Knowing-Doing Gap chapter preview`；`Reader Come Home authorized excerpt`

- Pfeffer & Sutton (2000) 第一章只访问到 O'Reilly 有限预览，研究对象是组织。可用于提出“聪明谈话替代执行”的组织机制，不直接作为个人阅读行为的实证证据。
- Wolf (2018) 有作者页、授权书摘和由书改编的 SAGE 文章可访问。个人重读实验属于作者自述；有关纸屏差异的群体判断仍需独立元分析支持。

## 并行检索分工

| 研究线 | 范围 | 验收 |
| --- | --- | --- |
| 学习科学与叙事 | 提取、间隔、交错、元认知、迁移、案例与故事 | 至少8篇一手、3篇综述，含反常证据 |
| 行为与自助 | 意图差距、实施意图、习惯、反馈、书目疗法 | 至少7篇一手、4篇综述，严禁临床外推 |
| 媒介、数字与AI | 纸屏、深度阅读、认知卸载、AI学习、出版经济 | 至少6篇一手、3篇综述、2个最新AI来源 |

子任务返回后由主研究者再次核对 DOI、访问层级、样本、效应与限制；不会直接复制子任务结论。

## 2026-07-12：媒介、数字信息行为与AI辅助阅读

### 查询组 F：纸屏理解与元认知校准

查询：`screen paper metacognitive calibration reading comprehension experiment`；`long text Kindle print temporal comprehension`；`paper screen reading meta-analysis prediction interval`。

- Ackerman & Goldsmith (2011) 全文显示，固定时间下纸屏成绩近乎相同，但屏幕组判断更乐观；自定时间时屏幕组表现较差。它更接近自我调节证据，不是“屏幕伤害编码”的普遍证明。
- Margolin 等 (2013) 在纸、电脑和Kindle间未见总体理解差异，作为零效应反证保留。
- Mangen 等 (2019) 使用约10,800词故事，差异主要落在时序与情节排序，而非总体事实理解。电子版隐藏页码和进度条，限制外推。
- Delgado 等 (2018) 元分析给出纸张小均值优势，但纯叙事、自定步调等子条件效应很小或跨零；终稿不得写“纸必然更深”。

### 查询组 G：搜索、外部记忆与数字保存

查询：`Google effects memory transactive memory original study`；`internet search illusion internal knowledge experiment`；`digital hoarding motivation measurement study`。

- Sparrow 等 (2011) 能支持“预期可访问时，记忆偏向入口而非内容”，不能支持互联网造成整体失忆。
- Fisher 等 (2015) 的关键结局是无关领域的解释能力自评，不是客观知识或行为。终稿把它写成与AI相邻的机制证据，不冒充生成式AI研究。
- Sweeten 等 (2018) 和 Neave 等 (2019) 研究数字囤积动机及量表结构，但不能把普通收藏、稍后阅读或买书直接诊断为囤积，更不能证明它替代行动。

### 查询组 H：LLM、笔记与延迟理解

查询：`large language model note taking reading comprehension memory randomized experiment secondary school 2025`。

Kreijkes 等（2025在线、2026卷期）预注册实验比较 LLM、手写笔记与 LLM+笔记。只用LLM相对手写笔记在三天后的保持和理解较弱，但研究没有纯阅读组、只用GPT-3.5，且两套随机比较不能跨组直接互比。它支持“便利感和延迟表现可分离”，不支持“LLM必然损害阅读”。

### 元数据与访问复核

主研究者经 Crossref API 复核上述8项 DOI、标题与卷期年份；正文访问范围仍按账本中的 `M/T-全文` 标注。Firecrawl 因缺少API密钥不可用，Exa抓取阶段性超时；因此优先使用出版商全文、PMC/XML、作者稿、Crossref和机构原始页面。搜索结果摘要只用于定位，未作为结论来源。
