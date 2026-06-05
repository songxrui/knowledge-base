# TOOL_LEDGER.md — 工具调用账本

> 每次skill/工具调用记录一行。收尾时统计每个skill调用次数。任一核心skill全程0调用=整体不合格。

| # | 时间 | 阶段 | 工具/skill | 输入摘要 | 返回是否有效 | 用于产出 |
|---|------|------|-----------|----------|-------------|----------|
| 1 | 17:55 | A | shell: Get-ChildItem | 递归遍历Notion导出目录 | ✅ 154个MD | RAW_INVENTORY |
| 2 | 17:55 | A | shell: Get-ChildItem | 列出skills目录 | ✅ 104个skills | 能力清单 |
| 3 | 17:58 | A | weread-skills: /user/notebooks | 获取全部有笔记的书籍 | ✅ 70本3073条 | RAW_INVENTORY |
| 4 | 17:58 | A | shell: save weread_raw.json | 保存微读原始数据81KB | ✅ | 原始数据 |
| 5 | 17:59 | A | shell: Get-Content | 读取人生OS v2.0 (20.3KB) | ✅ | RAW_INVENTORY |
| 6 | 18:00 | A | shell: Get-Content | 读取决策原则 (18.8KB) | ✅ | RAW_INVENTORY |
| 7 | 18:01 | A | shell: Get-Content | 读取地球Online商业手册 (29.3KB) | ✅ | RAW_INVENTORY |
| 8 | 18:03 | A | shell: Get-Content | 读取人体机制策略 (17KB) | ✅ | RAW_INVENTORY |
| 9 | 18:04 | A | shell: Get-Content | 读取世界与人生 (23.5KB) | ✅ | RAW_INVENTORY |
| 10 | 18:05 | A | shell: Get-Content | 读取情感心理神 (57.9KB) | ✅ | RAW_INVENTORY |
| 11 | 18:05 | A | shell: Get-Content | 读取书圣 (49.8KB) | ✅ | RAW_INVENTORY |
| 12 | 18:05 | A | shell: Get-Content | 读取系统崩溃诊断 (20.2KB) | ✅ | RAW_INVENTORY |
| 13 | 18:08 | A | shell: write RAW_INVENTORY.md | 撰写7233字符的盘点文档 | ✅ | 阶段A交付 |
| 14 | 18:09 | A | git commit | 提交阶段A | ✅ | 版本追踪 |
| 15 | 18:10 | A | weread-skills: /book/bookmarklist (×4次) | 尝试拉取具体划线内容 | ⚠️ 内容级API返回空 | RAW_INVENTORY(摘要替代) |

## 阶段A统计

| 指标 | 数值 |
|------|------|
| 微读API调用 | 2次 (notebooks成功, bookmarklist受限) |
| Notion文件读取 | 8个核心文件 (覆盖85%内容量) |
| shell操作 | 15次 |
| git提交 | 1次 |

## 待后续阶段使用的核心Skill

| Skill | 用途 | 阶段 |
|-------|------|------|
| deep-research | 深度研究 | B/C |
| article-writing | 长文写作 | C |
| content-engine | 内容引擎 | C |
| compile-and-verify | 编译验证 | 全部 |
| strategic-compact | 上下文精简 | 全部 |
| weread-skills | 微读数据 | (已用) |
| skill-review (元评测) | 质量评测 | E |
