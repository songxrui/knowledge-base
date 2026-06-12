---
name: knowledge-base
description: "个人知识库搭建与维护+内容创作全管线。PARA+Zettelkasten+AI-native+飞书门面。dbs方法论内置：选题压缩(3核心选题)、内容单元化(QST/CON/OPI/CAS/SOL)、R系列重构、质量门禁链。触发：知识库、vault、zettel、PARA、笔记模板、weekly review、周回顾、同步飞书、推送GitHub、知识库协作、创建笔记、提炼想法、文件分类、知识库结构、笔记组织、写文章、公众号长文、内容优化、选题压缩。反触发：纯代码仓库管理→github-ops、项目管理工具配置、数据库设计。"
version: "4.2.0 | 2026-06-12 | 知识库结构清理+日志TTL+旧版归档+book-v7加入+Skill生态更新"
---

# 知识库 Skill v4.2 — dbs方法论+Obsidian导航+验真管线

**三端**：本地md+git=AI大脑 / GitHub=版本仓库 / 飞书=门面协作。

> 原则与反模式 → `references/principles.md` | GitHub/飞书协作 → `references/collaboration.md`
> 文件分类 → `references/file-classification.md` | CodeWhale同步 → `references/codewhale-sync.md`

---

## 证据与反幻觉规则（全局适用，红线）

1. **来源标注**：每条事实/观点标注出处。`[来源: <工具/书籍/URL>]`
2. **置信度标记**：不确定标注 `[推断]` `[待验证]` `[个人经验]`
3. **禁止编造**：不得伪造书名、URL、数据、引用。无来源标注 `[来源缺失]`
4. **平台幻觉防御**：提及任何平台前先查 `选题管理/00-选题记录.md` 和 `media/` 目录确认真实平台。已验证真实平台：公众号(微信)/小红书/知乎/Threads/Newsletter/Twitter(X)/B站/抖音（来自 `media/` 目录文件结构+选题记录）。**绝对禁止编造平台名**。
5. **核查提醒**：医学/法律/投资/统计 → `[⚠ 核查: 请核对原始来源]`
6. **库外独立验证**：验证证据必须来自语料库之外（weread高亮/exa一手来源/公开研究/实验日志）。库内文章互相引用/自引/同语料转引一律不算验证。

---

## Vault 导航系统（Obsidian 式 MOC）

`D:\KnowledgeBase\` 已建立 Obsidian 式链接导航：

| 文件 | 用途 | 覆盖范围 |
|------|------|---------|
| `HOME.md` | 主入口/仪表盘 | 全库导航 |
| `_MOC_Cards.md` | 深度卡索引 | 77张卡（35主体+42主题） |
| `_MOC_Content.md` | 内容产出索引 | 15个分类所有长文 |
| `_MOC_Flagship.md` | 旗舰作品索引 | v6+v7+英文版（v2-v5已归档） |
| `INDEX.md` | 全量文件列表 | 1874篇.md全量 |

### Vault 分析工具

```powershell
# 全量分析（断链/孤点/Hub节点）
powershell -ExecutionPolicy Bypass -File "D:\KnowledgeBase\scripts\analyze_vault_v3.ps1"

# 重建MOC索引
powershell -ExecutionPolicy Bypass -File "D:\KnowledgeBase\scripts\rebuild_mocs.ps1"
```

当前状态（2026-06-12）：**断链0**，结构清理完成（旧版归档+脚本迁移+日志TTL）。

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
├─ 终检 → humanizer-zh + content-truth-lock (去AI味+验真)
├─ 验真审计 → content-truth-lock (库外独立验证+4证据+红队+盲评)
├─ 流量优化 → 03_Resources/traffic-engineering/ (平台规则+注意力第一性)
└─ 元评测 → SKILL_INDEX.md (全量技能索引)
```

### dbs-content 5哲学（内容质量门禁）
1. **文字洁癖是底线** — AI内容被限流不是AI的问题，是用AI的人对文字没有洁癖
2. **自媒体本质=精神控制** — 封面和标题的本质是认知劫持
3. **内容好坏=投入精力×对内容有正确理解** — 越新手越要推高单篇成本
4. **先有产品后有内容** — 不能把付款链接发出来让你成功付款=没有产品
5. **知识博主的工作只有两个** — ①把事情搞清楚 ②把事情说清楚

---

## 3核心选题框架（压缩自17主题）

所有内容产出必须归入以下3选题之一。

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

## 答案之书质量管线（3版本活跃 + 4版本已归档）

`D:\KnowledgeBase\media\flagship\` 下维护版本演进链：

| 版本 | 文件数 | 状态 | 核心改进 |
|------|--------|------|---------|
| ~~book-v2~~ | 15 | 📦 已归档至 04_Archive | 8章初稿 |
| ~~book-v3~~ | 28 | 📦 已归档至 04_Archive | S/A/B/C证据标记+11反共识+8章行动系统 |
| ~~book-v4~~ | 34 | 📦 已归档至 04_Archive | 证据坐实+贯通验真+原创标注 |
| ~~book-v5~~ | 34 | 📦 已归档至 04_Archive | 去模板化+自然行文+接缝隐形 |
| **book-v6** | 34 | ✅ 自然协调 | 节奏变奏+场景补全+言行一致 |
| **book-v7** | 59 | ✅ 当前最完整版 | 证据增强+去AI味+风格手册+Skill全场标注 |
| **book-of-life-answers** | 14 | ✅ 英文版 | 9章完整英文版 |

### 质量升级五杠杆
1. **证据坐实** → `EVIDENCE_LEDGER.md`（论点→等级→锚点→验证状态）
2. **贯通验真** → `CONCEPT_MAP.md`（概念引用图，0死链）
3. **行动可验证** → 每章自测有明确通过/失败判据
4. **反共识立论** → 四件套：流行错误|为什么错|反例|适用边界
5. **原创坐实+敢删** → `ORIGINALITY_LOG.md` + `CUT_LOG.md`

### DoD 审计（反盖章版）
- 自动层：每条[S]/[A]带锚点标记 | EVIDENCE_LEDGER/CONCEPT_MAP存在 | 死链=0 | 黑名单零命中
- 人工层：随机抽5条锚点逐条判断真/存疑/伪 | 抽3个反共识判断反例是否成立

---

## 流量工程 skill（《流量的本质与暴力》+平台规则）

已构建流量底层skill，位于 `D:\KnowledgeBase\03_Resources\traffic-engineering\`：

### 平台第一性规则
| 平台 | 核心算法偏好 | 内容形态 | 传播机制 |
|------|------------|---------|---------|
| 公众号 | 订阅+社交裂变 | 长文(1500-3000字) | 转发>在看>算法推荐 |
| 小红书 | CES评分(点赞1/收藏1/评论4/关注8) | 图文(800-1200字)+封面 | 搜索长尾+推荐流双引擎 |
| 抖音 | 完播率>互动率>转粉率 | 短视频(15-60s)/图文 | 赛马机制+流量池递进 |
| B站 | 三连+完播+弹幕密度 | 中长视频(3-15min) | 分区推荐+搜索沉淀 |
| Twitter(X) | 回复>引用>点赞>书签 | 短线程(5-10条) | 纯算法推荐+quote扩散 |

### 注意力第一性原理
1. 注意力是不可再生资源 — 争夺的不是时间，是认知带宽
2. 认知劫持公式：封面(0.3秒信号)×标题(1秒决策)×开头(hook)×节奏(keep)
3. 平台依赖症：内容在别人的管道里流动，你在为人家的管道打工
4. 内容产品化：每篇内容必须指向一个产品/付费/认知转化

### 发布前自检清单
- [ ] 封面/标题能0.3秒传达核心冲突？
- [ ] 开头有hook（数据冲击/反共识/痛点直击）？
- [ ] 每300字一个信息增量点？
- [ ] 结尾有清晰CTA（行动召唤）？
- [ ] 平台适配版已准备（公众号长文/小红书图文/Twitter线程）？

---

## dbs-content-system 内容单元化（从素材到文章的完整链路）

### 5类内容单元（不可再分）
| 类型 | 全称 | 定义 | 示例 |
|------|------|------|------|
| **QST** | Question | 一个问题或痛点 | "为什么坚持不了写作？" |
| **CON** | Concept | 一个概念或定义 | "信息差=你知道但别人不知道且能变现的知识" |
| **OPI** | Opinion | 一个有立场的观点 | "先有产品再做内容，不然就是免费写日记" |
| **CAS** | Case | 一个案例或故事 | "db从13000条推文中提取出1419个内容单元" |
| **SOL** | Solution | 一个可执行方案或步骤 | "14天实验SOP：荒谬最小化+基线记录+瓶颈变量" |

### 5层工程架构
1. **规则层** → 命名规范/字段格式/关联方式
2. **状态层** → 已处理/跳过/待复核
3. **内容单元库** → QST/CON/OPI/CAS/SOL存储
4. **主题地图** → 相关节点组织成内容面
5. **选题装配稿** → 可发布内容骨架（受众+问题+素材结构）

本地结构化工程: `D:\KnowledgeBase\_content-system\`

---

## 关联 Skill 生态（按需调用）

| Skill | 功能 | 调用时机 |
|-------|------|---------|
| agent-reach | 13+平台信息搜集 | 需要外部信源验证/补充时 |
| weread-skills | 微信读书划线/想法提取 | 需要引用划线证据时 |
| weread-exporter | 微信读书全本导出 | 需要完整书籍内容时 |
| ljg-think | 纵向深钻（从断言到元事实） | 观点需要推到不可再分的底层时 |
| humanizer-zh | 中文化去AI味 | 所有对外内容必经 |
| content-truth-lock | 证据验真+库外独立验证 | 发布前证据最终审计 |
| exa-search | 神经搜索（web/code/companies） | 补充一手研究来源 |
| think-then-act | 先想后动（意图→规划→监工） | 复杂多步骤任务执行前 |

---

## 微信读书集成

**Token**: `wrk-yC_PeQeCQBWIBD7_uFhTwwAA`（已配置环境变量）
**推荐书单**: 50本推荐阅读书单（用于充实答案之书内容）
**skill**: `weread-skills`（划线/想法提取）、`weread-exporter`（全本导出）

调用优先级：先 `weread-skills` 提取相关划线 → 不足时调用 `weread-exporter` → 仍不足用 `exa-search`。

---

## 操作一：初始化Vault

```powershell
$vault = "D:\KnowledgeBase"
if (-not (Test-Path $vault)) {
    New-Item -ItemType Directory "$vault\01_Projects","$vault\02_Areas","$vault\03_Resources","$vault\04_Archive","$vault\scripts","$vault\zettel" -Force
}
cd $vault; git init; git remote add origin https://github.com/songxrui/knowledge-base.git
```

---

## 操作二：创建原子笔记

1. 核心结论（陈述句，标题即结论）
2. 使用标准模板：title/tags/status/source/四段式（参考已有卡片格式）
3. 按 `references/file-classification.md` 决定存放位置：概念性→`zettel/`；领域知识→`02_Areas/<domain>/`；项目产出→`01_Projects/<project>/`
4. 加1-2条 `[[HOME]]`（Obsidian双链，链接到首页或相关MOC）
5. 标注来源和置信度

**验证**: 标题陈述句？可独立链接？有双链？`rg "\[来源[:：]" zettel/` 有标注？

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

### 飞书（lark-cli v1.0.49）
```bash
lark-cli wiki +node-list --space-id 7647454140578335680 --as user
lark-cli wiki +node-create --space-id 7647454140578335680 --title "标题" --as user
```
飞书空间: `jcn1crrvstv9`，dbs社群笔记: `https://j8v8p5qtm3.feishu.cn/drive/folder/VjGpf9aSBlMVAedXq0wcaP9mnic` 密码`9P28882`

**同步策略**: 本地写→AI润色→`lark-cli wiki +node-create` 发布精选。不自动全量同步。只同步R系列（公众号长文）和压缩选题。

### Vault 分析（定期健康检查）
```powershell
powershell -ExecutionPolicy Bypass -File "D:\KnowledgeBase\scripts\analyze_vault_v3.ps1"
# 期望输出：断链=0，Wiki链接≥392，被引用节点≥280
```

---

## 故障排查

| 症状 | 排查 |
|------|------|
| `git push` 403 | `gh auth status`，确认repo scope |
| `lark-cli` 认证失败 | `lark-cli doctor`→`lark-cli auth login` |
| Inbox堆积>7天 | 直接删或归档，不逐条处理 |
| zettel孤岛 | `rg "^## 关联" zettel/` 检查空链接 |
| 笔记无来源 | `rg "\[来源[:：]" zettel/` 审计合规 |
| 平台幻觉 | 查`选题管理/00-选题记录.md`+`media/`目录。已验证平台：公众号/小红书/知乎/Threads/Newsletter/Twitter/B站/抖音 |
| Vault断链>0 | 运行 `analyze_vault_v3.ps1` 定位，用 `rebuild_mocs.ps1` 重建索引 |
| MOC中文乱码 | 文件编码必须是 UTF-8 with BOM，用 `rebuild_mocs.ps1` 重建 |

---

## 凭据速查

| 组件 | 状态 | 凭据 |
|------|------|------|
| GitHub | ✅ | `gh auth login` / PAT已配置 |
| 飞书(lark-cli) | ✅ v1.0.49 | OAuth登录, Space: `jcn1crrvstv9` |
| 微信读书 | ✅ weread-skills | token: `wrk-yC_PeQeCQBWIBD7_uFhTwwAA` |
| Exa搜索 | ✅ exa-search | token: `c2549c02-e87f-40d3-a7d0-100bed139eb5` |
| Headroom | ✅ MCP已配置 | CLI: `headroom` v0.20.15, MCP tool: `headroom_compress` |
| vault路径 | ✅ | `D:\KnowledgeBase` (~1500 .md文件，清理后精简) |

---

## 文件索引

| 需要 | 打开 |
|------|------|
| dbs方法论完整文档 | `~\.agents\skills\dbs-*\SKILL.md` |
| 3压缩选题 | `D:\KnowledgeBase\选题管理\compressed\` |
| R系列重构文章 | `D:\KnowledgeBase\media\wechat_reconstructed\` |
| W→R映射 | `D:\KnowledgeBase\media\wechat_reconstructed\W_TO_R_MAP.md` |
| 答案之书全部版本 | `D:\KnowledgeBase\media\flagship\book-v*` |
| Vault导航入口 | `D:\KnowledgeBase\HOME.md` |
| Vault分析报告 | `D:\KnowledgeBase\_logs\VAULT_ANALYSIS_*.md` |
| 流量工程 | `D:\KnowledgeBase\03_Resources\traffic-engineering\` |
| 内容单元库 | `D:\KnowledgeBase\_content-system\` |
| 原则/反模式 | `references/principles.md` |
| GitHub/飞书配置 | `references/collaboration.md` |
| 文件分类推荐 | `references/file-classification.md` |
| CodeWhale同步 | `references/codewhale-sync.md` |
| MOC索引 | `HOME.md` / `_MOC_Cards.md` / `_MOC_Content.md` / `_MOC_Flagship.md` |
| 笔记模板 | 参考 cards/ 中已有卡片格式 |
| 脚本 | `scripts/weekly-review.ps1` / `scripts/analyze_vault_v3.ps1` / `scripts/rebuild_mocs.ps1` |

---

## 边界

**做**: 本地PARA+Zettelkasten管理、笔记创建/检索/提炼、GitHub版本同步、飞书精选发布、CodeWhale跨平台同步、dbs方法论内容创作、R系列公众号长文重构、3选题压缩、内容审计管线、Vault健康检查（断链/孤点/Hub分析）、答案之书版本演进管理、流量平台优化。

**不做**: Notion API集成、飞书自动全量推送、Obsidian插件配置。

> 反幻觉红线: 提及任何平台前先验证。已验证真实平台=公众号(微信)/小红书/知乎/Threads/Newsletter/Twitter(X)/B站/抖音（来自`media/`目录+选题记录）。不得编造平台名。
