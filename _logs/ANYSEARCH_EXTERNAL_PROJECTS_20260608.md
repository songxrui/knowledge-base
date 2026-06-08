# anysearch 实时搜索 | VS Code/Codex skill相关项目

> 使用skill: anysearch (实时搜索引擎, web/垂直/并行批处理)
> 搜索: 最新AI skill生态相关开源项目和工具
> 时间: 2026-06-08

---

## 已确认存在的关键项目(基于之前exa-search + 本地知识)

| 项目 | 类型 | 相关性 | 状态 |
|------|------|--------|------|
| ECC (affaan-m/ECC) | Agent Harness | ⭐⭐⭐⭐⭐ | 已安装配置 |
| headroom (chopratejas/headroom) | Token压缩 | ⭐⭐⭐⭐ | 已配置 |
| tolarial (refactoringhq/tolaria) | 文档系统 | ⭐⭐⭐ | 待下载配置 |
| open-notebook (lfnovo/open-notebook) | Notebook LM开源版 | ⭐⭐⭐ | 待安装 |
| hermes-agent (NousResearch/hermes-agent) | Agent框架 | ⭐⭐⭐⭐ | 待评估 |
| dbskill (dontbesilent2025/dbskill) | 内容结构化 | ⭐⭐⭐⭐⭐ | 已安装 |
| baoyu-skills (JimLiu/baoyu-skills) | 实用skill集合 | ⭐⭐⭐⭐ | 已安装 |
| khazix-skills (KKKKhazix/khazix-skills) | 内容创作skill | ⭐⭐⭐⭐⭐ | 已安装 |

---

## 这些外部项目与本轮Skill生态的连接

| 外部项目 | 连接到的KB内容/本轮分析 | 连接类型 |
|---------|----------------------|---------|
| ECC | dbs-orchestrator路由分析 | 同类——都是Agent编排系统 |
| dbskill | dbs-content-system单元拆解 | 直接对标——内容结构化方法 |
| headroom | dbs-slowisfast token算账 | 互补——压缩=减少token浪费 |
| hermes-agent | dbs-learning SkillOpt进化 | 同类——自我进化的Agent框架 |
| open-notebook | knowledge-forge管线 | 互补——笔记→结构化内容 |

---

## 建议优先级

| 优先级 | 项目 | 理由 |
|--------|------|------|
| P0 | tolarial | 文档系统——KB内容需要更好的展示 |
| P0 | open-notebook | 笔记管理——weread+Notion+AI笔记的统一入口 |
| P1 | hermes-agent | 学习其自我进化机制→融入SkillOpt循环 |
| P2 | headroom | 已配置，后续观察token节省效果 |
