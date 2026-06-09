---
name: knowledge-base
description: "个人知识库搭建与维护+内容创作全管线。PARA+Zettelkasten+AI-native+飞书门面。dbs方法论内置：选题压缩(3核心选题)、内容单元化(QST/CON/OPI/CAS/SOL)、R系列重构、质量门禁链。触发：知识库、vault、zettel、PARA、笔记模板、weekly review、周回顾、同步飞书、推送GitHub、知识库协作、创建笔记、提炼想法、文件分类、知识库结构、笔记组织、写文章、公众号长文、内容优化、选题压缩。反触发：纯代码仓库管理→github-ops、项目管理工具配置、数据库设计。"
version: "4.0.0 | 2026-06-08 | dbs-content-system+3选题+R系列+新skill集成"
---

# 知识库 Skill v4 — dbs方法论内置版

**三端**：本地md+git=AI大脑 / GitHub=版本仓库 / 飞书=门面协作。

> 原则与反模式 → `references/principles.md`
> GitHub/飞书协作配置 → `references/collaboration.md`
> 文件分类推荐体系 → `references/file-classification.md`
> CodeWhale技能同步 → `references/codewhale-sync.md`

---

## 证据与反幻觉规则（全局适用，红线）

1. **来源标注**：每条事实/观点标注出处。`[来源: <工具/书籍/URL>]`
2. **置信度标记**：不确定标注 `[推断]` `[待验证]` `[个人经验]`
3. **禁止编造**：不得伪造书名、URL、数据、引用。无来源标注 `[来源缺失]`
4. **平台幻觉防御**：提及任何平台前先查 `选题管理/00-选题记录.md` 和 `media/` 目录确认真实平台。**绝对禁止编造平台名**（如"即刻"——仅当选题记录明确出现时才可用）
5. **核查提醒**：医学/法律/投资/统计 → `[⚠ 核查: 请核对原始来源]`

---

## dbs内容方法论（内置路由+质量标准）

### dbs-orchestrator 路由决策树
遇到内容任务时，按以下顺序判定用哪个dbs skill：

```
任务类型
├─ 单篇改写/优化 → dbs-content (5哲学诊断+结构+可执行建议)
├─ 批量结构化旧稿 → dbs-content-system (QST/CON/OPI/CAS/SOL单元化+5层工程)
├─ 概念拆解 → dbs-deconstruct (维特根斯坦五层拆解+奥派校标)
├─ 慢方法审计 → dbs-slowisfast (快方法陷阱识别+放弃条件)
├─ 对标分析 → dbs-benchmark (五重过滤+合成公式)
├─ 开头/hook优化 → dbs-hook (3类开头公式：数据冲击/反共识/痛点直击)
├─ 去AI味 → humanizer-zh (5指纹扫描+替换)
├─ 终检 → compile-and-verify (禁用词+证据密度+质量分)
└─ 元评测 → skill-review (路径:D:\_ai\skills\skill-review\)
```

### dbs-content 5哲学（内容质量门禁）
1. **文字洁癖是底线** — AI内容被限流不是AI的问题，是用AI的人对文字没有洁癖
2. **自媒体本质=精神控制** — 封面和标题的本质是认知劫持
3. **内容好坏=投入精力×对内容有正确理解** — 越新手越要推高单篇成本
4. **先有产品后有内容** — 不能把付款链接发出来让你成功付款=没有产品
5. **知识博主的工作只有两个** — ①把事情搞清楚 ②把事情说清楚

---

## 3核心选题框架（压缩自17主题）

所有内容产出必须归入以下3选题之一。db本人只有这3个选题。

### 选题1: 执行系统
**核心问题**: 意志力不可靠，系统如何替代意志力？
**子节点**: 环境暴政(0.3秒信号)/14天实验(荒谬最小化)/P0单一主线(瓶颈变量)/健康底盘(身体唯一硬件)/人生OS
**取材卡**: C1×5 + C6×5 + C7×5
**对应R系列**: R1(执行系统) / R4(14天SOP) / R5(健康底盘) / R8(人生OS)

### 选题2: 内容与一人企业
**核心问题**: 内容如何变成可复用资产？一人企业如何从0到1？
**子节点**: 内容产品化(油田→油井)/杠铃策略(90%保命10%赌命)/注意力第一性(不可再生)/平台策略
**取材卡**: C3×5 + C4×5
**对应R系列**: R2(一人企业) / R6(杠铃策略)

### 选题3: 认知框架重构
**核心问题**: 哪些"常识"在阻碍你？如何重建认知OS？
**子节点**: 反依赖(删OS旧代码)/代际错位(OS不兼容→IP杠杆)/游戏转化(省42=元能力证据)/六格复盘/完美主义破局
**取材卡**: C2×5 + C5×5
**对应R系列**: R3(认知框架) / R7(完美主义破局)

### 选题记录
选题管理: `D:\KnowledgeBase\选题管理\00-选题记录.md`
压缩主题: `D:\KnowledgeBase\选题管理\compressed\TOPIC*.md`
重构文章: `D:\KnowledgeBase\media\wechat_reconstructed\R*.md`

---

## dbs-content-system 内容单元化（从素材到文章的完整链路）

### 5类内容单元（不可再分）
| 类型 | 全称 | 定义 | 示例 |
|------|------|------|------|
| **QST** | Question | 一个问题或痛点 | "为什么坚持不了写作？" |
| **CON** | Concept | 一个概念或定义 | "信息差=你知道但别人不知道且能变现的知识" |
| **OPI** | Opinion | 一个有立场的观点 | "先有产品再做内容，不然就是在自嗨" |
| **CAS** | Case | 一个案例或故事 | "省42名LOL→快速决策能力证明" |
| **SOL** | Solution | 一个可执行的方案 | "每天发1条，坚持100天，前30天别管质量" |

### 4种关系
- **回应**: CON回应QST — "信息差(CON)解释了为什么赚钱难(QST)"
- **解释**: CAS证明OPI — "李亚鹏案例(CAS)证明了人脉≠赚钱(OPI)"
- **证明**: SOL证明OPI — "100天写作计划(SOL)证明坚持>天赋(OPI)"
- **冲突**: OPI vs OPI — "先有产品 vs 先有流量"的冲突

### 扩散树
1条推文→1张知识卡→1篇公众号→1个产品模块。扩散比约**1:40**。

---

## 公众号长文重构流程（R系列标准）

当需要从旧稿产出新文章时，走以下流程：

1. **dbs-content-system**: 从W系列+D系列素材中提取QST/CON/OPI/CAS/SOL单元
2. **3选题归并**: 按选题框架归类单元，确定文章归属
3. **dbs-deconstruct/slowisfast/benchmark**: 深度拆解+慢方法审计+对标过滤
4. **成稿**: 按R系列标准结构（hook认知劫持→信息-案例-观点交替→金句+行动号召）
5. **dbs-hook**: 开头优化（3选1）
6. **humanizer-zh**: 去AI味（5指纹扫描）
7. **compile-and-verify**: 终检（禁用词+证据密度≥2条+质量分≥9.0）

**R系列标准字段**：产出skill链 | 取材卡号 | 归并自(W/D系列) | 目标平台 | 禁用词检查 | SCORE

**存量参考**: `D:\KnowledgeBase\media\wechat_reconstructed\W_TO_R_MAP.md`

---

## 内容审计管线（发布前必须走完）

```
dbs-content(5维诊断) → humanizer-zh(去AI味) → compile-and-verify(禁用词+评分) → content-auditor(发布前审计)
```

任一环节不通过 → 返回源头重做。不许带病入库。

---

## 集成的外部Skill（内容创作增强）

| Skill | 用途 | 调用时机 |
|-------|------|---------|
| agent-reach | 13+平台信息搜集（小红书/公众号/Twitter等） | 需要外部信源验证/补充时 |
| browser-act | 浏览器自动化研究 | 需要深度浏览微信文章/网页时 |
| geju (格局) | 认知格局提升+视角升华 | 文章收尾需要拉高维度时 |
| understand-anything | 代码库/内容库知识图谱分析 | 分析知识库结构/关联时 |
| weread-exporter | 微信读书全本导出 | 需要完整书籍内容时 |
| weread-skills | 微信读书划线/想法提取 | 需要引用划线证据时 |
| ljg-think | 纵向深钻（从断言到元事实） | 观点需要推到不可再分的底层时 |
| ljg-plain | 白话重写（去复杂化） | 概念需要通俗化时 |
| baoyu-diagram | 专业深色SVG图表 | 需要架构图/流程图时 |
| crosspost | 多平台适配 | 发布前做平台适配时 |
| brand-voice | 统一语调 | 多篇需要统一声音时 |
| optimize-network | 网络/内容分发优化 | 发布策略需要优化时 |

---

## 操作一：初始化Vault

```powershell
$vault = "D:\KnowledgeBase"
if (-not (Test-Path $vault)) {
    New-Item -ItemType Directory "$vault\00_Inbox","$vault\01_Projects","$vault\02_Areas","$vault\03_Resources","$vault\04_Archive","$vault\zettel","$vault\选题管理\compressed" -Force
}
cd $vault; git init; git remote add origin https://github.com/songxrui/knowledge-base.git
```

---

## 操作二：创建原子笔记

1. 核心结论（陈述句，标题即结论）
2. 使用 `assets/note-template.md` → title/tags/status/source/四段式
3. 按 `references/file-classification.md` 决定存放位置：概念性→`zettel/`；领域知识→`02_Areas/<domain>/`；项目产出→`01_Projects/<project>/`
4. 加1-2条 `[[HOME]]（Obsidian双链示例）`
5. 标注来源和置信度

**验证**: 标题陈述句？可独立链接？有双链？`rg "\[来源" zettel/` 有标注？

---

## 操作三：Weekly Review

```powershell
scripts/weekly-review.ps1 -VaultPath D:\KnowledgeBase
```
手动流程：清空Inbox→加双链→升级seedling→`git commit -m "weekly: $(Get-Date -Format 'yyyy-MM-dd')"`

---

## 操作四：协作同步

### GitHub
```powershell
cd D:\KnowledgeBase; git add -A; git commit -m "描述"; git push
```
Token: `$env:GH_TOKEN` 已配置。远程: `songxrui/knowledge-base`

### 飞书（lark-cli）
```bash
lark-cli wiki +node-list --space-id jcn1crrvstv9 --as user
lark-cli wiki +node-create --space-id jcn1crrvstv9 --title "标题" --as user
```
飞书空间: `jcn1crrvstv9`，dontbesilent社群: `https://j8v8p5qtm3.feishu.cn/drive/folder/VjGpf9aSBlMVAedXq0wcaP9mnic` 密码`9P28882`

**同步策略**: 本地写→AI润色→`lark-cli wiki +node-create` 发布精选。不自动全量同步。只同步R系列（公众号长文）和压缩选题。

---

## 故障排查

| 症状 | 排查 |
|------|------|
| `git push` 403 | `gh auth status`，确认repo scope |
| `lark-cli` 认证失败 | `lark-cli doctor`→`lark-cli auth login` |
| Inbox堆积>7天 | 直接删或归档，不逐条处理 |
| zettel孤岛 | `rg "^## 关联" zettel/` 检查空链接 |
| 笔记无来源 | `rg "\[来源[:：]" zettel/` 审计合规 |
| 平台幻觉 | 查`选题管理/00-选题记录.md`+`media/`目录确认真实平台 |

---

## 凭据速查

| 组件 | 状态 | 凭据 |
|------|------|------|
| GitHub | ✅ | `gh auth login` / `$env:GH_TOKEN` |
| 飞书(lark-cli) | ✅ 已安装 | OAuth登录 |
| 微信读书CLI | ✅ weread-skills | token: `wrk-yC_PeQeCQBWIBD7_uFhTwwAA` |
| Exa搜索 | ✅ exa-search | `c2549c02-e87f-40d3-a7d0-100bed139eb5` |
| vault路径 | ✅ | `D:\KnowledgeBase` |

---

## 文件索引

| 需要 | 打开 |
|------|------|
| dbs方法论完整文档 | `~\.agents\skills\dbs-*\SKILL.md` |
| 3压缩选题 | `D:\KnowledgeBase\选题管理\compressed\` |
| R系列重构文章 | `D:\KnowledgeBase\media\wechat_reconstructed\` |
| W→R映射 | `D:\KnowledgeBase\media\wechat_reconstructed\W_TO_R_MAP.md` |
| 原则/反模式/工具对照 | `references/principles.md` |
| GitHub/飞书链接/CLI细节 | `references/collaboration.md` |
| 文件分类推荐体系 | `references/file-classification.md` |
| CodeWhale技能同步 | `references/codewhale-sync.md` |
| 笔记模板 | `assets/note-template.md` |
| 飞书发布格式模板 | `assets/feishu-template.md` |
| 周回顾脚本 | `scripts/weekly-review.ps1` |

---

## 边界

**做**: 本地PARA+Zettelkasten管理、笔记创建/检索/提炼、GitHub版本同步、飞书精选发布、CodeWhale跨平台同步、dbs方法论内容创作、R系列公众号长文重构、3选题压缩、内容审计管线。

**不做**: Notion API集成、飞书自动全量推送、Obsidian插件配置。

> 反幻觉红线: 提及任何平台前先验证。不得编造平台名（如"即刻"——仅当实际存在才可用）。真实平台=公众号(微信)/小红书/知乎/Threads/Newsletter（来自`media/`目录+选题记录）。
