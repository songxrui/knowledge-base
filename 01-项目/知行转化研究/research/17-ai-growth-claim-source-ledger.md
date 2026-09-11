# AI个体增长章：逐条主张与来源台账

> 版本：2026-07-21
> 原稿：`03-资源/素材库/人生操作系统-v3-09-AI个体增长.md`
> 目的：把创作者案例、模型能力、Agent编排、内容资产、OPC经济学和个人实验分层；原稿保持不变，派生稿只使用已通过边界审查的主张。
> 证据时间边界：截至2026-07-21。网页能力描述不自动等于当前可用性、生产率、收入或团队替代。
> 证据等级：A=官方文档/官方API/原作者材料；B=同行评议研究或正式评测；C=公开平台机制或自述；D=作者综合/实验参数。D类不是外部事实证明。

## 1. 结论

- Pieter Levels、Sahil Lavingia、Dan Koe的具体收入、利润、员工、融资、粉丝和订阅数字，本轮没有取得可追溯的一手财务或平台数据，不进入派生稿正文。
- OpenAI o3和o1可按官方文档描述为面向特定复杂推理任务的模型；这不等于自主Agent、团队替代或稳定商业结果。
- Cursor和Replit Agent可支持特定的代码/应用开发工作流；官方材料同时要求按权限配置自主程度、项目上下文和部署边界。
- `Fable 5`无法定位为可核验的AI模型、产品或能力等级，阻断。
- 十倍生产率、五人团队替代、五千美元年成本、百分之八十职能覆盖、四十五分钟对三到四小时、内容`c×n×h`公式和“陌生人付费即PMF”均不能作为已证事实。
- 派生稿保留OPC作为作者工作框架，重写为“目标—任务—工具—验收—人工批准—结果复盘”的个人实验系统。

## 2. 来源登记

### `AIG-S01` OpenAI o3模型文档

- URL：[o3模型文档](https://developers.openai.com/api/docs/models/o3)
- 身份：OpenAI官方模型文档；A级，但属于产品能力说明，不是独立评测。
- 支持：o3面向数学、科学、编码、视觉推理和多步骤问题等任务的模型定位。
- 不支持：任意复杂工作自主完成、长期记忆、自动调用子模型、团队等价、收入或生产率倍数。
- 使用：C08。

### `AIG-S02` OpenAI reasoning best practices

- URL：[Reasoning best practices—Visual reasoning](https://developers.openai.com/api/docs/guides/reasoning-best-practices)
- 身份：OpenAI官方推理指南；A级。
- 支持：o1类推理模型在复杂视觉数据和跨图像推理任务中的使用边界。
- 不支持：模型具备完整Agent循环、工具权限、跨会话记忆或自动纠错闭环。
- 使用：C09、C16。

### `AIG-S03` Cursor Agent overview

- URL：[Cursor Agent overview](https://cursor.com/docs/agent/overview)
- 身份：Cursor官方文档；A级。
- 支持：Agent式代码库理解、规划、修改和构建工作流。
- 不支持：一个人等于五人团队、固定效率倍数、无审查生产交付。
- 使用：C11、C31。

### `AIG-S04` Cursor GitHub Actions autonomy levels

- URL：[Cursor GitHub Actions—Autonomy levels](https://cursor.com/docs/cli/github-actions)
- 身份：Cursor官方文档；A级。
- 支持：full autonomy与restricted autonomy的配置差异；生产环境需要权限控制和审计意识。
- 不支持：无条件安全自治、自动承担法律/商业责任、跨平台通用Agent能力。
- 使用：C12、C45。

### `AIG-S05` Replit Agent overview

- URL：[Replit Agent overview](https://docs.replit.com/features/agent/overview)
- 身份：Replit官方文档；A级。
- 支持：在浏览器式开发环境中辅助构建应用的Agent工作流。
- 不支持：过去五人团队的全部工作、稳定生产质量或收入结果。
- 使用：C13、C15。

### `AIG-S06` Replit项目上下文与部署配置

- URL：[replit.md](https://docs.replit.com/updates/replit-md)；[Deployment configuration](https://docs.replit.com/core-concepts/project-editor/app-setup/configuration)
- 身份：Replit官方文档；A级。
- 支持：通过项目文件提供技术栈、编码风格、架构和沟通偏好；部署需要具体配置。
- 不支持：一句模糊指令即可得到稳定可交付产品、无需人工验收或无需权限管理。
- 使用：C14、C45。

### `AIG-S07` Gumroad公共商品页API

- URL：[Gumroad API](https://gumroad.com/api)
- 身份：Gumroad官方API文档；A级平台机制来源。
- 支持：公开商品页可展示价格、描述、卖家公开资料、订阅属性、评价等字段；部分销售数需卖家主动公开。
- 不支持：Gumroad公司收入、员工、融资、创始人收入、总订阅数或某个案例的盈利结论。
- 使用：C07、C50。

### `AIG-S08` Fable开源项目检索结果

- URL：[Fable compiler](https://github.com/fable-compiler/Fable)
- 身份：与AI Agent无关的公开项目；C级负证据。
- 支持：说明不能把搜索到的同名Fable项目当作“Fable 5 AI Agent”的来源。
- 不支持：Fable 5的模型身份、能力等级、发布者、评测任务或商业结论。
- 使用：C10。

### `AIG-S09` NIST AI Risk Management Framework

- URL：[NIST AI RMF](https://www.nist.gov/itl/ai-risk-management-framework)
- 身份：美国国家标准与技术研究院治理框架；A级规范来源。
- 支持：AI系统需要按风险、治理、测量和管理来设计；可作为人工批准、记录和审计的治理参考。
- 不支持：证明任何具体工具安全、准确、适合替代员工或必然提高收入。
- 使用：C45、C46。

## 3. Claim-source ledger

| Claim ID | 原稿主张/待处理主张 | 身份 | 决定 | 来源 | 支持边界与不支持边界 | 派生稿 |
|---|---|---|---|---|---|---|
| AIG-C01 | Pieter Levels从阿姆斯特丹搬到东南亚并在阳台创业 | historical-description | block | 无可核验一手出处 | 叙述未绑定原始访谈、日期和原文 | 不使用 |
| AIG-C02 | Nomad List十二个月后月收入四万美元 | inventory-snapshot | block | 无 | 无原始财务记录、统计口径和日期 | 不使用 |
| AIG-C03 | Remote OK月收入再加十万、年收入超过三百万 | inventory-snapshot | block | 无 | 第三方估算不能当审计数据 | 不使用 |
| AIG-C04 | Levels没有团队、融资、办公室并拒绝所有投资 | historical-description | block | 无 | 不能由个人品牌或网站外观推导法律与融资事实 | 不使用 |
| AIG-C05 | Sahil Lavingia创办Gumroad并在2015年裁员 | historical-description | block | 无 | 本轮未取得人物履历一手来源 | 不使用 |
| AIG-C06 | Gumroad利润翻三倍、2023年超过两千万美元 | inventory-snapshot | block | 无 | 公司财务未核验 | 不使用 |
| AIG-C07 | Gumroad公共商品页与订阅字段存在 | platform-mechanism | qualify | S07 | 可写平台机制，不推出公司或个人财务 | 使用改写 |
| AIG-C08 | o3适合数学、科学、编码、视觉和多步骤推理 | official-framework | qualify | S01 | 绑定官方任务描述，不外推自主商业结果 | 使用 |
| AIG-C09 | o1可处理复杂视觉数据与跨图像推理 | official-framework | qualify | S02 | 是特定任务能力，不等于Agent循环 | 使用 |
| AIG-C10 | Fable 5是公开的Agent能力等级 | capability-claim | block | S08 | 无模型卡、产品文档、论文、基准和发布者 | 不使用 |
| AIG-C11 | Cursor提供Agent式代码库规划和修改 | official-framework | qualify | S03 | 仅写代码工作流能力，不写团队等价 | 使用 |
| AIG-C12 | Cursor可以完全自主执行外部操作 | capability-claim | reframe | S04 | 自主程度取决于权限；生产环境需受限和审计 | 使用改写 |
| AIG-C13 | Replit Agent可辅助构建应用 | official-framework | qualify | S05 | 绑定应用开发任务，不写稳定交付保证 | 使用 |
| AIG-C14 | replit.md可提供项目上下文和偏好 | official-framework | keep | S06 | 上下文文件改善约束传递，不替代验收 | 使用 |
| AIG-C15 | Cursor/Replit让一人完成过去五人团队工作 | causal-claim | block | S03/S05 | 无岗位清单、质量阈值、时间窗和比较实验 | 不使用 |
| AIG-C16 | Agent自动拆解、路由子模型、自纠错、记忆和升级 | capability-claim | block | S01/S02 | 这是多个系统能力的复合句，未被同一来源证明 | 不使用 |
| AIG-C17 | 精确系统指令决定Agent质量 | author-method | qualify | 无 | 可作为工作假设，必须用任务验收验证 | 使用改写 |
| AIG-C18 | Agent可以替代设计、分析、客服等职能 | capability-claim | block | 无 | 职能不是单一任务，缺少质量和责任边界 | 不使用 |
| AIG-C19 | AI让内容生产速度提高十倍 | productivity-claim | block | 无 | 没有模型、人员、任务、基线、质量和返工数据 | 不使用 |
| AIG-C20 | AI提高下限但不改变上限 | editorial-inference | parameterize | 无 | 作者判断，需通过具体内容评审和数据验证 | 使用改写 |
| AIG-C21 | AI生产不出让读者停三秒的内容 | capability-claim | block | 无 | 不可操作、不可证伪、缺少读者测量 | 不使用 |
| AIG-C22 | 内容在网上永久存在并持续带来流量 | causal-claim | block | 无 | 平台、链接、曝光和内容寿命均未定义 | 不使用 |
| AIG-C23 | 头部创作者收入幂律分布且内容产生睡后流量 | market-claim | block | 无 | 无样本、平台、时间窗和收入数据 | 不使用 |
| AIG-C24 | 每篇高质量内容都是信任存款并转为购买 | causal-claim | block | 无 | 没有归因设计，不能写成转化因果 | 不使用 |
| AIG-C25 | AI与内容会形成自动飞轮 | author-framework | parameterize | 无 | 可作为待测经营模型，不写成启动后必然加速 | 使用改写 |
| AIG-C26 | Cursor、Replit、Claude、Midjourney等构成OPC标准工具链 | author-method | parameterize | S03/S05 | 只可写为示例组合，工具和价格随日期变化 | 使用改写 |
| AIG-C27 | OPC年工具成本低于五千美元 | cost-claim | block | 无 | 套餐、调用量、税费、超额和人工成本未核验 | 不使用 |
| AIG-C28 | OPC覆盖百分之八十职能、剩余百分之二十由人完成 | productivity-claim | block | 无 | 没有岗位清单、成功率和人工返工定义 | 不使用 |
| AIG-C29 | 五分钟语音可完成一篇文章的素材采集 | productivity-claim | parameterize | 无 | 只能作为个人首轮输入参数 | 使用改写 |
| AIG-C30 | 两千五百字文章需要三个结构、四个Agent | workflow-parameter | parameterize | 无 | 是作者流程参数，不是普遍最佳实践 | 使用改写 |
| AIG-C31 | 人负责故事、洞察和语气，Agent负责框架与整理 | author-method | keep | S03/S06 | 作为人机分工原则；每个任务仍需验收 | 使用 |
| AIG-C32 | 一个人实际投入四十五分钟，原来需要三到四小时 | productivity-claim | block | 无 | 单人自报、任务不明、没有基线和质量对照 | 不使用精确数字 |
| AIG-C33 | 工具过载是个人AI系统常见失败 | author-method | parameterize | 无 | 可作为风险假设，需记录切换成本 | 使用 |
| AIG-C34 | 主动使用Agent不超过五个 | workflow-parameter | parameterize | 无 | 首轮个人限制，不是普遍上限 | 使用改写 |
| AIG-C35 | 内容工厂会在三个月内造成读者流失 | causal-claim | block | 无 | 无样本、留存定义和对照组 | 不使用 |
| AIG-C36 | 每篇内容必须有真实故事或只有你能写的部分 | author-method | parameterize | 无 | 可作为内容质量检查项，不是流量保证 | 使用改写 |
| AIG-C37 | 产品未验证前不要平台化 | author-method | qualify | 无 | 作为资源聚焦规则，不写成收入阈值定律 | 使用 |
| AIG-C38 | 陌生人付费就等于PMF | market-claim | block | 无 | 付费是信号，不是留存、复购和规模化充分条件 | 不使用 |
| AIG-C39 | 两到三个OPC朋友每月交流可避免崩溃 | psychological-claim | block | 无 | 未测量心理结果，不替代专业支持 | 不使用 |
| AIG-C40 | 每月一次同行复盘是可选协作参数 | author-method | parameterize | 无 | 作为低风险协作实验，不写成心理治疗 | 使用改写 |
| AIG-C41 | 信任资产等于`c×n×h` | mathematical-claim | block | 无 | 变量无统一定义，未有可复现验证 | 不使用 |
| AIG-C42 | n、h、c不独立且长期内容更有价值 | author-model | parameterize | 无 | 可作为内容实验假设，需按队列和时间窗验证 | 使用改写 |
| AIG-C43 | Levels的产品证明远程工作需求长期有效 | causal-claim | block | 无 | 案例未核验且单个产品不能证明市场长期趋势 | 不使用 |
| AIG-C44 | 2026是Agent能力和内容稀缺的指数窗口 | time-sensitive-claim | block | 无 | 缺少基准、市场样本和窗口关闭条件 | 不使用原断言 |
| AIG-C45 | AI工作流应按权限、风险、测量和审计设计 | normative-principle | keep | S04/S06/S09 | 治理原则，不证明具体工具安全或有效 | 使用 |
| AIG-C46 | 每个Agent任务需要目标、上下文、工具、验收和升级条件 | author-method | parameterize | S04/S06/S09 | 可执行工作协议，需按项目调整 | 使用 |
| AIG-C47 | AI能力必须绑定任务、模型、日期和评价指标 | author-method | keep | S01-S06/S09 | 研究与运营记录规则，不是模型能力主张 | 使用 |
| AIG-C48 | 内容资产循环可拆为产出、发现、使用、反馈、复用 | author-synthesis | parameterize | 无 | 作为经营观察框架，不能推出自动收入 | 使用 |
| AIG-C49 | 个人效率只能通过自身基线和结果复盘判断 | author-method | keep | 无 | 适合作为实验原则，不冒充因果研究 | 使用 |
| AIG-C50 | 付费、复用、留存、推荐和边际服务成本共同验证产品 | author-method | parameterize | S07 | 经营验证清单，不是唯一PMF定义 | 使用 |

## 4. 派生规则

1. 派生稿只引用`keep`、`qualify`、`parameterize`、`author-synthesis`和明确改写后的`reframe`主张。
2. `block`主张保留在台账中用于解释删除原因，不进入派生稿正文或引用闭包。
3. 所有AI能力主张必须带任务、工具/模型、核验日期和评价指标；没有这些字段只能写假设或流程规则。
4. 创始人案例只作为待回源材料；本轮不把其收入、利润、员工、融资、粉丝和订阅数字写进证据版。
5. 文章工作流中的时间、字数、Agent数量和成本都视为个人首轮参数，必须记录基线、返工和结果。
6. 内容复利、信任、飞轮和PMF只作为待验证经营模型，不承诺流量、收入或长期留存。
7. 人类负责目标、授权、事实、质量、发布和后果；Agent在受限权限内执行，并保留停止/升级条件。

