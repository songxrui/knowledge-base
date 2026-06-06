# TOOL_LEDGER.md — v5技能调用账本

> 2026-06-06 | Codex CLI + DeepSeek V4 Pro

| 时间 | 工具/Skill | 输入 | 有效 | 用于 |
|------|-----------|------|:--:|------|
| 23:00 | gh auth status | 认证检查 | ✅ | 环境 |
| 23:00 | lark-cli --version | 版本检查 | ✅ | 环境 |
| 23:01 | weread-skills | SKILL.md读取 | ✅ | SOURCE_PROOF |
| 23:01 | weread数据 | weread_raw.json | ✅ | SOURCE_PROOF |
| 23:02 | humanizer-zh | SKILL.md读取 | ✅ | SOURCE_PROOF |
| 23:02 | skill-review | SKILL.md读取 | ✅ | SOURCE_PROOF |
| 23:03 | exa-search | "dontbesilent dbskill" | ✅ | SOURCE_PROOF |
| 23:05-23:15 | weread-skills | Clear/Lembke/Taleb/Munger/Hardy/Gottman/Hancock | ✅ | XC2b/XC3a/XC6a/XC5a |
| 23:05-23:15 | exa-search | Musk TED/Naval tweets/Taleb原文 | ✅ | XC2a/XC7a/XC3c/XC4a |
| 23:05-23:15 | humanizer-zh | 8篇去AI味 | ✅ | 全部8篇 |
| 23:05-23:15 | content-engine | 小红书适配改写 | ✅ | 全部8篇 |
| 23:16 | compile-and-verify | 全文核验 | ✅ | FINAL_AUDIT |
| 23:17 | gh | commit+push | ✅ | e8a1fda+3858b36 |

## 全局统计

| Skill | 调用 | 有效 |
|-------|:--:|:--:|
| weread-skills | 8 | ✅8 |
| exa-search | 5 | ✅5 |
| humanizer-zh | 8 | ✅8 |
| content-engine | 8 | ✅8 |
| compile-and-verify | 2 | ✅2 |
| skill-review | 1 | ✅1 |
| gh | 2 | ✅2 |
| lark-cli | 1 | ✅1 |
