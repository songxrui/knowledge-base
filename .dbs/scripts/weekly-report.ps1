<#
.SYNOPSIS
    周报生成器：自动读取CSV → 生成本周数据报告
.DESCRIPTION
    从数据统计CSV中读取指定时间范围的数据，
    按平台分组统计，生成六格复盘 + Top/Bottom 分析，
    输出 Markdown 格式的完整周报。
.PARAMETER CsvPath
    数据统计CSV路径。默认: D:\KnowledgeBase\05-数据统计\数据统计表.csv
.PARAMETER OutputPath
    周报输出路径。默认: D:\KnowledgeBase\04-方法论沉淀\周报\
.PARAMETER WeekOffset
    周偏移: 0=本周, 1=上周, 2=上上周。默认: 0
.PARAMETER StartDate
    自定义起始日期 (yyyy-MM-dd)。覆盖 WeekOffset
.PARAMETER EndDate
    自定义结束日期 (yyyy-MM-dd)。覆盖 WeekOffset
.PARAMETER OpenReport
    生成后自动打开报告文件
.EXAMPLE
    .\weekly-report.ps1
    生成本周默认周报
.EXAMPLE
    .\weekly-report.ps1 -WeekOffset 1 -OpenReport
    生成上周周报并打开
.EXAMPLE
    .\weekly-report.ps1 -StartDate "2026-06-01" -EndDate "2026-06-07"
    自定义日期范围
.NOTES
    版本: v1.0 | 创建: 2026-07-02
    依赖: 数据统计表.csv (UTF-8 编码)
    周报模板: 六格复盘 + Top/Bottom 分析 + 关键发现
#>

param(
    [Parameter(HelpMessage = "CSV文件路径")]
    [string]$CsvPath = "D:\KnowledgeBase\05-数据统计\数据统计表.csv",

    [Parameter(HelpMessage = "报告输出目录")]
    [string]$OutputDir = "D:\KnowledgeBase\04-方法论沉淀\周报",

    [Parameter(HelpMessage = "周偏移 (0=本周,1=上周)")]
    [ValidateRange(0, 4)]
    [int]$WeekOffset = 0,

    [Parameter(HelpMessage = "自定义开始日期 (yyyy-MM-dd)")]
    [string]$StartDate,

    [Parameter(HelpMessage = "自定义结束日期 (yyyy-MM-dd)")]
    [string]$EndDate,

    [Parameter(HelpMessage = "生成后打开报告")]
    [switch]$OpenReport
)

# ============================================================
# 配置区
# ============================================================
$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Message" -ForegroundColor Cyan
}

function Write-OK {
    param([string]$Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  ⚠ $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "  ✗ $Message" -ForegroundColor Red
}

# ============================================================
# 0. 确定日期范围
# ============================================================
Write-Host ""
Write-Host "╔══════════════════════════════════════╗"
Write-Host "║   董辉自媒体周报生成器 v1.0         ║"
Write-Host "╚══════════════════════════════════════╝"
Write-Host ""

Write-Step "0. 确定日期范围..."

if ($StartDate -and $EndDate) {
    $rangeStart = [datetime]::ParseExact($StartDate, "yyyy-MM-dd", $null)
    $rangeEnd = [datetime]::ParseExact($EndDate, "yyyy-MM-dd", $null)
    Write-OK "自定义范围: $StartDate → $EndDate"
} else {
    $today = Get-Date
    $daysToMonday = if ($today.DayOfWeek -eq [DayOfWeek]::Sunday) { 6 } else { [int]$today.DayOfWeek - 1 }
    $monday = $today.AddDays(-$daysToMonday - (7 * $WeekOffset)).Date
    $sunday = $monday.AddDays(6).Date
    $rangeStart = $monday
    $rangeEnd = $sunday
    Write-OK "第 $($WeekOffset + 1) 周前: $($monday.ToString('yyyy-MM-dd')) → $($sunday.ToString('yyyy-MM-dd'))"
}

$WeekLabel = "$($rangeStart.ToString('MM.dd')) - $($rangeEnd.ToString('MM.dd'))"
$WeekNum = [int](($rangeStart - (Get-Date "2026-01-05")).TotalDays / 7) + 1

# ============================================================
# 1. 读取 CSV
# ============================================================
Write-Step "1. 读取数据..."

if (-not (Test-Path $CsvPath)) {
    Write-Error-Custom "CSV 文件不存在: $CsvPath"
    exit 1
}

$csvContent = Get-Content $CsvPath -Encoding UTF8 | Where-Object { $_.Trim() -ne "" -and $_ -notmatch '^#' }
if ($csvContent.Count -le 1) {
    Write-Warn "CSV 中没有数据行（仅表头或空文件）"
    $records = @()
} else {
    $headers = $csvContent[0].Split(',')
    $records = $csvContent[1..($csvContent.Count - 1)] | ForEach-Object {
        $values = $_ -split ','
        $record = @{}
        for ($i = 0; $i -lt [Math]::Min($headers.Count, $values.Count); $i++) {
            $record[$headers[$i]] = $values[$i]
        }
        [PSCustomObject]$record
    }
}

Write-OK "总计 $($records.Count) 条记录"

# ============================================================
# 2. 过滤本周数据
# ============================================================
Write-Step "2. 筛选时间范围..."

$weekRecords = $records | Where-Object {
    try {
        $recordDate = [datetime]::ParseExact($_.'发布日期', "yyyy-MM-dd", $null)
        $recordDate -ge $rangeStart -and $recordDate -le $rangeEnd
    } catch {
        $false
    }
}

Write-OK "本周记录: $($weekRecords.Count) 条"

if ($weekRecords.Count -eq 0) {
    Write-Host ""
    Write-Warn "本周没有数据记录！将生成空报告模板。"
}

# ============================================================
# 3. 平台分组统计
# ============================================================
Write-Step "3. 计算统计数据..."

$douyinRecords = $weekRecords | Where-Object { $_.'平台' -match '抖音|douyin' }
$wechatRecords = $weekRecords | Where-Object { $_.'平台' -match '公众|wechat' }

# 抖音统计
$douyinStats = @{
    发布数 = $douyinRecords.Count
    总播放  = ($douyinRecords | ForEach-Object { try { [int]$_.'阅读量' } catch { 0 } } | Measure-Object -Sum).Sum
    总点赞  = ($douyinRecords | ForEach-Object { try { [int]$_.'点赞' } catch { 0 } } | Measure-Object -Sum).Sum
    总评论  = ($douyinRecords | ForEach-Object { try { [int]$_.'评论' } catch { 0 } } | Measure-Object -Sum).Sum
    总转发  = ($douyinRecords | ForEach-Object { try { [int]$_.'转发' } catch { 0 } } | Measure-Object -Sum).Sum
    总收藏  = ($douyinRecords | ForEach-Object { try { [int]$_.'收藏' } catch { 0 } } | Measure-Object -Sum).Sum
    新增粉丝 = ($douyinRecords | ForEach-Object { try { [int]$_.'新增关注' } catch { 0 } } | Measure-Object -Sum).Sum
}

# 公众号统计
$wechatStats = @{
    发布数 = $wechatRecords.Count
    总阅读  = ($wechatRecords | ForEach-Object { try { [int]$_.'阅读量' } catch { 0 } } | Measure-Object -Sum).Sum
    总点赞  = ($wechatRecords | ForEach-Object { try { [int]$_.'点赞' } catch { 0 } } | Measure-Object -Sum).Sum
    总评论  = ($wechatRecords | ForEach-Object { try { [int]$_.'评论' } catch { 0 } } | Measure-Object -Sum).Sum
    总转发  = ($wechatRecords | ForEach-Object { try { [int]$_.'转发' } catch { 0 } } | Measure-Object -Sum).Sum
    总收藏  = ($wechatRecords | ForEach-Object { try { [int]$_.'收藏' } catch { 0 } } | Measure-Object -Sum).Sum
    在看数   = ($wechatRecords | ForEach-Object { try { [int]$_.'在看' } catch { 0 } } | Measure-Object -Sum).Sum
}

Write-OK "抖音: $($douyinStats.发布数) 条, 播放 $($douyinStats.总播放)"
Write-OK "公众号: $($wechatStats.发布数) 条, 阅读 $($wechatStats.总阅读)"

# ============================================================
# 4. 互动率计算
# ============================================================
if ($douyinStats.总播放 -gt 0) {
    $douyinEngagement = ($douyinStats.总点赞 + $douyinStats.总评论 + $douyinStats.总收藏) / $douyinStats.总播放 * 100
    $douyinEngagement = [Math]::Round($douyinEngagement, 1)
} else { $douyinEngagement = 0 }

if ($wechatStats.总阅读 -gt 0) {
    $wechatEngagement = ($wechatStats.总点赞 + $wechatStats.总评论 + $wechatStats.总转发) / $wechatStats.总阅读 * 100
    $wechatEngagement = [Math]::Round($wechatEngagement, 1)
} else { $wechatEngagement = 0 }

# ============================================================
# 5. Top/Bottom 排序
# ============================================================
Write-Step "4. 排序分析..."

function Get-TopBottom {
    param($records, $sortField, $topN = 3)

    $sorted = $records | Sort-Object { try { [int]$_.$sortField } catch { 0 } } -Descending
    $top = $sorted | Select-Object -First $topN
    $bottom = $sorted | Select-Object -Last $topN | Sort-Object { try { [int]$_.$sortField } catch { 0 } }

    return @{ Top = $top; Bottom = $bottom }
}

$dyTopBottom = Get-TopBottom -records $douyinRecords -sortField "阅读量"
$wxTopBottom = Get-TopBottom -records $wechatRecords -sortField "阅读量"

# ============================================================
# 6. 生成报告
# ============================================================
Write-Step "5. 生成周报 Markdown..."

# 生成 Top/Bottom 行
$dyTopLines = if ($dyTopBottom.Top.Count -gt 0) {
    ($dyTopBottom.Top | ForEach-Object { "1. $($_.'内容标题') — 播放 $($_.'阅读量')" }) -join "`n"
} else { "1. (无数据)" }

$dyBottomLines = if ($dyTopBottom.Bottom.Count -gt 0) {
    ($dyTopBottom.Bottom | ForEach-Object { "1. $($_.'内容标题') — 播放 $($_.'阅读量')" }) -join "`n"
} else { "1. (无数据)" }

$wxTopLines = if ($wxTopBottom.Top.Count -gt 0) {
    ($wxTopBottom.Top | ForEach-Object { "1. $($_.'内容标题') — 阅读 $($_.'阅读量')" }) -join "`n"
} else { "1. (无数据)" }

$wxBottomLines = if ($wxTopBottom.Bottom.Count -gt 0) {
    ($wxTopBottom.Bottom | ForEach-Object { "1. $($_.'内容标题') — 阅读 $($_.'阅读量')" }) -join "`n"
} else { "1. (无数据)" }

$reportDate = Get-Date -Format "yyyy-MM-dd HH:mm"
$report = @"
# 📊 第 ${WeekNum} 周复盘 ($WeekLabel)

> 自动生成于: $reportDate

---

## 📈 本周数据概览

| 指标 | 抖音 | 公众号 |
|------|:----:|:-----:|
| 发布数 | $($douyinStats.发布数) | $($wechatStats.发布数) |
| 总播放/阅读 | $($douyinStats.总播放) | $($wechatStats.总阅读) |
| 总点赞 | $($douyinStats.总点赞) | $($wechatStats.总点赞) |
| 总评论 | $($douyinStats.总评论) | $($wechatStats.总评论) |
| 总转发/分享 | $($douyinStats.总转发) | $($wechatStats.总转发) |
| 总收藏 | $($douyinStats.总收藏) | $($wechatStats.总收藏) |
| 新增粉丝 | $($douyinStats.新增粉丝) | — |
| 互动率 | ${douyinEngagement}% | ${wechatEngagement}% |

---

## 🔝 抖音 Top 3 内容

$dyTopLines

## 🔻 抖音 Bottom 3 内容

$dyBottomLines

---

## 🔝 公众号 Top 3 内容

$wxTopLines

## 🔻 公众号 Bottom 3 内容

$wxBottomLines

---

## 🧠 六格复盘

| 维度 | 内容 |
|------|------|
| **发布条数** | 抖音 $($douyinStats.发布数) + 公众号 $($wechatStats.发布数) = $($douyinStats.发布数 + $wechatStats.发布数) |
| **总播放/阅读** | 抖音 $($douyinStats.总播放) + 公众号 $($wechatStats.总阅读) |
| **平均互动率** | 抖音 ${douyinEngagement}% / 公众号 ${wechatEngagement}% |
| **粉丝净增** | 抖音 +$($douyinStats.新增粉丝) |
| **最高内容** | (见 Top 1) |
| **最低内容** | (见 Bottom 1) |

---

## ✅ 做得好的

- 

## ⚠️ 需要改进的

- 

## 🧪 下周实验

- 

---

> 📝 本报告由 weekly-report.ps1 自动生成 | 原始数据: $CsvPath
"@

# ============================================================
# 7. 输出报告
# ============================================================
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
}

$reportFileName = "周报_第${WeekNum}周_$($rangeStart.ToString('yyyyMMdd'))-$($rangeEnd.ToString('yyyyMMdd')).md"
$reportPath = "$OutputDir\$reportFileName"
$report | Out-File -FilePath $reportPath -Encoding utf8

Write-OK "周报已生成: $reportPath"

# ============================================================
# 完成
# ============================================================
Write-Host ""
Write-Host "╔══════════════════════════════════════╗"
Write-Host "║   ✅ 周报生成完成!                  ║"
Write-Host "╚══════════════════════════════════════╝"
Write-Host ""
Write-Host "  📊 报告: $reportPath" -ForegroundColor Green
Write-Host "  📅 范围: $WeekLabel" -ForegroundColor Green
Write-Host "  📈 数据: $($weekRecords.Count) 条记录" -ForegroundColor Green
Write-Host ""
Write-Host "  请手动填写:" -ForegroundColor Yellow
Write-Host "    - 做得好的 / 需要改进的 / 下周实验"
Write-Host "    - 关键发现与洞察"
Write-Host ""

if ($OpenReport -and (Test-Path $reportPath)) {
    Start-Process $reportPath
}

# 同时输出到控制台
Write-Host "═══════ 报告预览 ═══════" -ForegroundColor DarkGray
Write-Host $report
