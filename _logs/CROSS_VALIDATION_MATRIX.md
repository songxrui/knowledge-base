# DBS Skill 交叉验证矩阵 v1.0
> 生成时间: 2026-06-08 | 方法论: SkillOpt R3 | 模型: DeepSeek v4 Pro

## 已优化 Skill 路由表 (8 个)

| Skill | 触发信号 | →路由到 | 冲突/重叠 |
|-------|---------|---------|----------|
| dbs-diagnosis | 商业模式/生意/赚钱/问诊 | →action/decision/deconstruct/goal/benchmark/content | 与 decision 共享"帮我分析" |
| dbs-decision | 决策/选项/选哪个/怎么办 | →goal/save/slowisfast | 与 diagnosis 共享"怎么办" |
| dbs-deconstruct | 拆概念/什么意思/伪概念 | →diagnosis/goal/good-question | 与 diagnosis 共享"帮我分析"→优先diagnosis |
| dbs-goal | 目标审计/想做什么/定目标 | →decision/action/diagnosis | 独立 |
| dbs-good-question | 好问题/问题说明书/该怎么问 | →deconstruct/goal/diagnosis/decision | 独立 |
| dbs-slowisfast | 慢就是快/慢方法/长期主义 | →action/goal/content-system | 独立 |
| dbs-save | 存档/保存结论 | →restore | 与 restore 配对 |
| dbs-action | 拖延/执行力/不想做 | →goal/slowisfast/diagnosis | 独立 |
| dbs-content | 内容诊断/选题评估/形式匹配 | →content-system/hook/xhs-title | 独立 |
| dbs-content-system | 结构化内容/内容工程/批量处理 | →content/hook | 与 content 互补 |
| dbs-hook | 优化开头/hook/前5秒 | →content | 独立 |

## 路由优先级链

`
用户输入 → 一级判断:
  ├── 涉及商业模式/生意→ dbs-diagnosis (深度优先)
  ├── 涉及选项选择 → dbs-decision
  ├── 涉及概念定义 → dbs-deconstruct
  ├── 涉及目标模糊 → dbs-goal
  ├── 涉及问题不清 → dbs-good-question
  ├── 涉及执行力 → dbs-action
  ├── 涉及慢方法 → dbs-slowisfast
  └── 涉及内容创作 → dbs-content → dbs-content-system → dbs-hook
`

## 已知间隙

| 问题 | 影响 | 建议 |
|------|------|------|
| dbs-benchmark 未 R3 (0.6KB) | 对标功能无可用 skill | 优先级中 |
| dbs-learning 未 R3 (0.8KB) | 学习诊断功能缺失 | 优先级中 |
| dbs-report 未 R3 (0.6KB) | 报告生成功能缺失 | 优先级低 |
| dbs-agent-migration 未 R3 (1.2KB) | Agent 迁移无 skill | 优先级低 |

## 验证结论

✅ 已优化 skill 间触发边界清晰，无严重重叠
✅ 每个 skill 包含 ≥5 个触发词 + 正反例
✅ 每个 skill 指定了 ≥1 个路由目标
⚠ dbs-chatroom + dbs-chatroom-austrian 为 RICH 但 description 需 R3 规范化