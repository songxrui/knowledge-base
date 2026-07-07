<#
.SYNOPSIS
    批量渲染：扫描文件夹内所有txt脚本 → 逐一渲染为抖音视频
.DESCRIPTION
    遍历指定文件夹中的所有 .txt/.md 脚本文件，
    逐一调用 HyperFrames 渲染为不露脸知识口播视频。
    支持断点续传、并行渲染、失败重试。
.PARAMETER InputDir
    脚本文件夹路径。默认: D:\KnowledgeBase\01-内容生产\进行中
.PARAMETER Filter
    文件名过滤模式（支持通配符）。默认: "抖音脚本_*.md"
    示例: "第1期_*.md" / "day*.txt" / "*"
.PARAMETER Style
    视频风格模板。可选值: minimal-knowledge (默认), narrative-dark, data-visual
.PARAMETER Quality
    渲染质量。可选值: draft (快速预览), high (最终发布)。批量建议用 draft
.PARAMETER OutputDir
    视频输出目录。默认: D:\videos\douyin\renders
.PARAMETER Parallel
    并行渲染数量。默认: 1 (HyperFrames 建议串行以避免资源争抢)
.PARAMETER MaxRetries
    单个脚本失败重试次数。默认: 1
.PARAMETER DryRun
    仅列出待处理脚本，不实际渲染
.PARAMETER ResumeFrom
    从指定脚本文件名开始（跳过之前的）。用于断点续传。
    示例: "抖音脚本_第3批_7条.md"
.EXAMPLE
    .\batch-render.ps1
    渲染进行中目录下所有"抖音脚本_*.md"
.EXAMPLE
    .\batch-render.ps1 -Filter "第2期_*.md" -Quality high -Style data-visual
    高质量渲染第2期所有脚本
.EXAMPLE
    .\batch-render.ps1 -DryRun
    仅列出待处理脚本清单
.EXAMPLE
    .\batch-render.ps1 -ResumeFrom "抖音脚本_第4批_8条.md"
    从第4批开始断点续传
.NOTES
    版本: v1.0 | 创建: 2026-07-02
    依赖: new-douyin.ps1 或可直接调用 HyperFrames CLI
    建议: 批量渲染前先用 -DryRun 确认脚本清单
    注意: 每条视频渲染约 2-5 分钟，批量渲染可能耗时较长
#>

param(
    [Parameter(HelpMessage = "脚本文件夹路径")]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$InputDir = "D:\KnowledgeBase\01-内容生产\进行中",

    [Parameter(HelpMessage = "文件名过滤模式")]
    [string]$Filter = "抖音脚本_*.md",

    [Parameter(HelpMessage = "视频风格模板")]
    [ValidateSet("minimal-knowledge", "narrative-dark", "data-visual")]
    [string]$Style = "minimal-knowledge",

    [Parameter(HelpMessage = "渲染质量")]
    [ValidateSet("draft", "high")]
    [string]$Quality = "draft",

    [Parameter(HelpMessage = "视频输出目录")]
    [string]$OutputDir = "D:\videos\douyin\renders",

    [Parameter(HelpMessage = "并行渲染数量")]
    [ValidateRange(1, 4)]
    [int]$Parallel = 1,

    [Parameter(HelpMessage = "失败重试次数")]
    [ValidateRange(0, 3)]
    [int]$MaxRetries = 1,

    [Parameter(HelpMessage = "仅列出脚本")]
    [switch]$DryRun,

    [Parameter(HelpMessage = "断点续传: 从指定文件名开始")]
    [string]$ResumeFrom
)

# ============================================================
# 配置区
# ============================================================
$ErrorActionPreference = "Continue"
$ScriptBaseDir = "D:\videos\douyin\projects"
$ReportPath = "D:\KnowledgeBase\.dbs\scripts\batch-render-report.md"
$DateStr = Get-Date -Format "yyyyMMdd"
$StartTime = Get-Date

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

function Write-Progress-Bar {
    param([int]$Current, [int]$Total, [string]$Label)
    $percent = [Math]::Round($Current / $Total * 100)
    $barLength = 30
    $filled = [Math]::Round($barLength * $Current / $Total)
    $empty = $barLength - $filled
    $bar = "[" + ("█" * $filled) + ("░" * $empty) + "]"
    Write-Host "`r  $bar ${percent}% ($Current/$Total) $Label" -NoNewline -ForegroundColor Cyan
}

# ============================================================
# 0. 环境自检
# ============================================================
Write-Host ""
Write-Host "╔══════════════════════════════════════╗"
Write-Host "║   董辉批量视频渲染器 v1.0           ║"
Write-Host "╚══════════════════════════════════════╝"
Write-Host ""

Write-Step "0. 环境自检..."

# 检查 Node / FFmpeg / HyperFrames
$nodeOk = try { $v = node --version 2>&1; $v -replace 'v','' -as [version] -ge [version]"22.0.0" } catch { $false }
$ffmpegOk = try { $null = ffmpeg -version 2>&1; $true } catch { $false }
$hfOk = try { $null = npx hyperframes --version 2>&1; $LASTEXITCODE -eq 0 } catch { $false }

if (-not $nodeOk) { Write-Error-Custom "Node.js >= 22 未安装"; exit 1 }
if (-not $ffmpegOk) { Write-Error-Custom "FFmpeg 未安装"; exit 1 }
if (-not $hfOk) { Write-Warn "HyperFrames 未检测到，将尝试自动安装" }
Write-OK "Node.js / FFmpeg / HyperFrames 检测完成"

# 确认输出目录
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
}
if (-not (Test-Path $ScriptBaseDir)) {
    New-Item -ItemType Directory -Force -Path $ScriptBaseDir | Out-Null
}

# ============================================================
# 1. 扫描脚本
# ============================================================
Write-Step "1. 扫描脚本..."

$allScripts = Get-ChildItem -Path $InputDir -Filter $Filter -File |
    Sort-Object Name |
    ForEach-Object { $_.FullName }

if ($allScripts.Count -eq 0) {
    Write-Error-Custom "未找到匹配的脚本文件"
    Write-Host "  搜索路径: $InputDir\$Filter"
    Write-Host "  提示: 用 -Filter 参数指定其他模式, 如 '*抖音*.md'"
    exit 1
}

Write-OK "找到 $($allScripts.Count) 个脚本"

# 断点续传
$scripts = $allScripts
if ($ResumeFrom) {
    $skipMode = $true
    $filtered = @()
    foreach ($s in $scripts) {
        $name = Split-Path $s -Leaf
        if (-not $skipMode) {
            $filtered += $s
        }
        if ($name -eq $ResumeFrom) {
            $skipMode = $false
            $filtered += $s
        }
    }
    if ($filtered.Count -eq 0) {
        Write-Error-Custom "未找到断点文件: $ResumeFrom"
        exit 1
    }
    $skipped = $scripts.Count - $filtered.Count
    Write-OK "断点续传: 跳过 $skipped 个，剩余 $($filtered.Count) 个"
    $scripts = $filtered
}

# 打印脚本清单
Write-Host ""
Write-Host "  ─── 待渲染清单 ($($scripts.Count) 个) ───" -ForegroundColor DarkGray
for ($i = 0; $i -lt $scripts.Count; $i++) {
    $name = Split-Path $scripts[$i] -Leaf
    $idx = $i + 1
    Write-Host "  $idx. $name" -ForegroundColor Gray
}
Write-Host ""

if ($DryRun) {
    Write-Host "  ℹ  DryRun 模式 — 仅列出脚本，不渲染。" -ForegroundColor Yellow
    Write-Host "  移除 -DryRun 参数以开始渲染。" -ForegroundColor Yellow
    exit 0
}

# 确认
Write-Warn "将渲染 $($scripts.Count) 个视频 (风格: $Style | 质量: $Quality)"
$confirm = Read-Host "  确认开始? (y/N)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "已取消。"
    exit 0
}

# ============================================================
# 2. 批量渲染
# ============================================================
Write-Step "2. 开始批量渲染..."

$results = @()
$total = $scripts.Count
$success = 0
$failed = 0

for ($i = 0; $i -lt $total; $i++) {
    $scriptPath = $scripts[$i]
    $scriptName = Split-Path $scriptPath -Leaf
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($scriptPath)
    $safeName = ($baseName -replace '[^a-zA-Z0-9\u4e00-\u9fff_-]', '-').Substring(0, [Math]::Min(40, $baseName.Length))
    $idx = $i + 1

    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Step "[$idx/$total] $scriptName"
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

    $renderSuccess = $false
    $attempt = 0

    while (-not $renderSuccess -and $attempt -le $MaxRetries) {
        $attempt++
        if ($attempt -gt 1) {
            Write-Warn "重试 $attempt/$MaxRetries..."
        }

        try {
            # 创建 HyperFrames 项目
            $projectDir = "$ScriptBaseDir\${DateStr}-${safeName}-batch${idx}"

            # 如果项目已存在，清理
            if (Test-Path $projectDir) {
                Remove-Item -Recurse -Force $projectDir
            }

            Write-Host "  创建项目..."
            $initResult = npx hyperframes init $projectDir --non-interactive --example=blank 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw "项目创建失败: $initResult"
            }

            # 写入脚本
            $scriptContent = Get-Content $scriptPath -Raw -Encoding UTF8
            $visibleTextDir = "$projectDir\capture\extracted"
            if (-not (Test-Path $visibleTextDir)) {
                New-Item -ItemType Directory -Force -Path $visibleTextDir | Out-Null
            }
            $scriptContent | Out-File -FilePath "$visibleTextDir\visible-text.txt" -Encoding utf8

            # 检查链
            Push-Location $projectDir
            try {
                Write-Host "  Lint..."
                npx hyperframes lint 2>&1 | Out-Null
                if ($LASTEXITCODE -ne 0) { throw "Lint 失败" }

                Write-Host "  Validate..."
                npx hyperframes validate 2>&1 | Out-Null
                if ($LASTEXITCODE -ne 0) { throw "Validate 失败" }

                Write-Host "  Inspect..."
                npx hyperframes inspect 2>&1 | Out-Null
                # inspect 警告不阻塞

                # 渲染
                $outputFile = "$OutputDir\douyin_${DateStr}_${safeName}.mp4"
                Write-Host "  渲染中..."
                npx hyperframes render --skill=faceless-explainer --style $Style --quality $Quality --output $outputFile -- --width=1080 --height=1920 2>&1 | Out-Null

                if ($LASTEXITCODE -ne 0 -or -not (Test-Path $outputFile)) {
                    throw "渲染失败或输出文件不存在"
                }

                $fileSize = [Math]::Round((Get-Item $outputFile).Length / 1MB, 1)
                Write-OK "完成 → $outputFile (${fileSize}MB)"
                $renderSuccess = $true
                $success++
            } finally {
                Pop-Location
            }
        } catch {
            Write-Error-Custom "尝试 $attempt 失败: $_"
            if ($attempt -gt $MaxRetries) {
                $failed++
            }
        }
    }

    $results += [PSCustomObject]@{
        Index    = $idx
        Script   = $scriptName
        Success  = $renderSuccess
        Attempts = $attempt
        Time     = Get-Date -Format "HH:mm:ss"
    }

    # 进度条
    $elapsed = [Math]::Round(((Get-Date) - $StartTime).TotalMinutes, 1)
    $avgMin = if ($idx -gt 0) { [Math]::Round($elapsed / $idx, 1) } else { 0 }
    $etaMin = if ($avgMin -gt 0) { [Math]::Round(($total - $idx) * $avgMin, 1) } else { "?" }
    Write-Host "  ⏱ 已用 ${elapsed}min | 预估剩余 ${etaMin}min | 成功 $success / 失败 $failed"
}

# ============================================================
# 3. 生成报告
# ============================================================
Write-Step "3. 生成批量渲染报告..."

$EndTime = Get-Date
$totalMinutes = [Math]::Round(($EndTime - $StartTime).TotalMinutes, 1)
$totalHours = [Math]::Round($totalMinutes / 60, 1)

$reportContent = @"
# 批量渲染报告

> 日期: $(Get-Date -Format 'yyyy-MM-dd HH:mm') | 风格: $Style | 质量: $Quality

---

## 📊 总体统计

| 指标 | 数值 |
|------|:----:|
| 脚本总数 | $total |
| 成功 | $success |
| 失败 | $failed |
| 成功率 | $([Math]::Round($success / $total * 100, 1))% |
| 总耗时 | ${totalMinutes}min (${totalHours}h) |
| 输出目录 | $OutputDir |

---

## 📋 详细结果

| # | 脚本 | 状态 | 重试 | 时间 |
|---|------|:----:|:----:|------|
$(
    ($results | ForEach-Object {
        $status = if ($_.Success) { "✅" } else { "❌" }
        "| $($_.Index) | $($_.Script) | $status | $($_.Attempts) | $($_.Time) |"
    }) -join "`n"
)

---

## 📝 备注

- 输入目录: $InputDir
- 过滤模式: $Filter
- 项目目录: $ScriptBaseDir

> 失败项请手动检查错误原因。常见问题: 脚本格式、字体缺失、FFmpeg 异常。
"@

$reportContent | Out-File -FilePath $ReportPath -Encoding utf8

# ============================================================
# 完成
# ============================================================
Write-Host ""
Write-Host "╔══════════════════════════════════════╗"
Write-Host "║   ✅ 批量渲染完成!                  ║"
Write-Host "╚══════════════════════════════════════╝"
Write-Host ""
Write-Host "  📹 成功: $success / $total" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Yellow" })
Write-Host "  ❌ 失败: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Gray" })
Write-Host "  ⏱ 耗时: ${totalMinutes}min" -ForegroundColor Cyan
Write-Host "  📊 报告: $ReportPath" -ForegroundColor Green
Write-Host "  📁 输出: $OutputDir" -ForegroundColor Green
Write-Host ""

if ($failed -gt 0) {
    Write-Host "  失败列表:" -ForegroundColor Red
    $results | Where-Object { -not $_.Success } | ForEach-Object {
        Write-Host "    - $($_.Script) (重试 $($_.Attempts) 次)" -ForegroundColor Red
    }
    Write-Host ""
}
