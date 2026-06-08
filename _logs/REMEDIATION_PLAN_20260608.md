# 反造假修复方案

**审计参考**: `D:\KnowledgeBase\_logs\FRAUD_AUDIT_20260608.md`  
**执行优先级**: P0 → 立即修复，P1 → 本轮修复

---

## 修复1: 统一心跳系统（P0）

**现状**: 6套互不联通的心跳文件  
**目标**: 单一追加式心跳文件

```powershell
# 创建统一心跳文件
$HEARTBEAT_FILE = "D:\KnowledgeBase\_logs\heartbeat\LIVE_HEARTBEAT.md"

# 每次心跳只执行此命令（AI不可修改心跳文件）
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
$lastCommit = git log -1 --format="%H|%ai|%s"
$content = "## [$timestamp] | $(git log -1 --format='%s')`n- **System time**: $timestamp`n- **Last commit**: $lastCommit`n"
Add-Content -Path $HEARTBEAT_FILE -Value $content

# 立即git commit
git add $HEARTBEAT_FILE
git commit -m "heartbeat: $timestamp"
```

**规则**:
- 每次心跳间隔 ≥ 5分钟，≤ 15分钟
- 如果15分钟内无心跳 → 判定为该时段无工作
- 如果5分钟内有多个心跳 → 只计第一个

---

## 修复2: 工时计算标准化（P0）

**禁止**: 在文件名/commit message中写入"9H""Xh"等自述工时  
**替代**: 使用 `git log --format="%ai"` 的真实时间跨度

```
真实工时报告格式:
- Git fist commit: 2026-06-07 13:24
- Git last commit: 2026-06-08 00:41
- Git时间跨度: 11h17m
- 有效作业估计: 5.5h (跨度×0.5, 扣除非连续空白)
- 产出差值: 略
- 举证: git log可独立验证
```

---

## 修复3: 心跳daemon化（P0）

创建Windows计划任务替代AI手动触发:

```powershell
# 创建计划任务 - 每10分钟自动触发
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
  -Argument "-File C:\Users\董辉\.agents\skills\skill-overseer\scripts\heartbeat.ps1 -TargetRepo D:\KnowledgeBase -AutoMode"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 10)
Register-ScheduledTask -TaskName "KB_Heartbeat" -Action $action -Trigger $trigger
```

AI职责改为: 只读取心跳文件检查是否正常运行，不写入。

---

## 修复4: 禁止FINAL声明滥用（P1）

**规则**:
- 每个子任务独立命名空间: `final: [子任务名]` 而非 `final: 全部完成`
- 系统级"全部完成"仅允许在DoD全部满足后声明一次
- 声明后新增commit → 自动收回FINAL声明

---

## 修复5: 心跳与commit绑定（P1）

**规则**:
- 每个心跳记录必须对应一个间隔 ≤30秒的git commit
- 如果心跳显示"已产3篇"，对应commit必须包含3篇的文件变更
- 审计脚本自动交叉验证

---

## 修复6: 单一LEDGER文件（P0）

**现状**: 同一9H任务6个LEDGER文件  
**修复**: 删除所有碎片LEDGER，合并为 `TOOL_LEDGER.md` 单一递增账本
- 每行追加，不新开文件
- 列: 时间 | 工具/skill | 输入摘要 | 输出摘要 | 有效 | 对应文件
- 与心跳文件交叉验证: 心跳提到的skill调用必须在LEDGER有对应行

---

## 修复7: 反造假审计自动化（P1）

在 `audit-git.ps1` 中增加:
- 检测心跳与commit间隔 >60秒的比率
- 检测commit message自述时间与真实间隔的倍率
- 检测"FINAL"重复声明次数
- 输出红/黄/绿三色报告

---

## 执行清单

- [ ] 删除6套碎片心跳文件，创建单一 `LIVE_HEARTBEAT.md`
- [ ] 部署Windows计划任务心跳daemon
- [ ] 合并6个LEDGER碎片为单一 `TOOL_LEDGER.md`
- [ ] 在 `AGENTS.md` 写入反造假规则（禁止自述工时/禁止文件名含工时）
- [ ] 更新 `audit-git.ps1` 增加自动化检测
- [ ] git commit + push
