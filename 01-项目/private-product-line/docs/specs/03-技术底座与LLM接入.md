---
id: ppl-03-platform
status: ai-draft
evidence_level: B
created: 2026-09-11
updated: 2026-09-11
---

# 03 · 技术底座与 LLM 接入规范

## 一、总原则

1. **TypeScript 单语言栈**：一人长期维护，宁可同构也不要双栈。领域逻辑写一次，两端复用。
2. **本地优先，文件即真理**：SQLite 是运行时，Markdown/CSV 是对外接口（与 `.dbs`、`05-内容生产` 的现有形态互通）。卸载软件不丢数据。
3. **收编优先于重写**：底座从 `01-项目/super-individual-os-v0.2/`（Northstar）迁移改造，它已是 React + Vite + PWA + Tauri 2 的 monorepo，DDD 分层与本产品线一致。
4. **每个产品必须独立可删**：三产品共享底座包，但数据表按产品前缀隔离，删除一个产品不伤另外两个。

## 二、仓库结构

```
01-项目/private-product-line/
  apps/
    desktop/        # Tauri 2 + React（Windows，主端）
    mobile/         # Capacitor 6 打包同一套 React UI（安卓 6.74"）
  packages/
    aqua/           # AQUA 设计系统（令牌 + 12 组件，见 02 规格）
    core/           # 领域逻辑：五层系统、状态机、门禁、评分（纯 TS，零 UI 依赖）
    storage/        # SQLite + drizzle-orm，schema 按产品前缀隔离（zhixing_/dbs_/cortex_）
    llm/            # LLM 供应商注册表、OpenAI 兼容客户端、任务路由、Token 账本
    humanizer/      # faith-humanizer v6.5 规则引擎（98 模式 + 红线门禁，规则表外置为 JSON）
  docs/specs/       # 本规格集
```

- 状态管理 zustand；动效 framer-motion；图标自绘 SVG 集。
- 桌面 SQLite 走 `tauri-plugin-sql`，安卓走 `@capacitor-community/sqlite`，由 `packages/storage` 屏蔽差异。
- 知识库文件访问：桌面端经 Tauri fs API 直读 `D:\KnowledgeBase`（只写两个白名单路径：`00-收件箱/` 与 `.dbs/assembly/`），移动端不直接碰知识库。

## 三、安卓策略（6.74 英寸）

- v0-v1 用 **Capacitor 打包同一套 React UI**：一份代码、最快可用，符合"最小可运行单元"哲学。性能预算：冷启动 <2s、交互响应 <100ms、滚动 55fps；超预算先做虚拟列表与动效降级。
- 若 WebView 方案实测不达标，备选迁移路径：`packages/core` 原样复用 + Expo RN 重写 UI 层（成本集中在 `apps/mobile`，领域逻辑零改动）。
- 安卓端角色定位为**速记与打卡终端**：重输入、轻管理；管理端永远在 Windows。

## 四、LLM 接入规范（全产品共享）

### 4.1 供应商模型

设置页支持多个供应商并存，每个供应商一条配置：`{ 名称, 类型, BaseURL, APIKey, 模型列表, 启用 }`。类型只有两种：

- `openai-compatible`：中转站与绝大多数国产官网都用它（`/chat/completions` + SSE 流式）。
- `custom`：非标接口（预留，v0.1 可只做第一种）。

内置预设（BaseURL 以各家官网文档为准，允许用户改写）：

| 预设 | BaseURL | 备注 |
|---|---|---|
| 通用中转站 | （用户手填） | OneAPI/NewAPI 类聚合站，模型名手填 |
| DeepSeek | `https://api.deepseek.com` | 官网：platform.deepseek.com |
| 智谱 GLM | `https://open.bigmodel.cn/api/paas/v4` | 官网：open.bigmodel.cn |
| 通义千问 | `https://dashscope.aliyuncs.com/compatible-mode/v1` | 官网：bailian.console.aliyun.com |
| Kimi (月之暗面) | `https://api.moonshot.cn/v1` | 官网：platform.moonshot.cn |
| 豆包（火山方舟） | `https://ark.cn-beijing.volces.com/api/v3` | 官网：console.volcengine.com/ark |
| MiniMax | 按官网文档填写 | 接口路径非标准时归入 custom |

硬性要求：**预设只预填 BaseURL 与名称，API Key 一律用户手动粘贴**；不内置任何默认 Key、不请求任何在线密钥服务。

### 4.2 设置页（手动填写，全产品统一）

- 入口：各产品"系统"Tab → 模型设置。
- 布局：供应商卡片列表（AQUA 卡片）→ 点开为 Sheet 表单：名称 / 类型 / BaseURL / API Key（密码框，可点击显隐）/ 模型名（多值，可"获取模型列表"按钮拉取）。
- **连接测试**：保存前强制执行两步——①列出模型（验证 BaseURL+Key）；②发送一句 20 token 测试对话（验证推理可用）。显示延迟与首字耗时。
- 密钥存储：Windows 用 DPAPI（CryptProtectData）加密后落 SQLite；安卓用 Keystore + EncryptedSharedPreferences。明文密钥永不进 Git、永不进日志、永不随导出文件带出（导出时脱敏）。
- 失败降级：主供应商连续 3 次失败 → 提示切换备用供应商（用户在设置里指定优先级，软件不自动乱跳）。

### 4.3 任务路由与用量账本

- 每类 AI 任务固定映射到模型角色，用户可为每个角色指定"用哪个供应商的哪个模型"：
  | 任务角色 | 特征 | 默认建议 |
  |---|---|---|
  | `coach` 复盘教练/归因 | 长上下文、强推理 | DeepSeek-R1 / GLM-4.6 / Kimi 长思考 |
  | `audit` humanizer 审计 | 规则执行、低成本大批量 | DeepSeek-V3 / GLM-4.5-Air |
  | `titles` 标题工厂 | 快、便宜、并发 | 千问-turbo / 豆包-lite |
  | `qa` 知识库问答 | 长上下文 RAG | Kimi 128k / GLM 长文本 |
- Token 账本：每次调用记录 `{时间, 产品, 任务角色, 供应商, 模型, 输入/输出 tokens, 延迟}`，月度汇总页展示（数据性质同发布数据，可导出 CSV 追加到 `99-系统` 日志区）。
- 全部请求走本机直连，软件内不设任何服务器。

### 4.4 LLM 内容纪律（写进 `packages/llm` 的系统提示层）

- 所有生成内容自动带 `ai_derived: true` 标记，落库即 B 级（对齐 `SOURCE_OF_TRUTH` 冲突规则第 5/7 条）。
- 教练/问答类提示词必须包含"只引用用户记录，无记录则明确说没有"的硬约束；引用必须可点击回溯到原文。
- humanizer 的 G 类红线（禁编造经历）在代码层校验，不依赖模型自觉。

## 五、数据与同步

- v0：桌面是唯一主库；安卓速记/打卡写入本地库，通过"导出包（加密 zip）→ 桌面导入合并"或局域网 HTTP 直传（同 Wi-Fi 一键同步）合并，冲突以"后写优先 + 保留双版本标记"处理。
- v1 再评估 Syncthing 同步 SQLite WAL 或内嵌 litestream；**永远不做云账号**。
- 备份：每日关闭时自动导出全量 SQL + 关键 Markdown 到 `99-系统/日志/` 下按日期归档，保留 30 份滚动。

## 六、安全与隐私边界

- 三产品的数据只落本机；LLM 调用仅发送完成该任务所需的最小上下文（能量四字段、单篇草稿等），不整库上传。
- 知识库问答（Cortex）检索到的片段进入提示词前，剥离任何 API Key、密钥类内容（正则黑名单）。
- 窗口失焦 5 分钟自动上锁（PIN 或 Windows Hello），防物理窥屏——私有产品的"合规风控"由自己承担，但至少别让旁观者一眼看到。
