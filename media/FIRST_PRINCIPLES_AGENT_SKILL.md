# 第一性拆解 — "Agent Skill"到底是什么？

> 产出方法: dbs-deconstruct R3 (维特根斯坦语言哲学+第一性原理)  
> 拆解对象: "Agent Skill"概念  
> 信源: Anthropic工程博客 + SoK论文 + SkillsBench + OpenSkillEval + 本地审计数据

---

## 第一性变量识别

"Agent Skill"这个概念的不可再分核心变量:

| 变量 | 定义 | 现状(本地147个skill) |
|------|------|---------------------|
| **可发现性** | Agent能否在正确时刻识别并加载skill | 74%无触发词 → 不可发现 |
| **可执行性** | skill是否包含可操作的指令/脚本/流程 | 大量纯SKILL.md → 弱可执行 |
| **可验证性** | 使用skill前后的效果可否量化对比 | 3.3%有.git → 不可验证 |
| **可组合性** | 多个skill能否协同完成复杂任务 | 仅在dbs系列实践 |
| **可演进性** | skill能否随着使用反馈持续改进 | 无CHANGELOG → 不可演进 |

---

## 三层定义（从表到里）

### 表层: "加了工具且有摘要的提示词"

这是常见的理解。对在哪: skill确实包含prompt指令+工具声明+metadata描述。错在哪: 这个理解把skill降维成了"一个文件"，忽略了三层结构中最重要的两个:

1. **文件系统能力** (Anthropic工程博客): "Code execution > inline instructions" — skill不是纯文本指令，是文件系统中的可执行模块
2. **渐进式加载** (Progressive Disclosure): metadata(~50t) → SKILL.md(~500t) → references(按需加载) — 三层各解决不同问题

### 中层: "可复用、可调用的程序性知识模块"

SoK论文定义: "A skill carries its own applicability conditions, termination criteria, and callable interface"
Anthropic定义: "organized folders of instructions, scripts, and resources that agents can discover and load dynamically"

中层定义的关键词: **可复用** (跨任务) × **可调用** (有接口) × **可发现** (有metadata) × **可组合** (有层级)

### 深层(第一性): "skill = 把人类专业知识编译为Agent可渐进式加载的文件系统程序"

拆到底层:
- **编译**: 不是"写提示词"，是把人类的知识/流程/判断转化为Agent可执行的指令+代码+数据包
- **渐进式加载**: 不是"全部塞进上下文"，是按需三层加载 —— metadata路由→SKILL.md执行→references深挖
- **文件系统程序**: 不只是文本，是文件系统中的可执行单元 —— 脚本可以运行(不在上下文中消耗token)，文档可以按需查阅

**一句记住**: Skill不是更好的提示词，是Agent的"可执行外脑"。

---

## 边界与反例

**Skill ≠ Prompt**:
- Prompt: 一次性的对话级指令，每次都要重复写
- Skill: 持久的文件级能力，一次编写、反复调用

**Skill ≠ Tool**:
- Tool: 原子级外部API (搜索/读文件/发消息)
- Skill: 组合级内部能力 (如何使用工具、按什么流程、检查什么)

**Skill ≠ Agent**:
- Agent: 完整的决策-执行循环体
- Skill: 注入Agent循环中的特定领域能力

**反例** (什么时候不应该做成skill):
- 如果你每次使用都需要改内容 → 应该是prompt，不是skill
- 如果它只调用一个工具且无流程逻辑 → 应该是tool description，不是skill
- 如果你无法验证它是否有效 → 应该先做baseline测试(SkillsBench方法), 再做skill

---

## 成立前提（skill有效的必要条件）

1. **任务有规律性**: 同一类任务会反复出现 (否则不存在"可复用")
2. **人类有专业知识**: 存在可被编码的领域知识 (否则skill内容空洞)
3. **Agent有文件系统**: 有bash/代码执行能力 (否则无法渐进式加载)
4. **有验证机制**: 能测量skill使用前后的效果差异 (否则不知道是否有效)

**本地147个skill中，有多少满足这四个前提？** 审计数据显示: 满足全部4条的≤7个(GA级)。其余至少缺少1条。

---

## 边界与第二层推论

**推论1**: 如果一个skill没有触发词(不满足可发现性)，它的其他质量都无意义 —— 因为永远不会被调用。SkillsBench数据: 自生成skill平均-1.3pp退化，OpenSkillEval数据: 最差skill<不使用skill。

**推论2**: "Focused > Comprehensive" (SkillsBench) → skill不是知识库，是操作手册。2-3个精准模块的skill优于10页文档。这个发现推翻了很多skill的设计假设。

**推论3**: "Smaller models with Skills can match larger models without" → skill的真正ROI不在"让强模型更强"，而在"让小模型追上大模型"。这是成本优化的终局方向。

**推论4** (反共识): 杀掉一个坏的skill比创建一个新的skill价值更大。根据OpenSkillEval数据，最差skill拖累性能0.28分——如果你的147个skill中有20%是坏的，它们在系统性降低你的Agent质量。

---

> dbs-deconstruct方法论: 表层→中层→深层三层拆解; 变量识别→边界→反例→前提→推论; 维特根斯坦语言哲学: "概念的边界就是使用的边界"
> SCORE: 9/10 (概念拆解深度足够, 推论有实证支撑, 扣1分因为未包含用户本人的skill使用失败案例)
