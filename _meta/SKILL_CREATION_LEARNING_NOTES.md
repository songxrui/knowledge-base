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

---

## 九、跨域 Skill 通用模式（8 种可复用结构）

> 从 tdd-workflow(13.6KB) / security-review(12.9KB) / e2e-testing(17.4KB) / content-guard / compile-and-verify / mcp-builder(1.2KB) 6 个跨域 Skill 提炼

### 模式 A：证据门禁推进（Evidence-Gated Progression）

**定义**：每一步完成后有显式验证，验证不通过禁止进入下一步。

**典型案例** — tdd-workflow 的 RED→GREEN 门禁：
```
Step 3: 写测试 → 运行测试 → 必须 RED（失败才算通过）
  ↓ 门禁：未确认 RED 状态？→ 禁止修改业务代码
Step 4: 写最小实现
  ↓ 门禁：必须编译通过
Step 5: 运行测试 → 必须 GREEN
  ↓ 门禁：未全绿？→ 回到 Step 4
Step 6: 重构（可选）
```

**另一案例** — content-guard 的 6 门禁：
| 门禁 | 检查内容 | 不通过处理 |
|------|---------|-----------|
| Delta 验证 | 改动行数 vs 预期 | 差异 >20% → BLOCK |
| 基线锁定 | 修改前备份存在 | 缺失 → BLOCK |
| 抽样 diff | 随机 3 文件 diff 审 | 有问题 → WARNING |
| 关键词扫描 | 禁用词/敏感信息 | 命中 → BLOCK |
| 循环计数器 | 同文件修改轮次 | >3 轮 → BLOCK |
| 环境自检 | 工作目录/仓库状态 | 异常 → BLOCK |

**可复用要素**：
- 每步有可观测通过判据（不是"检查一下"而是"运行 X 命令，输出应包含 Y"）
- 失败有明确阻断级别（BLOCK 立即停 / WARNING 批量输出）
- 门禁先于动作（先验证 RED 才写代码；先过门禁才放行）

### 模式 B：PASS/FAIL 双轨教学（Antipattern Contrast）

**定义**：每个风险点同时展示错误做法和正确做法，用代码对比替代纯文字警告。

**来源**：security-review 全文 9 个安全检查项，每项结构：
```
#### FAIL: NEVER Do This
` ` `code` ` `  ← 错误代码

#### PASS: ALWAYS Do This
` ` `code` ` `  ← 正确代码

#### Verification Steps
- [ ] 检查项 1
- [ ] 检查项 2
```

**e2e-testing 中的同类模式**（Flaky Test → Fix）：
```
// Bad: assumes element is ready
await page.click('[data-testid="button"]')

// Good: auto-wait locator
await page.locator('[data-testid="button"]').click()
```

**为什么有效**：模型对"不要做什么"的理解远弱于"这是错的 / 这是对的"的对比。PASS/FAIL 双轨 = 把禁止规则变成可模仿的正确代码。

**何时用**：
- 安全类 Skill（SQL 注入、XSS、密钥泄露）
- 规范类 Skill（代码风格、测试写法）
- 任何"容易踩坑"的领域

**何时不用**：创造性工作（写作/设计）——没有唯一正确答案。

### 模式 C：分步编号工作流（Numbered Step Pipeline）

**定义**：用编号步骤定义线性执行顺序，每步有独立输入/输出/验证。

**采样数据**：
| Skill | 步骤数 | 每步验证 | Git 提交策略 |
|-------|--------|---------|------------|
| tdd-workflow | 8 步 | RED/GREEN 门禁 | 每阶段 1 commit |
| mcp-builder | 6 步 | 最后 1 步测试通过 | 无强制 |
| compile-and-verify | 2 阶段 | 质检表逐项 ✓/✗ | 无强制 |
| documents | 4 步 | G1-G6 自评 | 无强制 |

**compile-and-verify 的极简两阶段**：
```
Phase 1 编译：模糊输入 → 真实目标 + 可量化目标变量 + 分步计划 + 假设清单
Phase 2 质检：逐项核查目标变量 + 低级错误扫描 + 结论（通过/打回）
```

**步骤粒度原则**：
- 每步应有独立可验证输出（不是"分析需求"而是"产出用户旅程列表，≥3 条"）
- 步骤间耦合通过门禁管理（前一步未验证，后一步不启动）
- ≤10 步（超过应分子 Skill）

### 模式 D：子模式分化（Sub-mode Disaggregation）

**定义**：同一 Skill 内根据任务复杂度走不同路径，避免简单任务被复杂流程拖死。

**唯一案例** — compile-and-verify：
```
simple 路径（如"把 README.md 里的 v1.0 改成 v2.0"）：
  编译 30-80 tokens → 质检 30-80 tokens → 全流程 ≤200 tokens

complex 路径（如"给 API 加限流中间件"）：
  编译 100-200 tokens → 质检 80-150 tokens → 全流程 ≤500 tokens
```

**分化判据**：
- 是否涉及多文件？→ complex
- 是否需要假设补充信息？→ complex
- 是否可在单次 read→edit→verify 完成？→ simple

**为什么重要**：不让"改一行文字"走完 8 步 TDD 流程。Skill 应自判复杂度并降级。

### 模式 E：边界声明 + 组合关系（Boundary + Skill Combo）

**定义**：在 Skill 文档中显式列出"我不做什么"和"应该用什么替代"，防止语义重叠和误触发。

**compile-and-verify 的边界声明**（行业最佳）：
```
本 Skill 不负责：
- 不做逐行代码审查 → 由 diff-reviewer 负责
- 不做权限审查 → 由 permission-reviewer 负责
- 不做内容质量迭代 → 由 evaluator-optimizer 负责
- 不做记忆持久化 → 由 session-memory 负责

可以接力：
- plan-reviewer：编译后可选的边界审查层
- evaluator-optimizer：可串联使用
```

**另一种做法** — documents skill 的 description 边界：
```
description: "不适用：飞书文档→feishu; Markdown→直接写; 幻灯片→presentations"
```

**写法标准**：
- 每个"不负责"必须指向具体替代 Skill（不能只说"不做 X"）
- 边界判断条件用用户能理解的场景语言（不是技术术语）

### 模式 F：失败处方表（Failure Prescription Table）

**定义**：预设所有已知失败模式及对应处理动作，模型不需要"自己想办法"。

**compile-and-verify 的失败预案**：
| 场景 | 兜底 |
|------|------|
| 需求极度模糊/矛盾 | 标记"致命歧义"，只问 1-2 个最关键确认点 |
| 编译假设错误 | 暂停，回退 Phase 1 更新目标变量和计划 |
| 质检发现致命问题 | 进入修复循环（最多 3 轮） |
| 3 轮仍未通过 | 输出当前状态 + 剩余失败项 + 尝试记录，请求用户 |
| 工具链/环境不满足 | 标注"环境依赖待确认"，建议替代方案 |

**e2e-testing 的 Flaky 处理**：
```
发现 Flaky → test.fixme() 隔离 → --repeat-each=10 复现 → 修根因 → 移除 quarantine
```

**为什么是"处方"而非"检查清单"**：处方包含动作（"回退 Phase 1"），清单只列问题。Skill 应减少模型在失败时的自主决策空间。

### 模式 G：制品管理（Artifact Blueprint）

**定义**：定义产出物的标准格式和存放位置，确保跨轮次一致。

**e2e-testing 的测试报告模板**：
```
# E2E Test Report
**Date:** YYYY-MM-DD | **Duration:** Xm Ys | **Status:** PASSING/FAILING
## Summary: Total X | Passed Y (Z%) | Failed A | Flaky B | Skipped C
## Failed Tests: 文件名 + 行号 + 错误 + 截图 + 修复建议
## Artifacts: HTML报告 / 截图 / 视频 / Traces
```

**compile-and-verify 的质检表模板**：
```
| 目标变量 | 预期 | 实际 | ✓/✗ |
|---------|------|------|-----|
| 变量1 | ... | ... | ... |
低级错误扫描：...
结论：通过交付 / 打回修复（第 N/3 轮）
修复清单（若打回）：1. ... 2. ...
```

**设计原则**：
- 模板字段有明确填写规则（不是"写个总结"）
- 制品路径固定（如 `artifacts/*.png`）
- 包含元数据（时间/轮次/状态）方便审计

### 模式 H：G1-G6 自评嵌入（Self-Assessment Footer）

**定义**：Skill 文档末尾嵌入标准化自评表，作为分发前的最后检查。

**标准格式**：
```
## G1-G6
| 门禁 | 状态 |
|------|------|
| G1 ≤10KB | ✅ |
| G2 触发层 | ✅ |
| G3 可执行 | ✅ |
| G4 验证 | ✅ |
| G5 失败兜底 | ✅ |
| G6 安全 | ✅ |
```

**使用频率**：compile-and-verify / documents / mcp-builder / e2e-testing 均包含此自评。

**为什么有效**：Skill 作者在发布前被迫逐项确认，减少"写了但不可用"的 Skill。

---

## 十、从 6 个跨域 Skill 提取的通用 Quality Gates

比对各 Skill 的验证机制，提炼出一套可跨域复用的门禁体系：

| 门禁层 | 来源 Skill | 检查方式 | 适用域 |
|--------|-----------|---------|--------|
| **执行前验证** | tdd-workflow RED gate | 运行命令确认失败 | 所有"先写测试"域 |
| **执行后验证** | tdd-workflow GREEN gate | 运行命令确认通过 | 所有"修改后验证"域 |
| **批量安全阀** | content-guard 6 门禁 | 文件级 diff 扫描 | ≥2 文件修改 |
| **安全基线** | security-review checklist | 逐项勾选确认 | 涉及用户数据/密钥 |
| **制品完整性** | e2e-testing report template | 模板字段全部填写 | 需要跨轮次追踪 |
| **编译→质检闭环** | compile-and-verify | 目标变量逐一过检 | 所有最终交付物 |
| **Token 预算** | compile-and-verify | 按 simple/complex 预算 | 所有 Skill body |

---

> 数据来源: C:\Users\董辉\.codex\skills\ (246 Skill) + D:\_ai\skills\skill-review\ + 15 轮实战
> 跨域 Skill 采样: tdd-workflow(13.6KB/ECC) + security-review(12.9KB/ECC) + e2e-testing(17.4KB) + content-guard + compile-and-verify + mcp-builder(1.2KB)

---

## 十一、Skill 原型分类学（7 种原型 × 355 Skill 全量）

> 从 355 个 Skill 中提炼出 7 种结构原型。每种原型有不同的设计约束、质量标准和常见陷阱。

### 原型总览

| # | 原型 | 数量(估) | 核心特征 | 代表 Skill |
|---|------|---------|---------|-----------|
| P1 | 元 Skill | ~15 | 自指涉、评测驱动、生命周期管理 | skill-review, skill-forge, skill-creator |
| P2 | 内容创作 | ~40 | 多阶段流水线、平台适配、禁用词黑名单 | viral-writer, humanizer-zh, article-writing |
| P3 | 工程开发 | ~50 | 证据门禁、PASS/FAIL 双轨、代码示例 | tdd-workflow, security-review, compile-and-verify |
| P4 | 研究搜索 | ~20 | 来源分级、多源交叉验证、证据溯源 | deep-research, exa-search, weread-skills |
| P5 | 平台集成 | ~30 | API 封装、凭据管理、CLI 包装 | feishu, x-api, github, crosspost |
| P6 | 编排调度 | ~10 | 多 Agent 协调、决策树路由、回退链 | dmux-workflows, agent-sort |
| P7 | 工具实用 | ~190 | 单用途、CLI 驱动、无状态 | agent-reach, file-organizer, headroom |

---

### P1：元 Skill（Meta-Skill）— "管理 Skill 的 Skill"

**定义**：以其他 Skill 为操作对象的 Skill。自指涉结构。

**结构模板**：
```
触发层：description 含边界路由（不适用→指向替代元 Skill）
程序层：评测/锻造/安装/部署 的标准流水线
资源层：评分 rubric / G1-G6 模板 / 版本记录
```

**设计约束**：
- description 必须含"不适用→重定向到 X"（元 Skill 之间语义重叠最严重）
- body 必须含 G1-G6 自评（以身作则）
- 必须有"与其他元 Skill 的联动图"（ASCII 流程图）
- Token 上限更严格：≤5KB（元 Skill 自身膨胀是最大的讽刺）

**常见陷阱**：
- 元 Skill 自身未过 G1-G6 → 可信度归零
- 元 Skill 之间的边界模糊（skill-forge vs skill-creator vs skill-synthesizer）
- 评测标准过于抽象无法执行

**skill-forge 的联动图示例**：
```
skill-review → 评测发现低分 skill
    ↓
skill-forge → 锻造优化
    ↓
skill-creator → 参考模式创建新 skill
skill-distiller → 去重合并
skill-deployer → 部署分发
```

---

### P2：内容创作 Skill（Content Creation）— "把素材变成作品"

**定义**：输入素材/主题，输出结构化内容。多阶段流水线，平台感知。

**结构模板**：
```
触发层：触发词=内容类型+平台+动作
程序层：诊断→创作→标题→优化→验证 的线性/循环流水线
资源层：禁用词黑名单、平台风格指南、标题公式库
```

**viral-writer 的 6 步流水线**（行业最完整）：
```
需求确认 → 内部分析(11维诊断) → 创作 → 标题优化 → 配图 → 多平台输出
```

**humanizer-zh 的双轨模式**（检测+对策）：
```
AI 病征诊断(扫描4大类特征) → 针对性改写 → 去味验证
```

**设计约束**：
- 必须含禁用词黑名单（"赋能/抓手/闭环/综上所述…"）
- 必须含平台适配（公众号 vs 小红书 vs 抖音 的差异化要求）
- 必须有质量门禁（"改写后字数 ≥ 原文 1.5×"）
- 禁止空洞的"优化内容质量"——必须有可观测判据

**常见陷阱**：
- 黑名单不完整→AI味漏网
- 平台要求互相矛盾→改A平台破坏B平台
- 只给原则不给动作（"增强可读性" vs "每 150 字至少 1 个具体数字/案例"）

---

### P3：工程开发 Skill（Engineering）— "先验证再放行"

**定义**：以代码/系统为操作对象。证据门禁驱动，PASS/FAIL 双轨。

**结构模板**：
```
触发层：按操作类型激活（写新功能/修bug/加认证/写测试）
程序层：RED→GREEN→REFACTOR 或 Build→Type→Lint→Test→Security→Diff
资源层：代码模板(正确/错误对比)、checklist、CI/CD 配置
```

**核心模式**（见第九部分详述）：
- 模式 A：证据门禁推进（tdd-workflow RED/GREEN）
- 模式 B：PASS/FAIL 双轨教学（security-review）
- 模式 C：分步编号工作流（mcp-builder 6步）
- 模式 D：子模式分化（compile-and-verify simple/complex）
- 模式 F：失败处方表（compile-and-verify 5种失败兜底）

**设计约束**：
- 每步必须有可运行命令验证（不是"检查一下"）
- 失败处理必须有具体动作（不是"修复它"）
- 安全类 Skill 必须含密钥管理规则（"密钥=环境变量，永不提交"）
- 必须含 Git commit 策略（tdd-workflow: 每阶段 1 commit）

**常见陷阱**：
- 验证条件不可观测（"确保代码质量"）
- 安全 Skill 只列风险不列检查命令
- 过于依赖特定技术栈（应标注适用范围）

---

### P4：研究搜索 Skill（Research）— "先搜后说，标注来源"

**定义**：以外部信息为操作对象。来源分级，交叉验证，禁止编造。

**结构模板**：
```
触发层：按信息类型激活（事实核查/深度研究/市场分析/文档查询）
程序层：搜索→提取→分级→交叉验证→综合
资源层：来源等级标准、搜索 query 模板、引用格式
```

**deep-research 的来源分级**：
```
[S] 一手来源（论文/官方文档/实验数据）
[A] 权威二手（权威媒体/知名分析师）
[B] 推断（模型基于多源推理，非直接引用）
[C] 待核实（单一来源/无法交叉验证）
```

**设计约束**：
- 必须含来源分级标准（S/A/B/C）
- 必须含"信息不足时"的处理规则（显式假设 vs 追问 3 个关键问题）
- 禁止伪造引用、禁止二手转述当一手
- 搜索结果必须标注日期和 URL

**常见陷阱**：
- 搜索结果不标注日期 → 信息时效性不可知
- "研究发现表明" → 不标具体研究
- 用搜索结果填充篇幅而非回答问题

---

### P5：平台集成 Skill（Platform Integration）— "封装 API 为可调用工具"

**定义**：以第三方平台 API 为操作对象。凭证管理，错误处理，CLI 包装。

**结构模板**：
```
触发层：按平台+动作激活（发飞书/发推/查GitHub/推送到X）
程序层：认证→构建请求→发送→处理响应→错误兜底
资源层：API 文档链接、认证配置指南、错误码对照表
```

**共同特征**：
- 认证信息一律走环境变量（`$env:FEISHU_APP_ID`）
- 错误处理分类（401=凭证过期、429=限流、5xx=服务端故障）
- 幂等性保证（推送前检查是否已存在）

**设计约束**：
- 密钥管理：环境变量 100%，零硬编码
- 错误处理：每种 HTTP 状态码有对应动作
- 速率限制：标注 API 限额和推荐请求间隔
- 重试策略：429→等 Retry-After；5xx→指数退避最多 3 次

**常见陷阱**：
- 凭证泄露到日志/Git 历史
- 不处理 API 限流导致批量操作中断
- 只写正常路径，不写异常路径

---

### P6：编排调度 Skill（Orchestration）— "决定谁做什么、按什么顺序做"

**定义**：以多个 Agent/Skill 的协调为操作对象。决策树路由，回退链。

**结构模板**：
```
触发层：按任务复杂度激活（多步骤/多模块/需要协调）
程序层：任务分解→Agent 分配→并行/串行决策→结果汇总→冲突解决
资源层：Agent 能力矩阵、路由决策树、冲突解决规则
```

**dmux-workflows 的核心模式**：
```
tmux 窗格 = Agent 实例
窗格间通信 = Agent 协作
主窗格 = 编排者（只调度，不执行）
```

**设计约束**：
- 必须有 Agent 能力矩阵（哪个 Agent 擅长什么）
- 必须有路由决策树（什么任务分配给哪个 Agent）
- 必须有冲突解决规则（两个 Agent 产出矛盾时谁裁决）
- 必须有超时/卡死处理（Agent 无响应时的降级方案）

**常见陷阱**：
- 过度编排 → 简单任务走了复杂调度
- Agent 职责重叠 → 两个 Agent 做同一件事
- 编排者自己做了执行工作 → 角色混乱

---

### P7：工具实用 Skill（Utility）— "一个命令解决一个问题"

**定义**：单用途、CLI 驱动、无状态。最大类别（~190 个）。

**结构模板**：
```
触发层：命令式触发词+输入格式
程序层：输入→处理→输出（≤3 步）
资源层：CLI 安装指南、命令参考
```

**agent-reach 的路由表模式**（17 平台零配置）：
```
| 用户意图 | 分类 | 详细文档 |
| 小红书/抖音/微博 | social | references/social.md |
| GitHub/代码 | dev | references/dev.md |
| YouTube/B站 | video | references/video.md |
```

**设计约束**：
- ≤3 步完成（超过→应拆分为独立 Skill）
- 输出格式固定（方便管道串联）
- 错误信息清晰（用户可直接按提示修复）
- Token 预算 ≤2KB（最大类别，必须克制）

**常见陷阱**：
- 功能蔓延：一个工具 Skill 装了 10 个不相关的功能
- 隐式依赖：不声明依赖的 CLI/API 工具
- 输出格式多变：下游无法可靠解析

---

### 原型选择决策树

```
需要操作其他 Skill？
  ├─ 是 → P1 元 Skill（含 G1-G6 自评 + 联动图）
  └─ 否 → 需要产出文字/媒体内容？
            ├─ 是 → P2 内容创作（含黑名单 + 平台适配 + 质量门禁）
            └─ 否 → 操作对象是代码/系统？
                      ├─ 是 → P3 工程开发（含证据门禁 + PASS/FAIL 双轨）
                      └─ 否 → 操作对象是外部信息？
                                ├─ 是 → P4 研究搜索（含来源分级 + 交叉验证）
                                └─ 否 → 操作对象是第三方平台？
                                          ├─ 是 → P5 平台集成（含凭据管理 + 错误处理）
                                          └─ 否 → 需要协调多个 Agent/Skill？
                                                    ├─ 是 → P6 编排调度（含路由决策树）
                                                    └─ 否 → P7 工具实用（≤3步, ≤2KB）
```

---

## 十二、Skill 优化实战案例（Before/After）

> 从 15 轮实战中选取 3 个代表性案例，展示优化前后的结构差异和分数变化。

### 案例 1：humanizer-zh — 从 28.5KB 膨胀到 8KB 精选

**问题诊断**：
- 原始大小 28.5KB，远超 10KB 上限
- 黑名单词 87 个，但 60% 为罕见词（token 浪费）
- description 只有一句话，无正反例、边界

**优化动作**（4 轮迭代）：
1. 拆分 references/：黑名单全文 → `references/blacklist.md`（18KB）
2. body 精简为标准模板：定义→诊断→改写→验证，每步 ≤500 字
3. description 重写：触发词 8 个 + 适用场景 5 个 + 不适用 3 个 + 正反例各 2 条
4. 追加 G1-G6 自评 + 失败兜底 + 边界声明

**Before→After**：
| 维度 | Before | After |
|------|--------|-------|
| 大小 | 28.5KB | 8.2KB (body) + 18KB (references) |
| D1 触发 | 3/10 | 9/10 |
| D3 可执行 | 5/10 | 8/10 |
| D6 兜底 | 3/10 | 7/10 |
| D7 边界 | 2/10 | 8/10 |
| **总分** | **48→C** | **78→A** |

---

### 案例 2：documents — 从 STUB(0.9KB) 到 R3 RICH(1.3KB)

**问题诊断**：
- 原始只有 4 行正文："创建Word文档。使用模板生成内容。"
- 无工作流、无验证、无错误处理
- description 含路径泄露（`C:\Users\...`）

**优化动作**（skill-forge 6步）：
1. 读原始 + reference → 提取：文档类型识别、模板加载、生成、格式化
2. 重写 description：触发词 7 个 + 不适用 3 场景 + 正反例各 2 条
3. 建 4 步工作流：识别类型→加载模板→生成内容→格式化输出
4. 加 G1-G6 自评 + 边界（不适用：飞书→feishu, Markdown→直接写）

**Before→After**：
| 维度 | Before | After |
|------|--------|-------|
| 大小 | 0.9KB | 1.3KB |
| D1 触发 | 2/10 | 9/10 |
| D3 可执行 | 1/10 | 7/10 |
| D4 验证 | 0/10 | 6/10 |
| D7 边界 | 0/10 | 8/10 |
| **总分** | **18→INC** | **72→B** |

---

### 案例 3：skill-forge 自身 — 从 8 次 R3 优化中孵化的元 Skill

**诞生过程**：
- 孵化来源：深度分析 8 个 dbs-* skill 的 R3 优化操作模式
- 发现规律：每次 R3 优化都是同一个 6 步流程（读→提取→写description→建Phase→加验证→G1-G6）
- 抽象为元 Skill：把"我做了 8 次的事"变成"一个可复用的 Skill"

**关键设计决策**：
1. 不直接修改原文件 → 先备份为 `.bak`
2. 按原始大小分 4 级处理策略（STUB<1KB / THIN 1-5KB / OK 5-10KB / RICH>10KB）
3. 与其他元 Skill 的联动图内置在 body 中

**孵化前后对比**：
| 指标 | 手工 R3 优化(8次平均) | skill-forge 自动化 |
|------|---------------------|-------------------|
| 耗时 | ~15min/个 | ~3min/个 |
| G1-G6 覆盖率 | 62% | 100% |
| description 正反例 | 2/8 完整 | 8/8 完整 |
| 遗漏边界声明 | 5/8 遗漏 | 0/8 遗漏 |

---

> 数据来源: C:\Users\董辉\.codex\skills\ (355 Skill 去重) + D:\_ai\skills\skill-review\ + 15 轮实战
> 跨域 Skill 采样: tdd-workflow(13.6KB) + security-review(12.9KB) + e2e-testing(17.4KB) + content-guard + compile-and-verify + mcp-builder(1.2KB)
> 原型采样: skill-forge(4.6KB) + viral-writer + humanizer-zh + deep-research + agent-reach(3.5KB) + dmux-workflows + feishu + x-api + crosspost + brand-voice
> 理论来源: SkillOpt (Microsoft) + ECC AGENTS.md + skill-creator/skill-review/skill-installer/skill-scout/skill-stocktake
> 理论来源: SkillOpt (Microsoft) + ECC AGENTS.md + skill-creator/skill-review/skill-installer/skill-scout/skill-stocktake
> 数据来源: C:\Users\董辉\.codex\skills\ (246 Skill) + D:\_ai\skills\skill-review\ + 15 轮实战

---

## 十一、Skill 原型分类学（7 种原型 × 355 Skill 全量）

> 从 355 个 Skill 中提炼出 7 种结构原型。每种原型有不同的设计约束、质量标准和常见陷阱。

### 原型总览

| # | 原型 | 数量(估) | 核心特征 | 代表 Skill |
|---|------|---------|---------|-----------|
| P1 | 元 Skill | ~15 | 自指涉、评测驱动、生命周期管理 | skill-review, skill-forge, skill-creator |
| P2 | 内容创作 | ~40 | 多阶段流水线、平台适配、禁用词黑名单 | viral-writer, humanizer-zh, article-writing |
| P3 | 工程开发 | ~50 | 证据门禁、PASS/FAIL 双轨、代码示例 | tdd-workflow, security-review, compile-and-verify |
| P4 | 研究搜索 | ~20 | 来源分级、多源交叉验证、证据溯源 | deep-research, exa-search, weread-skills |
| P5 | 平台集成 | ~30 | API 封装、凭据管理、CLI 包装 | feishu, x-api, github, crosspost |
| P6 | 编排调度 | ~10 | 多 Agent 协调、决策树路由、回退链 | dmux-workflows, agent-sort |
| P7 | 工具实用 | ~190 | 单用途、CLI 驱动、无状态 | agent-reach, file-organizer, headroom |

---

### P1：元 Skill（Meta-Skill）— "管理 Skill 的 Skill"

**定义**：以其他 Skill 为操作对象的 Skill。自指涉结构。

**结构模板**：
```
触发层：description 含边界路由（不适用→指向替代元 Skill）
程序层：评测/锻造/安装/部署 的标准流水线
资源层：评分 rubric / G1-G6 模板 / 版本记录
```

**设计约束**：
- description 必须含"不适用→重定向到 X"（元 Skill 之间语义重叠最严重）
- body 必须含 G1-G6 自评（以身作则）
- 必须有"与其他元 Skill 的联动图"（ASCII 流程图）
- Token 上限更严格：≤5KB（元 Skill 自身膨胀是最大的讽刺）

**常见陷阱**：
- 元 Skill 自身未过 G1-G6 → 可信度归零
- 元 Skill 之间的边界模糊（skill-forge vs skill-creator vs skill-synthesizer）
- 评测标准过于抽象无法执行

**skill-forge 的联动图示例**：
```
skill-review → 评测发现低分 skill
    ↓
skill-forge → 锻造优化
    ↓
skill-creator → 参考模式创建新 skill
skill-distiller → 去重合并
skill-deployer → 部署分发
```

---

### P2：内容创作 Skill（Content Creation）— "把素材变成作品"

**定义**：输入素材/主题，输出结构化内容。多阶段流水线，平台感知。

**结构模板**：
```
触发层：触发词=内容类型+平台+动作
程序层：诊断→创作→标题→优化→验证 的线性/循环流水线
资源层：禁用词黑名单、平台风格指南、标题公式库
```

**viral-writer 的 6 步流水线**（行业最完整）：
```
需求确认 → 内部分析(11维诊断) → 创作 → 标题优化 → 配图 → 多平台输出
```

**humanizer-zh 的双轨模式**（检测+对策）：
```
AI 病征诊断(扫描4大类特征) → 针对性改写 → 去味验证
```

**设计约束**：
- 必须含禁用词黑名单（"赋能/抓手/闭环/综上所述…"）
- 必须含平台适配（公众号 vs 小红书 vs 抖音 的差异化要求）
- 必须有质量门禁（"改写后字数 ≥ 原文 1.5×"）
- 禁止空洞的"优化内容质量"——必须有可观测判据

**常见陷阱**：
- 黑名单不完整→AI味漏网
- 平台要求互相矛盾→改A平台破坏B平台
- 只给原则不给动作（"增强可读性" vs "每 150 字至少 1 个具体数字/案例"）

---

### P3：工程开发 Skill（Engineering）— "先验证再放行"

**定义**：以代码/系统为操作对象。证据门禁驱动，PASS/FAIL 双轨。

**结构模板**：
```
触发层：按操作类型激活（写新功能/修bug/加认证/写测试）
程序层：RED→GREEN→REFACTOR 或 Build→Type→Lint→Test→Security→Diff
资源层：代码模板(正确/错误对比)、checklist、CI/CD 配置
```

**核心模式**（见第九部分详述）：
- 模式 A：证据门禁推进（tdd-workflow RED/GREEN）
- 模式 B：PASS/FAIL 双轨教学（security-review）
- 模式 C：分步编号工作流（mcp-builder 6步）
- 模式 D：子模式分化（compile-and-verify simple/complex）
- 模式 F：失败处方表（compile-and-verify 5种失败兜底）

**设计约束**：
- 每步必须有可运行命令验证（不是"检查一下"）
- 失败处理必须有具体动作（不是"修复它"）
- 安全类 Skill 必须含密钥管理规则（"密钥=环境变量，永不提交"）
- 必须含 Git commit 策略（tdd-workflow: 每阶段 1 commit）

**常见陷阱**：
- 验证条件不可观测（"确保代码质量"）
- 安全 Skill 只列风险不列检查命令
- 过于依赖特定技术栈（应标注适用范围）

---

### P4：研究搜索 Skill（Research）— "先搜后说，标注来源"

**定义**：以外部信息为操作对象。来源分级，交叉验证，禁止编造。

**结构模板**：
```
触发层：按信息类型激活（事实核查/深度研究/市场分析/文档查询）
程序层：搜索→提取→分级→交叉验证→综合
资源层：来源等级标准、搜索 query 模板、引用格式
```

**deep-research 的来源分级**：
```
[S] 一手来源（论文/官方文档/实验数据）
[A] 权威二手（权威媒体/知名分析师）
[B] 推断（模型基于多源推理，非直接引用）
[C] 待核实（单一来源/无法交叉验证）
```

**设计约束**：
- 必须含来源分级标准（S/A/B/C）
- 必须含"信息不足时"的处理规则（显式假设 vs 追问 3 个关键问题）
- 禁止伪造引用、禁止二手转述当一手
- 搜索结果必须标注日期和 URL

**常见陷阱**：
- 搜索结果不标注日期 → 信息时效性不可知
- "研究发现表明" → 不标具体研究
- 用搜索结果填充篇幅而非回答问题

---

### P5：平台集成 Skill（Platform Integration）— "封装 API 为可调用工具"

**定义**：以第三方平台 API 为操作对象。凭证管理，错误处理，CLI 包装。

**结构模板**：
```
触发层：按平台+动作激活（发飞书/发推/查GitHub/推送到X）
程序层：认证→构建请求→发送→处理响应→错误兜底
资源层：API 文档链接、认证配置指南、错误码对照表
```

**共同特征**：
- 认证信息一律走环境变量（`$env:FEISHU_APP_ID`）
- 错误处理分类（401=凭证过期、429=限流、5xx=服务端故障）
- 幂等性保证（推送前检查是否已存在）

**设计约束**：
- 密钥管理：环境变量 100%，零硬编码
- 错误处理：每种 HTTP 状态码有对应动作
- 速率限制：标注 API 限额和推荐请求间隔
- 重试策略：429→等 Retry-After；5xx→指数退避最多 3 次

**常见陷阱**：
- 凭证泄露到日志/Git 历史
- 不处理 API 限流导致批量操作中断
- 只写正常路径，不写异常路径

---

### P6：编排调度 Skill（Orchestration）— "决定谁做什么、按什么顺序做"

**定义**：以多个 Agent/Skill 的协调为操作对象。决策树路由，回退链。

**结构模板**：
```
触发层：按任务复杂度激活（多步骤/多模块/需要协调）
程序层：任务分解→Agent 分配→并行/串行决策→结果汇总→冲突解决
资源层：Agent 能力矩阵、路由决策树、冲突解决规则
```

**dmux-workflows 的核心模式**：
```
tmux 窗格 = Agent 实例
窗格间通信 = Agent 协作
主窗格 = 编排者（只调度，不执行）
```

**设计约束**：
- 必须有 Agent 能力矩阵（哪个 Agent 擅长什么）
- 必须有路由决策树（什么任务分配给哪个 Agent）
- 必须有冲突解决规则（两个 Agent 产出矛盾时谁裁决）
- 必须有超时/卡死处理（Agent 无响应时的降级方案）

**常见陷阱**：
- 过度编排 → 简单任务走了复杂调度
- Agent 职责重叠 → 两个 Agent 做同一件事
- 编排者自己做了执行工作 → 角色混乱

---

### P7：工具实用 Skill（Utility）— "一个命令解决一个问题"

**定义**：单用途、CLI 驱动、无状态。最大类别（~190 个）。

**结构模板**：
```
触发层：命令式触发词+输入格式
程序层：输入→处理→输出（≤3 步）
资源层：CLI 安装指南、命令参考
```

**agent-reach 的路由表模式**（17 平台零配置）：
```
| 用户意图 | 分类 | 详细文档 |
| 小红书/抖音/微博 | social | references/social.md |
| GitHub/代码 | dev | references/dev.md |
| YouTube/B站 | video | references/video.md |
```

**设计约束**：
- ≤3 步完成（超过→应拆分为独立 Skill）
- 输出格式固定（方便管道串联）
- 错误信息清晰（用户可直接按提示修复）
- Token 预算 ≤2KB（最大类别，必须克制）

**常见陷阱**：
- 功能蔓延：一个工具 Skill 装了 10 个不相关的功能
- 隐式依赖：不声明依赖的 CLI/API 工具
- 输出格式多变：下游无法可靠解析

---

### 原型选择决策树

```
需要操作其他 Skill？
  ├─ 是 → P1 元 Skill（含 G1-G6 自评 + 联动图）
  └─ 否 → 需要产出文字/媒体内容？
            ├─ 是 → P2 内容创作（含黑名单 + 平台适配 + 质量门禁）
            └─ 否 → 操作对象是代码/系统？
                      ├─ 是 → P3 工程开发（含证据门禁 + PASS/FAIL 双轨）
                      └─ 否 → 操作对象是外部信息？
                                ├─ 是 → P4 研究搜索（含来源分级 + 交叉验证）
                                └─ 否 → 操作对象是第三方平台？
                                          ├─ 是 → P5 平台集成（含凭据管理 + 错误处理）
                                          └─ 否 → 需要协调多个 Agent/Skill？
                                                    ├─ 是 → P6 编排调度（含路由决策树）
                                                    └─ 否 → P7 工具实用（≤3步, ≤2KB）
```

---

## 十二、Skill 优化实战案例（Before/After）

> 从 15 轮实战中选取 3 个代表性案例，展示优化前后的结构差异和分数变化。

### 案例 1：humanizer-zh — 从 28.5KB 膨胀到 8KB 精选

**问题诊断**：
- 原始大小 28.5KB，远超 10KB 上限
- 黑名单词 87 个，但 60% 为罕见词（token 浪费）
- description 只有一句话，无正反例、边界

**优化动作**（4 轮迭代）：
1. 拆分 references/：黑名单全文 → `references/blacklist.md`（18KB）
2. body 精简为标准模板：定义→诊断→改写→验证，每步 ≤500 字
3. description 重写：触发词 8 个 + 适用场景 5 个 + 不适用 3 个 + 正反例各 2 条
4. 追加 G1-G6 自评 + 失败兜底 + 边界声明

**Before→After**：
| 维度 | Before | After |
|------|--------|-------|
| 大小 | 28.5KB | 8.2KB (body) + 18KB (references) |
| D1 触发 | 3/10 | 9/10 |
| D3 可执行 | 5/10 | 8/10 |
| D6 兜底 | 3/10 | 7/10 |
| D7 边界 | 2/10 | 8/10 |
| **总分** | **48→C** | **78→A** |

---

### 案例 2：documents — 从 STUB(0.9KB) 到 R3 RICH(1.3KB)

**问题诊断**：
- 原始只有 4 行正文："创建Word文档。使用模板生成内容。"
- 无工作流、无验证、无错误处理
- description 含路径泄露（`C:\Users\...`）

**优化动作**（skill-forge 6步）：
1. 读原始 + reference → 提取：文档类型识别、模板加载、生成、格式化
2. 重写 description：触发词 7 个 + 不适用 3 场景 + 正反例各 2 条
3. 建 4 步工作流：识别类型→加载模板→生成内容→格式化输出
4. 加 G1-G6 自评 + 边界（不适用：飞书→feishu, Markdown→直接写）

**Before→After**：
| 维度 | Before | After |
|------|--------|-------|
| 大小 | 0.9KB | 1.3KB |
| D1 触发 | 2/10 | 9/10 |
| D3 可执行 | 1/10 | 7/10 |
| D4 验证 | 0/10 | 6/10 |
| D7 边界 | 0/10 | 8/10 |
| **总分** | **18→INC** | **72→B** |

---

### 案例 3：skill-forge 自身 — 从 8 次 R3 优化中孵化的元 Skill

**诞生过程**：
- 孵化来源：深度分析 8 个 dbs-* skill 的 R3 优化操作模式
- 发现规律：每次 R3 优化都是同一个 6 步流程（读→提取→写description→建Phase→加验证→G1-G6）
- 抽象为元 Skill：把"我做了 8 次的事"变成"一个可复用的 Skill"

**关键设计决策**：
1. 不直接修改原文件 → 先备份为 `.bak`
2. 按原始大小分 4 级处理策略（STUB<1KB / THIN 1-5KB / OK 5-10KB / RICH>10KB）
3. 与其他元 Skill 的联动图内置在 body 中

**孵化前后对比**：
| 指标 | 手工 R3 优化(8次平均) | skill-forge 自动化 |
|------|---------------------|-------------------|
| 耗时 | ~15min/个 | ~3min/个 |
| G1-G6 覆盖率 | 62% | 100% |
| description 正反例 | 2/8 完整 | 8/8 完整 |
| 遗漏边界声明 | 5/8 遗漏 | 0/8 遗漏 |

---

> 数据来源: C:\Users\董辉\.codex\skills\ (355 Skill 去重) + D:\_ai\skills\skill-review\ + 15 轮实战
> 跨域 Skill 采样: tdd-workflow(13.6KB) + security-review(12.9KB) + e2e-testing(17.4KB) + content-guard + compile-and-verify + mcp-builder(1.2KB)
> 原型采样: skill-forge(4.6KB) + viral-writer + humanizer-zh + deep-research + agent-reach(3.5KB) + dmux-workflows + feishu + x-api + crosspost + brand-voice
> 理论来源: SkillOpt (Microsoft) + ECC AGENTS.md + skill-creator/skill-review/skill-installer/skill-scout/skill-stocktake
> 理论来源: SkillOpt (Microsoft) + ECC AGENTS.md + skill-creator/skill-review/skill-installer/skill-scout/skill-stocktake
