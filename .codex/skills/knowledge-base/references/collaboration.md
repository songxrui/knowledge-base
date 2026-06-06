# 协作配置

> 以下配置使用占位符。首次使用时替换为你的实际值。

## GitHub

- **仓库模板**: `https://github.com/<your-username>/knowledge-base`
- **本地路径**: 由 `$env:KNOWLEDGE_VAULT` 指定（默认 `D:\KnowledgeBase`）
- **当前配置**: songxrui/knowledge-base ([仓库链接](https://github.com/songxrui/knowledge-base))

### 初始化

```powershell
$env:KNOWLEDGE_VAULT = "D:\KnowledgeBase"
cd $env:KNOWLEDGE_VAULT
git init
git remote add origin https://github.com/<your-username>/knowledge-base.git
```

### 常用操作

```powershell
cd $env:KNOWLEDGE_VAULT
git push
git status
git log --oneline -5
```

### Token 配置

GitHub token 需 `repo` scope。设置：
```powershell
$env:GH_TOKEN = "<your_github_pat>"
# 或用: gh auth login
```

验证：`gh auth status`

---

## 飞书

- **空间模板**: `https://<tenant>.feishu.cn/wiki/space/<SPACE_ID>`
- **Space ID**: 当前为 `7647454140578335680`
- **CLI**: `lark-cli`（`@larksuite/cli`，需 `lark-cli auth login` 认证）

### 常用 CLI

```bash
# 列出节点
lark-cli wiki +node-list --space-id <YOUR_SPACE_ID> --as user

# 创建节点
lark-cli wiki +node-create --space-id <YOUR_SPACE_ID> --title "标题" --as user

# 获取节点详情
lark-cli wiki +node-get <node_token> --as user

# 删除节点（谨慎）
lark-cli wiki +node-delete <node_token> --as user
```

### 节点映射（当前配置）

| 本地目录 | 飞书节点 | node_token |
|----------|---------|------------|
| 00_Inbox | 📥 00_Inbox | OvOnwvhkHiXQGpkUZpbcLDY8nLb |
| 01_Projects | 📂 01_Projects | AqGlwjdwGibszNklpZ5cJZTynVI |
| 02_Areas | 📂 02_Areas | XN6WwtPx1iU9oDkaPJocU3JanWd |
| 03_Resources | 📂 03_Resources | D5D0wDtNGionqhkLku8ciSEgnSh |
| 04_Archive | 📂 04_Archive | A2O4wlLjViGG0qkfUnFcGWldnEd |
| zettel | 🧠 Zettel 精选 | GVPDwduw8iiQ6ckYKGecBAWonFd |

> 发布格式规范见 `assets/feishu-template.md`

---

## CodeWhale 同步

> 详细工作流见 `references/codewhale-sync.md`

快速同步命令：
```powershell
robocopy ~/.codex/skills/knowledge-base/ ~/.codewhale/skills/knowledge-base/ /MIR /NJH /NJS /NP /NDL
```
