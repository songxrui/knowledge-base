# DeepSeek v4 Pro → Codex 能力优化基线

**日期**: 2026-06-11 | **模型**: deepseek-v4-pro (via CodexPlusPlus proxy @ 127.0.0.1:57321)

## 优化前状态

| 维度 | 优化前 | 问题 |
|------|--------|------|
| AGENTS.md模型表 | 全部推荐 GPT 5.4 | DS无专属配置 |
| retry次数 | 1次 | DS工具调用偶发失败无容错 |
| multi_agent | 未启用 | 复杂任务无法分解 |
| persistent_instructions | 通用 | 无DS专属行为规范 |
| skill触发示例 | 5/15有正反例 | DS误触发/漏触发风险高 |
| DS工作流模式 | 无 | 按GPT-5.5模式运行,不匹配 |

## 优化后状态

### Layer 1: AGENTS.md — DS能力画像 + 工作流模式
- ✅ DS v4 Pro 能力画像表（7维度+补偿策略）
- ✅ DS 模型推荐表（7种任务类型+对应工具链）
- ✅ DS 指令风格规范（5条: 显式/编号/确认/分解/先搜）
- ✅ DS 已知弱点自动补偿（5种场景自动触发补偿机制）
- ✅ DS 工作流模式（5种: 分解-验证/工具优先/多Agent/渐进纠错/上下文预算）

### Layer 2: config.toml — 基础设施
- ✅ retry: 1→3次
- ✅ multi_agent: true
- ✅ persistent_instructions: DS v4 Pro专属行为规范
- ✅ headroom MCP: 已配置（60-95% token节省）

### Layer 3: Skill触发精准度
- ✅ 14/14 核心skill补充正反例
- ✅ strategic-compact (codex/skills) 补充触发示例

### Layer 4: 工具链完整性
| MCP | 状态 | DS补偿作用 |
|-----|------|-----------|
| headroom | ✅ | 压缩上下文,补偿DS长文本退化 |
| exa | ✅ | 库外搜索,补偿DS幻觉 |
| context7 | ✅ | 文档查询,补偿DS训练数据过时 |
| sequential-thinking | ✅ | 结构化推理,补偿DS深度推理 |
| firecrawl | ✅ | 网页抓取,扩大信源 |
| token-optimizer | ✅ | token优化 |
| codescene | ✅ | 代码质量分析 |

## 效果度量方法

1. **任务完成率**: 复杂多步任务是否成功执行全部步骤
2. **工具调用成功率**: 工具调用成功率(%)
3. **自纠率**: DS是否能识别并修正自己的错误
4. **skill触发精准度**: 该触发时触发 / 不该触发时不触发
5. **上下文利用率**: headroom压缩前后token数对比

## 已知限制

- 无法改变模型参数（DS权重冻结）
- 优化通过AGENTS.md/config.toml/skills的"外部状态"实现
- 实际效果需运行真实任务验证

### Layer 6: Agent 角色配置 (新增)
- ✅ explorer: model→DSv4Pro, DS专属指令(编号步骤/文件行号/标注推断)
- ✅ reviewer: 保留GPT-5.4(高推理需求), 添加DS回退指令
- ✅ docs-researcher: model→DSv4Pro, search-first强制(context7→exa→标注来源)

### Layer 7: Hook 系统 (新增)
- ✅ DS SessionInit hook: 每次会话启动自动验证DS配置完整性(5项检查)
- ✅ 自动注入 CODEX_DS_MODE=1, CODEX_DS_VERIFY=true
- ✅ 日志: ~/.codex/ds-session-check.log

### 模型可用性
- ✅ CodexPlusPlus proxy @ 127.0.0.1:57321 正常运行
- ✅ 可用模型: deepseek-v4-pro, deepseek-v4-flash

### 总变更清单
| 文件 | 变更 | 类型 |
|------|------|------|
| ~/.codex/AGENTS.md | +5个DS专属区块 | 指令层 |
| ~/.codex/config.toml | retry/agent/instructions | 基础设施 |
| .agents/skills/*/SKILL.md | 14个skill +正反例 | 触发层 |
| .codex/skills/strategic-compact/SKILL.md | +触发示例 | 触发层 |
| .codex/agents/{explorer,reviewer,docs-researcher}.toml | DS专属指令 | Agent层 |
| .codex/hooks.json | +DS session-init | 自动化 |
| .codex/ds-session-init.js | 新建 | 自动化 |