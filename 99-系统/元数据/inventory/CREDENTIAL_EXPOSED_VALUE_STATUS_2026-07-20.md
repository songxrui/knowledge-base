# 已暴露凭据当前状态检查

> 日期：2026-07-20
> 安全边界：本文件不保存凭据值、哈希、响应正文或可用于重放的信息。

## DeepSeek

- 用户级 `DEEPSEEK_API_KEY` 存在：true
- 与 Git 历史已暴露候选相同：true
- `GET https://api.deepseek.com/v1/models`：HTTP 200
- 结论：已暴露旧值仍然有效，必须在 DeepSeek 控制台服务端吊销；仅删除环境变量不足以关闭风险。

## GitHub

- GitHub CLI 当前 token 存在：true
- 当前 token 与本轮从历史提示词中提取到的 `gh*` 模式候选相同：false
- 历史 `gh*` 模式候选数量：0
- 限制：未匹配不证明旧 PAT 已吊销；仍需在 GitHub token 设置中核对并撤销历史令牌。

## 结论

凭据状态继续保持 `rotation_required`。DeepSeek 已有直接“旧值仍有效”证据；其他服务仍缺少可定位的旧值拒绝或吊销证据。

