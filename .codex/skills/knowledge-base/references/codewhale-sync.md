# CodeWhale 技能同步工作流

> 确保 knowledge-base skill 在 Codex 和 CodeWhale 之间保持一致。

## 架构

```
~/.codex/skills/knowledge-base/     ← 主副本（Codex CLI 使用，本 repo）
        │
        │ robocopy /MIR
        ↓
~/.codewhale/skills/knowledge-base/ ← 镜像副本（CodeWhale 使用）
```

---

## 同步操作

### 从 Codex 推送到 CodeWhale（修改 skill 后执行）

```powershell
$source = "$env:USERPROFILE\.codex\skills\knowledge-base"
$target = "$env:USERPROFILE\.codewhale\skills\knowledge-base"

# 创建目标目录（如不存在）
New-Item -ItemType Directory $target -Force

# 镜像同步（仅同步变更文件）
robocopy $source $target /MIR /NJH /NJS /NP /NDL
```

**验证**：
```powershell
# 对比文件列表，确认一致
Get-ChildItem $source -Recurse -File | ForEach-Object { $_.Name } | Sort-Object > $env:TEMP\codex_files.txt
Get-ChildItem $target -Recurse -File | ForEach-Object { $_.Name } | Sort-Object > $env:TEMP\codewhale_files.txt
diff (Get-Content $env:TEMP\codex_files.txt) (Get-Content $env:TEMP\codewhale_files.txt)
```

### 从 CodeWhale 引入新技能到 Codex

CodeWhale 有 ~200+ 原生技能池。引入流程：

1. **发现**：`Get-ChildItem ~/.codewhale/skills -Directory | Where-Object { -not (Test-Path "$env:USERPROFILE\.codex\skills\$($_.Name)") }`
2. **评测**：用 `skill-review` 扫描目标 skill（路径 `D:\_ai\skills\skill-review\`）
3. **复制**：`robocopy ~/.codewhale/skills/<skill-name> ~/.codex/skills/<skill-name> /E`
4. **验证**：触发该 skill 的描述词，确认 Codex 能正确加载

---

## CodeWhale 特有技能推荐（可引入 Codex）

| CodeWhale Skill | 用途 | 推荐理由 |
|----------------|------|---------|
| `academic-paper-composer` | 论文写作 | 结构化写作能力 |
| `agent-browser` | Agent浏览器 | Web交互 |
| `everything-claude-code` | Claude Code大全 | 跨平台参考 |
| `mle-workflow` | ML工程工作流 | 数据科学 |
| `nextjs-turbopack` | Next.js开发 | 现代前端 |
| `bun-runtime` | Bun运行时 | JS运行时 |

> [推断] 以上基于名称推荐，实际引入前需用 `skill-review` 评测。

---

## 配置同步

### CodeWhale 配置参考

CodeWhale 配置位于 `~/.codewhale/config.toml`，包含 MCP server 和模型配置。

**与本skill相关的配置项**：
```toml
[features]
multi_agent = true

[mcp_servers.filesystem]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "D:\\KnowledgeBase"]
```

如需在 Codex 中使用相同 MCP 配置，手动添加到 `~/.codex/config.toml`。

---

## 故障排查

| 症状 | 排查 |
|------|------|
| robocopy 报错5(拒绝访问) | 以管理员运行 PowerShell |
| 同步后 CodeWhale 不识别 | 重启 CodeWhale 进程 |
| 文件内容不一致 | 检查编码（必须 UTF-8），BOM 可能导致差异 |
| Codex 和 CodeWhale 同时修改 | **始终以 Codex 为主副本**，CodeWhale 只做镜像 |
