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

---

## Skill 元数据标准化状态

| 指标 | 数据 | 状态 |
|------|------|------|
| 用户级技能总数 | 89 | ✅ |
| 有 `name:` 字段 | 88/88（其中44个已统一修复） | ✅ |
| 有 `description:` 字段 | 88/88 | ✅ |
| 有 `version:` 字段 | 88/88（44个本次补全） | ✅ |
| 标准格式 | `name` + `description` + `version` + `trigger` | ✅ |

---

## 反向索引：KB 内容所用 Skill（used_in）

> **当前状态**: 知识库内容与 skill 之间尚无关联标注。
> **本轮新增**: `_content-system/MAPPING_INDEX.md` 建立了内容结构化系统 ↔ 01_Projects 的映射。
> **约定（新内容）**: 每篇新内容末尾标注 skill 链：
> ```markdown
> ---
> skill: weread-skills → dbs-content-system → khazix-writer → humanizer-zh
> ```

### 内容 ↔ Skill 映射（逐步完善）

| Skill | 用于产出了哪些 KB 内容 | 状态 |
|-------|----------------------|------|
| think-then-act | KB 结构清理（本会话） | ✅ 已记录 |
| (更多待标注...) | | ⏳ |

---

## 知识库索引交叉引用

| 索引文件 | 作用 | 关联 |
|---------|------|------|
| `KNOWLEDGE_MAP.md` | 知识库主地图（目录/质量/管线） | ← 本索引 |
| `SKILL_INDEX.md` | **你在这里** — 全量技能索引 | → KNOWLEDGE_MAP |
| `_content-system/MAPPING_INDEX.md` | 内容结构化系统 ↔ PARA 映射 | ← NEW |
| `SKILL_INDEX.md` | 全量技能索引 | → load_skill |
| `HOME.md` | 仪表盘入口 | → KNOWLEDGE_MAP |

---

> 提示: 使用 `load_skill` 加载任一技能 | 运行 `ecc doctor` 查看 ECC 技能健康状态 | 新内容请标注 `skill:` 字段以逐步建立反向索引
