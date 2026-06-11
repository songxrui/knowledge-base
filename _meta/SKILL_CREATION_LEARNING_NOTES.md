# Skill 实践创造学习笔记

> 从 246 个 Skill · 15 轮实战 · 5 个元 Skill · 32 次激活 中提炼  
> 2026-06-12 | DeepSeek v4 Pro + Codex CLI

---

## 一、Skill 的第一性理解

### 1.1 定义
一个 Skill 是一个本地文件夹，内含 SKILL.md。宿主模型参数冻结，Skill 文档是**唯一可变外部状态**。Skill 质量 = 把"正确的程序性知识"压进最小 token，并让它在对的时刻被召回。

### 1.2 三层结构
| 层 | 内容 | 作用 |
|----|------|------|
| **触发层** | 
ame + description + 正反例 | 模型的召回与路由信号 |
| **程序层** | body（步骤/规则/门禁） | 被按需载入上下文的"操作手册" |
| **资源层** | eferences/ + scripts/ + ssets/ | 按需加载的辅助材料 |

### 1.3 Skill vs 其他机制
| 机制 | 何时用 |
|------|--------|
| Skill | 模型指令、工作流、轻量约定 |
| MCP | 外部API、持久工具 |
| Hooks | 自动本地事件 |
| Plugin | 打包多个 Skill/MCP 的脚手架 |

---

## 二、Skill 创建规范（从 skill-creator 提炼）

### 2.1 最小形态
`
my-skill/
  SKILL.md          # 唯一必需文件
  references/       # 按需：长文档、示例
  scripts/          # 按需：确定性辅助脚本
  assets/           # 按需：模板、素材
`

### 2.2 创建流程（7步）
1. **一句话定义边界** — Skill做什么、不做什么
2. **选对载体** — Skill / MCP / Hook / Plugin
3. **创建 SKILL.md** — --- 开头，
ame 用 hyphen-case
4. **写 frontmatter** — 
ame + description（含触发词+正反例+不适用场景+边界）
5. **写 body** — 触发条件 → 输入假设 → 分步工作流 → 验证检查 → 安全说明
6. **加辅助文件** — 只在减少真实复杂度时才加
7. **验证** — 通过 /skills 或实战测试

### 2.3 创建前必须做的事（skill-scout 原则）
- 先搜索本地已有 Skill：ind ~/.agents/skills -name SKILL.md | grep -iE "keyword"
- 再搜索市场/GitHub
- 避免重复造轮子

---

## 三、Skill 评估体系（从 skill-review + skill-stocktake 提炼）

### 3.1 10 维评分体系
| # | 维度 | 权重 | 0分 | 5分 | 10分(满分) |
|---|------|------|-----|-----|-----------|
| D1 | 触发精准度 | 10% | description 缺失 | <5个触发词，无正反例 | ≥5触发词 + 适用/不适用场景 + 正反例各2条 |
| D2 | 结构规范度 | 10% | 无 frontmatter | frontmatter 不全 | frontmatter完整 + 章节分明 + 步骤编号 + 验证清单 |
| D3 | 规则可执行性 | 15% | 纯描述无动作 | 1-2个可执行步骤 | 每步明确：做什么→用什么→输出什么→如何验证 |
| D4 | 验证闭环度 | 10% | 无验证 | 笼统验证 | 具体检查项 + 不通过处理 + before→after diff |
| D5 | 示例充分度 | 10% | 0示例 | 1-2个泛例 | ≥3个正例 + ≥2个反例 + 示例绑定具体场景 |
| D6 | 失败兜底 | 10% | 完全无 | 1-2个兜底 | ≥3种失败模式 + 每种有降级方案 + 重试策略 |
| D7 | 边界清晰度 | 10% | 无边界 | 笼统边界 | 与相邻 Skill 的显式划分 + "不适用→重定向到X" |
| D8 | 专业深度 | 10% | 空话堆砌 | 通用建议 | 领域专有概念 + 理论来源 + 实践数据 |
| D9 | AI 适配 | 10% | 不标注模型 | 笼统提到 | 针对具体模型(DS v4 Pro)的适配 + token 预算 + 压缩策略 |
| D10 | Token 预算 | 5% | >8KB | 2-8KB | 0.5-8KB + 核心规则在最短 token + references/ 分离长内容 |

### 3.2 评级标准
| 评级 | 分数 | 含义 |
|------|------|------|
| S | 90+ | 必爆 — 可直接收费 |
| A | 75-89 | 高概率可用 |
| B | 65-74 | 需优化 |
| C | 55-64 | 建议重做 |
| D | <55 | 严重缺陷 |
| INC | — | 不完整（缺 SKILL.md 或无法读取） |

### 3.3 6 门禁系统
| 门禁 | 条件 |
|------|------|
| G1 | 总分 ≥60 |
| G2 | D1(触发) ≥6 |
| G3 | D3(可执行) ≥6 |
| G4 | D6(兜底) ≥6 |
| G5 | D7(边界) ≥6 |
| G6 | body ≤10KB |

---

## 四、Skill 优化方法论（SkillOpt 思想 + 实战）

### 4.1 优化循环
`
rollout（跑真实任务，记录失败）
  → reflection（分析失败模式）
    → edit（add/delete/replace，每轮 ≤4 条）
      → validation（留出任务验证，没涨就回滚）
        → rejected buffer（记下被否改动）
          → slow update（跨版本纵向回顾）
`

### 4.2 克制原则
- 每轮改动 ≤4 条
- 没涨就回滚
- 被否改动入缓冲，避免重犯
- 先手动跑通再自动化

### 4.3 常见问题与修法
| 问题 | 表现 | 修法 |
|------|------|------|
| 误触发 | 不该触发时触发了 | 收紧 description，加"不适用场景" |
| 漏触发 | 该触发时不触发 | 扩充触发关键词，加正例 |
| Token 膨胀 | >8KB | 拆分 eferences/，删除冗余规则 |
| 语义重叠 | 两个 Skill 抢触发 | 明确边界 + "X情况→用Y Skill" |

### 4.4 Token 预算管理
- 中位目标：~900 token（SkillOpt 优化后）
- 上限：~2,000 token
- 超过 2,500 token 必须拆分 eferences/
- 核心规则 < body 的 60%

---

## 五、Skill 生态系统（从实战经验提炼）

### 5.1 Skill 生命周期
`
skill-scout（搜索）→ skill-installer（安装）
  → skill-stocktake（盘点）→ skill-review（评测）
    → skill-creator（创建/优化）→ skill-forge（锻造升级）
      → skill-deployer（部署）→ skill-synthesizer（交叉合成）
`

### 5.2 安装来源
| 来源 | 方式 |
|------|------|
| 本地 | 复制文件夹到 ~/.agents/skills/ |
| GitHub | 
px -y skills add <repo> -g --all |
| 市场 | Codex 内置市场 |

### 5.3 从 246 个 Skill 中提炼的最佳实践

#### 结构模式
- **6步工作流**（viral-writer）：需求确认→内部分析→创作→标题→配图→输出
- **5阶段执行**（traffic-engineering）：诊断→优化→评分→适配→验证
- **检测+对策双轨**（humanizer/ai-taste-check）：先诊断病征→再给对策→最后验证

#### description 写法模板
`
description: "[做什么]。触发：[关键词列表]。不适用：[排除场景]。
正例：'[具体触发语句]'→触发。反例：'[不触发语句]'→不触发→[重定向Skill]。"
`

#### 高质量 Skill 的共同特征
1. **description 极度精准** — 含触发词+正反例+边界
2. **body 极度可操作** — 每步有动作+工具+验证
3. **失败模式明确** — ≥3 种失败模式+降级方案
4. **与相邻 Skill 划清边界** — 显式标注"不适用→用X"
5. **Token 克制** — 核心规则 < 2KB

---

## 六、Codex/DeepSeek 专属适配

### 6.1 DS v4 Pro 已知弱点与补偿
| 弱点 | 补偿策略 |
|------|---------|
| 复杂多步指令可能漏步 | 每步编号 + 完成后确认 |
| 64K+ 上下文精度下降 | headroom 压缩 + strategic-compact |
| 工具调用偶有格式错误 | compile-and-verify 事后校验 |
| 幻觉倾向 | 强制标注"推断/待核实" + exa 库外验证 |

### 6.2 DS 指令风格规范
1. **显式 > 隐式** — 每一步写明"做什么→用什么工具→输出什么→如何验证"
2. **编号 > 段落** — 多步任务用编号列表
3. **确认 > 假设** — 工具输出必须验证后使用
4. **分解 > 合并** — 复杂任务拆为 ≤3 步子任务
5. **先搜 > 先猜** — 事实性任务先用搜索工具

### 6.3 Skill 发现路径（Codex CLI）
- <workspace>/.agents/skills
- ~/.agents/skills
- <workspace>/skills
- ~/.claude/skills
- ~/.deepseek/skills

---

## 七、15 轮实战经验沉淀

### 7.1 32 个 Skill 激活效果排名
| 排名 | Skill | 实战效果 | 关键原因 |
|------|-------|---------|---------|
| 1 | traffic-engineering | 82/100→三平台版 | 结构化流程+可溯源评分 |
| 2 | humanizer | 4→2 禁用词 | 黑名单成熟+病征诊断 |
| 3 | viral-writer | 88/110 诊断 | 11 维完整+三平台内建 |
| 4 | skill-review | 8 Skill 评测 | 10 维体系+6 门禁 |
| 5 | content-reverse | 五段式框架 | 可复用句式模板 |

### 7.2 常见陷阱
1. **大模型偷懒写正文** — 用 content-pipeline-orchestrator 强制走 Skill 链
2. **Skill 触发条件太弱** — description 缺正反例导致漏触发
3. **Token 膨胀** — humanizer 28.5KB，需拆分 references
4. **缺少失败兜底** — 4/8 Skill D6<6
5. **中文适配不足** — English-native Skill 需追加中文特有模式

### 7.3 新 Skill 孵化清单
| Skill | 用途 | 预期 Token |
|-------|------|-----------|
| content-pipeline-orchestrator | 五步流水线编排 | ~3KB (已孵化) |
| quality-gatekeeper | 6 门禁统一检查 | ~2KB |
| evidence-enricher | 微信读书↔内容自动溯源 | ~3KB |

---

## 八、Skill 创造检查清单

创建新 Skill 前逐项确认：

- [ ] 已搜索本地+市场是否有同类 Skill
- [ ] 已定义一句话边界（做什么/不做什么）
- [ ] frontmatter 含 
ame + description（触发词+正反例+边界）
- [ ] body 含触发条件→输入假设→分步工作流→验证→安全
- [ ] 每步写明：做什么→用什么工具→输出什么→如何验证
- [ ] ≥3 种失败模式 + 降级方案
- [ ] 与相邻 Skill 的边界标注
- [ ] body ≤10KB（超过则拆分 references/）
- [ ] G1-G6 全部 ≥6
- [ ] 针对 DS v4 Pro 做适配标注

---

> 数据来源: C:\Users\董辉\.codex\skills\ (246 Skill) + D:\_ai\skills\skill-review\ + 15 轮实战
> 理论来源: SkillOpt (Microsoft) + ECC AGENTS.md + skill-creator/skill-review/skill-installer/skill-scout/skill-stocktake
