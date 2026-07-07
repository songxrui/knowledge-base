# 生命之书 v2.0 — 视觉资产清单

本目录包含《生命之书》v2.0 配套的视觉资产。主文档已嵌入 Mermaid 流程图，以下为待生成的可选图片资源。

## 图片资产清单

### 1. 根因模型信息图 (Root Cause Infographic)
- **文件**: `root-cause-model.png`
- **用途**: 第1节「第一性根因」的开篇视觉
- **尺寸**: 1200×800px (3:2)
- **现有替代**: 主文档中已有 Mermaid 流程图
- **状态**: ⏳ 待生成

### 2. 六大杠杆总览图 (6 Levers Framework)
- **文件**: `6-levers-framework.png`
- **用途**: 第2节开篇，总览六杠杆
- **尺寸**: 1600×900px (16:9)
- **状态**: ❌ 未生成

### 3. 90天方案视觉表 (90-Day Plan Visual)
- **文件**: `90-day-plan.png`
- **用途**: 第4节「90天可执行方案」配套图
- **尺寸**: 1200×900px (4:3)
- **状态**: ❌ 未生成

### 4. 每日检查清单 (Daily Checklist)
- **文件**: `daily-checklist.png`
- **用途**: 第4节「每日必做清单」配套图
- **尺寸**: 800×1200px (2:3)
- **状态**: ❌ 未生成

---

## 图片生成说明

### 条件
执行需要 `bun` + 有效的 codex/OpenAI/其他图片生成 API 鉴权。

### 命令
```powershell
# 使用 baoyu-image-gen (codex CLI provider)
bun $env:USERPROFILE\.agents\skills\.archived\baoyu-image-gen\scripts\main.ts `
  --provider codex-cli `
  --image "$env:USERPROFILE\KnowledgeBase\assets\root-cause-model.png" `
  --prompt-file "$env:USERPROFILE\KnowledgeBase\assets\prompts\root-cause-prompt.md" `
  --ar "3:2"

# 使用 baoyu-image-gen (openai provider)
bun $env:USERPROFILE\.agents\skills\.archived\baoyu-image-gen\scripts\main.ts `
  --provider openai `
  --image "$env:USERPROFILE\KnowledgeBase\assets\6-levers-framework.png" `
  --prompt-file "$env:USERPROFILE\KnowledgeBase\assets\prompts\6-levers-prompt.md" `
  --ar "16:9"
```
