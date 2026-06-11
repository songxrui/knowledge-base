# ECC for Codex CLI

This supplements the root `AGENTS.md` with Codex-specific guidance.



## DeepSeek v4 Pro 优化配置（Codex CLI 专属）

### DS 能力画像
| 维度 | DS v4 Pro 表现 | 补偿策略 |
|------|---------------|---------|
| 指令遵循 | 复杂多步指令可能漏步 | 每步编号 + 完成后确认 |
| 长上下文 | 64K+后精度下降 | headroom 压缩 + strategic-compact 裁剪 |
| 工具调用 | 偶有参数格式错误 | compile-and-verify 事后校验 |
| 推理深度 | 中等复杂度可靠,极高复杂度需分解 | 多agent分解 + sequential-thinking |
| 结构化输出 | JSON/Markdown 格式可靠 | 提供schema模板 |
| 幻觉倾向 | 不确定时可能猜测 | 强制标注"推断/待核实" + exa/deep-research 库外验证 |
| 代码生成 | 函数级可靠,多文件项目需分步 | 单文件→测试→下一文件 |

### DS 模型推荐（替代 GPT 5.4 表格）
| Task Type | DS策略 | 补偿工具 |
|-----------|--------|---------|
| 单文件编辑/测试 | 直接执行 | compile-and-verify 事后校验 |
| 多文件重构 | 分解为单文件步骤,每步验证 | diff-reviewer + content-guard |
| 复杂架构设计 | sequential-thinking 先推理→再编码 | mcp__sequential_thinking |
| 长内容创作 | strategic-compact 裁剪上下文 | dbs-content + humanizer-zh |
| 研究/搜索 | exa-search + deep-research 先行 | 标注来源等级 |
| 安全审查 | 分模块审查,每模块独立报告 | security-review skill |
| 批量操作(≥3文件) | 每文件独立commit,禁止批量 | content-guard 6门禁 |

### DS 指令风格规范
1. **显式 > 隐式**: 每一步写明"做什么→用什么工具→输出什么→如何验证"
2. **编号 > 段落**: 多步任务用编号列表,不用连续段落
3. **确认 > 假设**: 工具输出必须验证后使用,不确定时标注[推断]
4. **分解 > 合并**: 复杂任务拆为≤3步的子任务,用多agent并行
5. **先搜 > 先猜**: 事实性问题先用 exa/context7 搜索,不要依赖训练数据

### DS 已知弱点自动补偿
- 遇到"可能/大概/也许"等不确定性表达 → 自动触发 exa-search 核验
- 修改≥3个文件 → 自动触发 content-guard 6门禁
- 产出最终交付物 → 自动触发 compile-and-verify 质检
- 工具调用失败1次 → 重试时更换参数格式(JSON→form或反)
- 上下文超过50%token预算 → 触发 strategic-compact 裁剪


## Skills Discovery

Skills are auto-loaded from `.agents/skills/`. Each skill contains:
- `SKILL.md` 鈥?Detailed instructions and workflow
- `agents/openai.yaml` 鈥?Codex interface metadata

Available skills:
- tdd-workflow 鈥?Test-driven development with 80%+ coverage
- security-review 鈥?Comprehensive security checklist
- coding-standards 鈥?Universal coding standards
- compile-and-verify — Task compiler + delivery verifier. Compiles fuzzy input into quantifiable goals, then validates output.
- frontend-patterns 鈥?React/Next.js patterns
- frontend-slides 鈥?Viewport-safe HTML presentations and PPTX-to-web conversion
- article-writing 鈥?Long-form writing from notes and voice references
- content-engine 鈥?Platform-native social content and repurposing
- market-research 鈥?Source-attributed market and competitor research
- investor-materials 鈥?Decks, memos, models, and one-pagers
- investor-outreach 鈥?Personalized investor outreach and follow-ups
- backend-patterns 鈥?API design, database, caching
- e2e-testing 鈥?Playwright E2E tests
- eval-harness 鈥?Eval-driven development
- strategic-compact 鈥?Context management
- api-design 鈥?REST API design patterns
- verification-loop 鈥?Build, test, lint, typecheck, security
- deep-research 鈥?Multi-source research with firecrawl and exa MCPs
- exa-search 鈥?Neural search via Exa MCP for web, code, and companies
- claude-api 鈥?Anthropic Claude API patterns and SDKs
- x-api 鈥?X/Twitter API integration for posting, threads, and analytics
- crosspost 鈥?Multi-platform content distribution
- fal-ai-media 鈥?AI image/video/audio generation via fal.ai
- dmux-workflows 鈥?Multi-agent orchestration with dmux
- content-guard — Content editing anti-regression gate. Mandatory for batch file edits (≥2 files). Six hard gates: Delta verification, Baseline lock, Sample diff, Keyword scan, Loop counter, Environment check.

## MCP Servers

Treat the project-local `.codex/config.toml` as the default Codex baseline for ECC. The current ECC baseline enables GitHub, Context7, Exa, Memory, Playwright, and Sequential Thinking; add heavier extras in `~/.codex/config.toml` only when a task actually needs them.

ECC's canonical Codex section name is `[mcp_servers.context7]`. The launcher package remains `@upstash/context7-mcp`; only the TOML section name is normalized for consistency with `codex mcp list` and the reference config.

### Automatic config.toml merging

The sync script (`scripts/sync-ecc-to-codex.sh`) uses a Node-based TOML parser to safely merge ECC MCP servers into `~/.codex/config.toml`:

- **Add-only by default** 鈥?missing ECC servers are appended; existing servers are never modified or removed.
- **7 managed servers** 鈥?Supabase, Playwright, Context7, Exa, GitHub, Memory, Sequential Thinking.
- **Canonical naming** 鈥?ECC manages Context7 as `[mcp_servers.context7]`; legacy `[mcp_servers.context7-mcp]` entries are treated as aliases during updates.
- **Package-manager aware** 鈥?uses the project's configured package manager (npm/pnpm/yarn/bun) instead of hardcoding `pnpm`.
- **Drift warnings** 鈥?if an existing server's config differs from the ECC recommendation, the script logs a warning.
- **`--update-mcp`** 鈥?explicitly replaces all ECC-managed servers with the latest recommended config (safely removes subtables like `[mcp_servers.supabase.env]`).
- **User config is always preserved** 鈥?custom servers, args, env vars, and credentials outside ECC-managed sections are never touched.

## External Action Boundaries

Treat networked tools as read-only by default. Search, inspect, and draft freely within the user's requested scope, but require explicit user approval before posting, publishing, pushing, merging, opening paid jobs, dispatching remote agents, changing third-party resources, or modifying credentials.

When approval is ambiguous, produce a local plan or draft artifact instead of taking the external action. Preserve user config and private state unless the user specifically asks for a scoped change.

## Multi-Agent Support

Codex now supports multi-agent workflows behind the experimental `features.multi_agent` flag.

- Enable it in `.codex/config.toml` with `[features] multi_agent = true`
- Define project-local roles under `[agents.<name>]`
- Point each role at a TOML layer under `.codex/agents/`
- Use `/agent` inside Codex CLI to inspect and steer child agents

Sample role configs in this repo:
- `.codex/agents/explorer.toml` 鈥?read-only evidence gathering
- `.codex/agents/reviewer.toml` 鈥?correctness/security review
- `.codex/agents/docs-researcher.toml` 鈥?API and release-note verification

## Key Differences from Claude Code

| Feature | Claude Code | Codex CLI |
|---------|------------|-----------|
| Hooks | 8+ event types | Not yet supported |
| Context file | CLAUDE.md + AGENTS.md | AGENTS.md only |
| Skills | Skills loaded via plugin | `.agents/skills/` directory |
| Commands | `/slash` commands | Instruction-based |
| Agents | Subagent Task tool | Multi-agent via `/agent` and `[agents.<name>]` roles |
| Security | Hook-based enforcement | Instruction + sandbox |
| MCP | Full support | Supported via `config.toml` and `codex mcp add` |

## Security Without Hooks

Since Codex lacks hooks, security enforcement is instruction-based:
1. Always validate inputs at system boundaries
2. Never hardcode secrets 鈥?use environment variables
3. Run `npm audit` / `pip audit` before committing
4. Review `git diff` before every push
5. Use `sandbox_mode = "workspace-write"` in config



## GitHub 收藏仓库管理


技能: github-starred-manager (在 ~/.codex/skills/github-starred-manager/)


- 列出收藏: "列出我收藏的仓库"

- 下载收藏: "把我的收藏仓库下载下来"

- 搜索收藏: "搜索收藏中是否有 XXX"

- 更新本地: "更新我的收藏仓库"


触发时我会自动读取 token 调用 GitHub API，无需安装额外 CLI 工具。


## D:\github - 收藏仓库一览

全部 13 个仓库已下载并配置启动说明。

**分类速查:**

- ai-agent (4): guizang-social-card-skill, ian-xiaohei-illustrations, anysearch-skill, compound-engineering-plugin
- python-tools (3): social-auto-upload, Scrapling, markitdown
- web-app (4): impeccable, tab-out, floral-notepaper, OmniRoute
- game (1): Pixelorama
- tutorial (1): hello-algo

**启动示例:**

cd D:\github\python-tools\Scrapling && pip install -e .
cd D:\github\web-app\floral-notepaper && npm install && npm run dev
cd D:\github\tutorial\hello-algo && docker compose up

详细说明见 D:\github\README.md

## 创作者作品采集 — 加速方案

脚本: D:\github\python-tools\D4Vinci__Scrapling\scripts\crawler_v2.py

### 加速策略
| 方案 | 加速比 | 原理 |
|------|--------|------|
| 流式音频 | 1.3x | ffmpeg pipe → whisper，0磁盘写入 |
| VAD过滤 | 1.3x | 跳过静音段，只转写有效语音 |
| 多核并行 | 1.8x | 12核CPU跑2路whisper |
| B站字幕API | ∞ | 直接获取已有字幕，零成本 |
| **联合加速** | **~6x** | 19视频 10min → 2min |

### 用法
`powershell
# B站 (直接用字幕, 秒出)
python crawler_v2.py bilibili <mid>

# 抖音 (流式whisper, 约16s/个)
python crawler_v2.py douyin <sec_user_id>
python crawler_v2.py douyin <sec_user_id> --model tiny --workers 3
`

### 已验证案例
- 抖音: 林杉43岁, 19个视频, 10.5分钟(旧) → 约3分钟(新)
- 输出: D:\github\output\{平台}\{博主名}\{id}.txt
## 执行前安全检查

多文件修改、配置变更、skill 更新前，依次执行：

1. **preflight-reviewer** — 计划边界 + 命令权限统一审查（替代原 plan-reviewer + permission-reviewer）
2. **content-guard** — 内容编辑防退化门禁（≥2文件批量修改时必须激活：6门禁含Delta验证/基线锁定/抽样diff/关键词扫描/循环计数器/环境自检）
3. **diff-reviewer** — 修改后、提交前 diff 级审查

规则：BLOCKER 立即阻断；WARNING 批量输出，不阻塞流程。

## Tolaria 知识库桌面应用

**应用路径**: `C:\Users\董辉\AppData\Local\Tolaria\tolaria.exe`
**源码**: `D:\github\tolaria\`
**Agent文档**: `D:\github\tolaria\src-tauri\resources\agent-docs\`

### 快速启动
```powershell
Start-Process "C:\Users\董辉\AppData\Local\Tolaria\tolaria.exe"
```

### 推荐 Vault 配置
- 主知识库: `D:\KnowledgeBase\` (已有 git)
- 入门教程: `D:\tolaria-getting-started\`
- 内容产出: `D:\KnowledgeBase\_alchemist\output\`

### Agent 使用方式
当用户提到 Tolaria 相关问题时，先读取 `D:\github\tolaria\src-tauri\resources\agent-docs\all.md` 获取产品文档。

### Tolaria 核心原则
- **Files-first**: 所有笔记为纯 Markdown 文件，可移植
- **Git-first**: 每个 vault 是独立 git 仓库
- **Offline-first**: 零账户、零订阅、零云依赖
- **Types as lenses**: 类型是导航辅助，非强制 schema
- **AI-first**: 支持 Claude Code / Codex CLI / Gemini CLI
- **Keyboard-first**: 为键盘操作设计

### 快捷键速查
| 快捷键 | 功能 |
|--------|------|
| Ctrl+K | 命令面板 |
| Ctrl+O | 快速打开笔记 |
| Ctrl+N | 新建笔记 |
| Ctrl+Shift+F | 全局搜索 |
## Headroom �� LLM ������ѹ�� (60-95% token ��ʡ)

**CLI**: `headroom` (v0.20.15)
**·��**: `D:\github\headroom\`
**npm**: `headroom-ai@0.22.4` (JavaScript SDK)

### Codex ���� (3�ַ�ʽ)

**��ʽ1: MCP (�Ƽ�,������)**
```toml
[mcp_servers.headroom]
command = "headroom"
args = ["mcp", "serve"]
```
Codex ������Զ����� `headroom_compress` / `headroom_retrieve` / `headroom_stats` ���ߡ�

**��ʽ2: Proxy ����**
```powershell
headroom proxy --port 8787
# ����ն�:
$env:OPENAI_BASE_URL = "http://localhost:8787/v1"
codex
```

**��ʽ3: Wrap ģʽ**
```powershell
headroom wrap codex
```

### ��������
| ���� | ���� |
|------|------|
| `headroom proxy` | ���ѹ������ (�˿�8787) |
| `headroom mcp install` | ע�� MCP ���� |
| `headroom learn` | �ھ�ʧ�ܻỰ,д�� AGENTS.md |
| `headroom memory list` | �鿴�� agent ���� |



## DS 工作流模式（GPT-5.5 能力补偿）

### 模式1：分解-执行-验证（替代端到端生成）
DS不擅长一次性产出复杂交付物。替代方案：
1. sequential-thinking 推理 → 产出分步计划
2. 每一步独立执行 → 单步验证通过再进入下一步
3. compile-and-verify 终验 → 对照计划逐项检查
禁止：跳过中间验证直接产出最终结果。

### 模式2：工具优先（替代自由生成）
DS自由生成容易空泛。强制工具链：
- 事实任务：exa-search → 标注来源 → 基于来源写作
- 代码任务：context7查文档 → 生成 → compile-and-verify校验
- 内容任务：dbs-content诊断 → dbs-hook优化 → humanizer-zh去味 → quality-gatekeeper门禁
- 研究任务：deep-research搜索 → 提取证据 → 标注等级

### 模式3：多Agent分解（替代单线程深度推理）
DS在极高复杂度任务上推理深度不足：
- 复杂分析 → spawn explorer(只读证据) + reviewer(批判检查)
- 批量操作 → spawn worker × N(并行处理不同文件)
- 研究任务 → spawn docs_researcher(库外验证)
要求：agent返回后必须审查其输出,禁止盲信子agent结果。

### 模式4：渐进式纠错（替代一次性完美）
DS工具调用偶有失败。策略：
1. 失败→重试(最多3次,每次改变参数格式)
2. 3次仍失败→更换工具或skill
3. 仍无法解决→标注[阻塞]报告用户,不伪造结果

### 模式5：上下文预算管理
DS在长上下文中精度下降。headroom自动压缩 + 手动触发strategic-compact:
- 对话超过30轮 → 触发strategic-compact压缩历史
- 单次工具输出超过5000字符 → 触发headroom_compress
- 文件读取后立即总结关键点,不保留原始全文