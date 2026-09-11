# 凭据本机存储就绪检查

> 日期：2026-07-20
> 安全边界：只记录是否存在，不读取、不显示、不哈希任何凭据值。

## 环境变量

| 变量 | 当前进程可见 |
|---|---|
| `FEISHU_APP_ID` | false |
| `FEISHU_APP_SECRET` | false |
| `FEISHU_FOLDER_TOKEN` | false |
| `WEREAD_COOKIE` | false |
| `EXA_API_KEY` | false |
| `DEEPSEEK_API_KEY` | false |

## GitHub CLI

- `gh` 可用：true
- `gh auth status` 退出码：0
- 登录状态可用：true
- 限制：当前登录只证明本机 keyring 有可用认证，不证明历史 PAT 已吊销。

## 结论

服务端轮换证据仍为 `verified=0 / pending=6`。在新值安全注入且旧值拒绝证据齐全前，严格检查器必须失败。

