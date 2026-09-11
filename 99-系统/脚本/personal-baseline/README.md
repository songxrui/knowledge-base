# 个人基线自动化维护

这套脚本对“个人基线”产品执行本地、可审计、可回滚的质量维护。默认不发布、不删除、不改价格、不升级证据等级，也不把语义候选直接写入正式内容。

## 快速使用

在知识库根目录运行：

```powershell
# 只读审计
pwsh -NoProfile -File .\99-系统\脚本\personal-baseline\Invoke-PersonalBaselinePipeline.ps1 -Mode audit

# 完整本地维护：确定性安全修复、候选生成、终验和报告
pwsh -NoProfile -File .\99-系统\脚本\personal-baseline\Invoke-PersonalBaselinePipeline.ps1 -Mode full-local

# 完整演练，不写任何文件
pwsh -NoProfile -File .\99-系统\脚本\personal-baseline\Invoke-PersonalBaselinePipeline.ps1 -Mode full-local -NoWrite

# 运行独立临时库测试
pwsh -NoProfile -File .\99-系统\脚本\personal-baseline\tests\Run-Tests.ps1
```

需要核验外部链接时显式追加 `-CheckExternal`。HTTP 403、429 等访问限制只记录为信息，不自动判断来源失效。

## 运行模式

| 模式 | 正式内容写入 | 候选区写入 | 报告写入 | 用途 |
|---|---:|---:|---:|---|
| `audit` | 否 | 否 | 是 | 结构、断链、主张、合同和内容质量审计 |
| `verify` | 否 | 否 | 是 | 审计并对比内容基线 |
| `safe-fix` | 仅确定性修复 | 否 | 是 | 清理 BOM、非语义行尾空白和表格分隔行 |
| `candidate` | 否 | 是 | 是 | 生成语义修复、重复内容和来源阻断候选 |
| `full-local` | 仅确定性修复 | 是 | 是 | 完整本地维护与终验 |

`-NoWrite` 会让所有模式保持只读，包括报告、当前清单和候选文件。

## 写入边界

- 正式内容的自动写入只允许发生在 `path-allowlist.json` 指定的安全修复目录。
- 来源、真实运行记录、合同 schema、主张台账、治理计划和冻结书稿始终受保护。
- 语义优化只输出到 `08-媒体与产品/产品/个人基线/00-缓冲区/自动化候选/`。
- 报告与清单只输出到 `99-系统/元数据/personal-baseline/`。
- 安全修复前保存内存快照；后置审计或基线门禁失败时恢复原字节。

## 产物

- `current-manifest.json`：当前正式内容清单与 SHA-256 指纹。
- `baselines/`：每次显式 `-InitializeBaseline -Force` 前自动保存的旧基线。
- `reports/latest-report.json`：机器可读终验报告。
- `reports/latest-report.md`：人工可读终验报告。
- `review-manifest.json`：全部语义候选的汇总与确定性指纹。
- `semantic-fixes/candidates.json`：需要人工判断的内容修复候选。
- `merged-drafts/duplicates.json`：精确重复段落候选。
- `source-blocked/issues.json`：证据不足或真实性阻断项。

## 人工保留事项

以下动作不进入无人值守执行：真实性确认、证据等级升级、删除、发布、定价和商业承诺。候选经人工确认后，应单独修改正式内容并重新运行 `full-local`。
