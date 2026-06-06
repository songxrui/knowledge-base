---
name: knowledge-base
description: 个人知识库搭建与维护。触发：知识库、vault、zettel、PARA、笔记模板、weekly review、周回顾、同步飞书、推送GitHub、知识库协作、创建笔记、提炼想法、文件分类、知识库结构、笔记组织。反触发：纯代码仓库管理、项目管理工具配置、数据库设计。
---

# 个人知识库 Skill

**三端**：本地 md+git = AI大脑 / GitHub = 版本仓库 / 飞书 = 门面协作。

> 原则与反模式 → `references/principles.md`
> GitHub/飞书协作配置 → `references/collaboration.md`
> 文件分类推荐体系 → `references/file-classification.md`
> CodeWhale 技能同步 → `references/codewhale-sync.md`

---

## 证据与反幻觉规则（全局适用）


---

## 快速上手（首次使用）

```powershell
# 1. 设置Vault路径
$env:KNOWLEDGE_VAULT = "D:\KnowledgeBase"

# 2. 初始化目录结构
New-Item -ItemType Directory "$env:KNOWLEDGE_VAULT\00_Inbox","$env:KNOWLEDGE_VAULT\01_Projects","$env:KNOWLEDGE_VAULT\02_Areas","$env:KNOWLEDGE_VAULT\03_Resources","$env:KNOWLEDGE_VAULT\04_Archive","$env:KNOWLEDGE_VAULT\zettel" -Force

# 3. 初始化git
cd $env:KNOWLEDGE_VAULT; git init; git remote add origin https://github.com/<your-username>/knowledge-base.git

# 4. 创建第一份笔记
@"
---
title: 我的第一条原子笔记
tags: [seedling] | created: $(Get-Date -Format 'yyyy-MM-dd') | status: seedling | source: 个人思考
---
## 核心结论
知识库的价值 = 被检索次数 × 被复用次数 × 改变了行动

## 适用边界
适用于任何需要长期积累和检索的个人知识领域

## 一个行动实验
本周开始，每条新想法都先写进00_Inbox，周末统一提炼

## 关联
## 证据
[来源: 个人经验] [置信度: 待验证]
"@ | Set-Content -Path "$env:KNOWLEDGE_VAULT\zettel\知识库的价值公式.md" -Encoding UTF8

# 5. 首次提交
cd $env:KNOWLEDGE_VAULT; git add -A; git commit -m "init: knowledge vault setup"
```

**验证**：`Get-ChildItem $env:KNOWLEDGE_VAULT -Directory` 显6目录+.git，`git log --oneline` 有1个commit。

---
**所有笔记/内容产出必须遵守**：

1. **来源标注**：每条事实/观点标注出处。格式：`[来源: <工具/书籍/URL/对话>]`
2. **置信度标记**：不确定内容标注 `[推断]` `[待验证]` `[个人经验]`
3. **禁止编造**：不得伪造书籍名、URL、数据、引用。无来源则标注 `[来源缺失]`
4. **引用完整性**：摘录他人内容需保留原始上下文，不得断章取义
5. **核查提醒**：涉及医学/法律/投资/统计数据，自动附加 `[⚠ 核查: 请核对原始来源]`

**验证**：`rg "\[来源[:：]" zettel/` 检查新笔记是否有来源标注。

---

## 文件分类推荐体系

> 详细分类指南 → `references/file-classification.md`

**快速决策流程**：
1. 这篇内容 **能直接变成一个行动/项目吗？** → `01_Projects/`
2. 这篇内容 **属于持续维护的领域吗？**（健康/财务/关系等）→ `02_Areas/`
3. 这篇内容 **是参考资料/外部素材吗？** → `03_Resources/`
4. 这篇内容 **是原子化思考/概念吗？** → `zettel/`
5. 这篇内容 **已完成/不再活跃吗？** → `04_Archive/`

**子分类维度**（`references/file-classification.md` 详述）：
| 维度 | 示例 | 适用场景 |
|------|------|---------|
| 按领域 | health/cognition/wealth/productivity | 个人知识体系 |
| 按媒介 | articles/books/videos/podcasts | 来源管理 |
| 按项目 | project-a/project-b | 多项目并行 |
| 按状态 | draft/seedling/evergreen/published | 内容成熟度 |
| 按受众 | internal/public/client | 协作场景 |

---

## 操作一：初始化 Vault

```powershell
$vault = "$env:KNOWLEDGE_VAULT"  # 默认 D:\KnowledgeBase；首次设置: $env:KNOWLEDGE_VAULT = "D:\KnowledgeBase"
if (-not $vault) { $vault = "D:\KnowledgeBase" }
New-Item -ItemType Directory "$vault\00_Inbox","$vault\01_Projects","$vault\02_Areas","$vault\03_Resources","$vault\04_Archive","$vault\zettel" -Force
cd $vault; git init
```

创建 `.gitignore` + `README.md`。参考 `references/file-classification.md` 创建子目录。

**验证**：`Get-ChildItem $vault -Directory` 显6目录+.git。

---

## 操作二：创建原子笔记

1. 确认核心结论（陈述句，标题即结论）
2. 使用 `assets/note-template.md`，填 title/tags/status/source/四段式
3. 按 `references/file-classification.md` 决定存放位置：概念性 → `zettel/`；领域知识 → `02_Areas/<domain>/`；项目产出 → `01_Projects/<project>/`
4. 加1-2条 `[[双链]]`
5. 标注来源和置信度（见证据规则）

**模板**：
```markdown
---
title: 标题即结论
tags: [] | created: YYYY-MM-DD | status: seedling | source:
---
## 核心结论
## 适用边界
## 一个行动实验
## 关联 [[]]
## 证据
[来源: <具体出处>] [置信度: 已验证/推断/待验证]
```

**验证**：标题陈述句？可独立链接？有双链？有来源标注？

---

## 操作三：Weekly Review

```powershell
scripts/weekly-review.ps1 -VaultPath $env:KNOWLEDGE_VAULT
```

手动流程：清空Inbox → 加双链 → 升级seedling → `git commit -m "weekly: YYYY-MM-DD"`

**验证**：Inbox空？新zettel有双链？git已提交？

---

## 操作四：AI 调用

| 平台 | 方式 | 命令/操作 |
|------|------|----------|
| Codex CLI | 直接在对话中引用vault文件 | `@KnowledgeBase` 或直接提及知识库相关任务 |
| CodeWhale | 触发 knowledge-base skill | 自动加载 SKILL.md |
| Cursor | @KnowledgeBase 提问 | 需配置 Cursor 索引 `$env:KNOWLEDGE_VAULT` |
| MCP | 文件系统MCP读取 | 配置 `filesystem` MCP server 指向 vault |
| 通用 | `rg` 全文检索 | `rg "关键词" $env:KNOWLEDGE_VAULT/zettel/` |

**验证**：任一方式能检索到 ≥1 条 zettel 笔记。

---

## 操作五：协作同步

### GitHub
```powershell
cd $env:KNOWLEDGE_VAULT
git push
```
需 `$env:GH_TOKEN`（`repo` scope）或 `gh auth login`。

**远程仓库配置**：`git remote add origin https://github.com/<your-username>/knowledge-base.git`
（首次需按 `references/collaboration.md` 配置）

### 飞书（lark-cli）
```bash
lark-cli wiki +node-list --space-id <YOUR_SPACE_ID> --as user
lark-cli wiki +node-create --space-id <YOUR_SPACE_ID> --title "标题" --as user
```

**发布规范**（参考 `assets/feishu-template.md`）：
- 标题：`[领域标签] 核心结论（≤30字）`
- 正文：精简版笔记，含来源链接
- 格式：标题+摘要+核心内容+关联链接

**同步策略**：本地写 → AI润色 → `lark-cli wiki +node-create` 发布精选。不自动全量同步。

### CodeWhale 技能同步
参考 `references/codewhale-sync.md`：
- CodeWhale skills 位于 `~/.codewhale/skills/`
- 本 skill 修改后同步：`robocopy ~/.codex/skills/knowledge-base/ ~/.codewhale/skills/knowledge-base/ /MIR`
- 从 CodeWhale 引入新技能：先评测，后复制到 `~/.codex/skills/`

**验证**：`gh auth status` / `lark-cli wiki +node-list` / `Get-ChildItem ~/.codewhale/skills/knowledge-base/`

---

## 故障排查

| 症状 | 排查 |
|------|------|
| `git push` 403 | `gh auth status`，token需repo scope |
| `lark-cli` 认证失败 | `lark-cli doctor` → `lark-cli auth login` |
| Inbox堆积 | 7天未处理→直接删或归档，不纠结 |
| zettel孤岛 | `rg "^## 关联" zettel/` 检查空链接 |
| 笔记无来源标注 | `rg "\[来源[:：]" zettel/` 检查合规 |
| CodeWhale skill未同步 | `Get-ChildItem ~/.codewhale/skills/knowledge-base/` 确认存在 |

---

## 凭据

| 组件 | 方式 | 环境变量 |
|------|------|---------|
| weekly-review.ps1 | 本地，无需凭据 | — |
| GitHub | `gh auth login` | `$env:GH_TOKEN` |
| 飞书 | `lark-cli auth login`（OAuth） | — |
| vault路径 | — | `$env:KNOWLEDGE_VAULT` |

---

## 文件索引

| 需要 | 打开 |
|------|------|
| 原则、反模式、工具对照 | `references/principles.md` |
| GitHub/飞书链接、CLI细节 | `references/collaboration.md` |
| 文件分类推荐体系（完整） | `references/file-classification.md` |
| CodeWhale技能同步工作流 | `references/codewhale-sync.md` |
| 笔记模板 | `assets/note-template.md` |
| 飞书发布格式模板 | `assets/feishu-template.md` |
| 周回顾脚本 | `scripts/weekly-review.ps1` |

---

## 边界

**做**：本地PARA+Zettelkasten管理、笔记创建/检索/提炼、GitHub版本同步、飞书精选发布、CodeWhale跨平台同步。

**不做**：全量自动化同步、Obsidian插件配置、Notion API集成、飞书自动全量推送。

**失败模式**：

| 失败 | 兜底 |
|------|------|
| git push被拒 | 检查token scope，`gh auth refresh -s repo` |
| lark-cli认证过期 | `lark-cli auth login` 重新OAuth |
| Inbox堆积>7天 | 直接删除或批量归档，不逐条处理 |
| zettel无来源标注 | 运行 `rg "\[来源" zettel/` 审计，补充标注 |
| vault路径未设置 | 默认使用 `D:\KnowledgeBase`，提示设置 `$env:KNOWLEDGE_VAULT` |

---

## 质量保证

**创建/修改笔记前可用评测 skill 校验**：

- **`compile-and-verify`** — 任务编译+质检。写重要笔记前先编译目标变量，写完对照验收
- **`evaluator-optimizer`** — Generate→Evaluate→Revise→Verify 循环。需要反复打磨的内容走此流程
- **`skill-review`** — 元Skill评测架构师。定期审计 knowledge-base skill 本身的健康度（路径：`D:\_ai\skills\skill-review\`）
- **`skill-stocktake`** — 定期库存盘点，检查所有skill质量

**触发反例（何时不用此 skill）**：
- 纯代码仓库管理（用 github-ops）
- Notion/飞书做为主要存储后端（本skill以本地md为主）
- 项目管理系统搭建（用 project-flow-ops）
- 数据库设计（用 database-migrations）
