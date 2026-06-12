# Skill 全量索引 — 2026-06-12 (更新版)

> 本索引对接 CodeWhale 与 ECC 技能体系，用于 `load_skill` 快速发现

---

## 技能来源路径

| 来源 | 数量 | 路径 |
|------|------|------|
| ECC 主技能库 | 232 skills | `D:\aaa\everything-claude-code\skills\` |
| ECC curated (Codex) | 33 skills | `D:\aaa\everything-claude-code\.agents\skills\` |
| 用户级 skills | 263+ skills | `C:\Users\董辉\.agents\skills\` |
| CodeWhale 原生 | 200+ skills | `C:\Users\董辉\.codewhale\skills\` |

---

## 按类别索引

### 内容创作
- `content-alchemist` — 统一内容炼金管线
- `khazix-writer` — AI 写作
- `viral-writer` — 爆文写作
- `baoyu-article-illustrator` — 文章配图
- `article-writing` — 长文写作 (ECC)
- `content-engine` — 平台原生社媒内容 (ECC)

### 内容发布
- `baoyu-post-to-wechat` — 发布到公众号
- `baoyu-post-to-weibo` — 发布到微博
- `baoyu-post-to-x` — 发布到 X/Twitter
- `crosspost` — 多平台分发 (ECC)
- `feishu` — 飞书集成

### 内容质检
- `compile-and-verify` — 编译与验证
- `content-auditor` — 内容审计
- `content-pipeline-auditor` — 流水线审计
- `humanizer-zh` — 中文去 AI 味
- `content-truth-lock` — 事实核查
- `dbs-ai-check` — AI 特征检测

### 商业诊断 (dbs)
- `dbs` — 商业工具箱主入口
- `dbs-action` — 执行力诊断
- `dbs-content` — 内容创作诊断
- `dbs-decision` — 个人决策系统
- `dbs-deconstruct` — 概念拆解
- `dbs-diagnosis` — 商业模式诊断
- `dbs-goal` — 目标审计
- `dbs-benchmark` — 对标分析
- `dbs-learning` — 交互式学习

### 技术开发
- `tdd-workflow` — TDD 工作流 (ECC)
- `coding-standards` — 编码标准 (ECC)
- `backend-patterns` — 后端模式 (ECC)
- `frontend-patterns` — 前端模式 (ECC)
- `api-design` — API 设计 (ECC)
- `verification-loop` — 构建->测试->安全 (ECC)
- `e2e-testing` — E2E 测试 (ECC)

### 安全
- `security-review` — 安全审查 (ECC)
- `security-scan` — 安全扫描 (ECC)

### AI/ML
- `deep-research` — 多源研究 (ECC)
- `exa-search` — Exa 神经搜索 (ECC)
- `fal-ai-media` — AI 媒体生成 (ECC)
- `x-api` — X/Twitter API (ECC)

### 效率工具
- `strategic-compact` — 上下文压缩 (ECC)
- `eval-harness` — Eval 驱动开发 (ECC)
- `context-compressor-r3` — R3上下文压缩
- `content-diffusion-engine-r1` — 内容扩散引擎
- `dbs-agent-mesh-r1` — 多 Skill 编排

---

## ECC Agent 角色

| Agent | Model | 用途 |
|-------|-------|------|
| explorer | deepseek-v4-flash | 只读代码探索 |
| reviewer | deepseek-v4-flash | 代码审查 |
| docs-researcher | deepseek-v4-flash | 文档验证 |

---

> 提示: 使用 `load_skill` 加载任一技能 | 运行 `ecc doctor` 查看 ECC 技能健康状态
