---
name: content-pipeline-orchestrator
description: |
  内容发布五步流水线编排。自动串联 humanizer→traffic-engineering→viral-writer→wewrite→crosspost。
  触发：发布内容、三平台分发、内容流水线、pipeline发布、content pipeline、内容上线。
  不适用：单步优化(用对应skill)、代码/技术文档、纯翻译。
  正例：'帮我把这篇发到三平台'→触发；'这篇文章要发布了，跑流水线'→触发。
  反例：'帮我改个标题'→不触发→viral-writer；'翻译这篇'→不触发→translate。
version: 1.0.0
---

# Content Pipeline Orchestrator

五步流水线编排——大模型只调度，不动笔。

## 核心原则
- **只编排，不写作**：正文由子skill产出
- **门禁传递**：每步产出必须过门禁才进下一步
- **单篇commit**：每完成一篇立即git commit

## 五步流水线

### Step 1: humanizer — AI味清除
- 扫描禁用词黑名单
- 检测6病征（排比成瘾/空泛结尾/强行中立/信息密度低/具体性缺失/伪个人化）
- 门禁：0禁用词 + 5/6病征PASS
- 不通过→回humanizer重做

### Step 2: traffic-engineering — 传播力优化
- Phase 1 注意力诊断（5项布尔判定）
- Phase 5 10维评分（S/A/B/C）
- 门禁：≥75分 A级
- 不通过→回traffic-engineering优化

### Step 3: viral-writer — 11维内容分析
- 11维度扫描（核心观点/金句/情绪曲线等）
- 门禁：≥80分
- 不通过→回viral-writer重做

### Step 4: wewrite — 公众号格式化
- 公众号安全排版检查
- SEO标题优化
- 门禁：格式合规 + SEO PASS

### Step 5: crosspost — 三平台适配
- 公众号版/小红书版/知乎版独立生成
- 门禁：三版本齐全 + 无跨平台复制粘贴

## 快速启动
说"发布[文件名]到三平台"即可触发完整流水线。

## 工时预估
单篇完整流水线：3-5分钟（含门禁检查）

## 输出
- platforms/wechat.md
- platforms/xiaohongshu.md
- platforms/zhihu.md
- PIPELINE_LOG.md（每步门禁结果）

## G1-G6
| 门禁 | 状态 |
|------|------|
| G1 ≤3KB | ✅ (2.1KB) |
| G2 触发层 | ✅ |
| G3 可执行(5Step) | ✅ |
| G4 验证(每步门禁) | ✅ |
| G5 失败兜底(重试机制) | ✅ |
| G6 安全 | ✅ |
