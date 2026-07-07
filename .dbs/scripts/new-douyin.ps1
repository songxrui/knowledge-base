<#
.SYNOPSIS
    一键发布抖音视频：输入脚本txt → 自动生成视频 + 封面提示词 + 记录CSV
.DESCRIPTION
    将口播脚本txt自动转化为HyperFrames渲染的不露脸知识视频。
    流程: 校验脚本 → 创建HyperFrames项目 → 质量检查 → 渲染 → 记录CSV
.PARAMETER ScriptPath
    脚本txt文件的完整路径。文件编码需为UTF-8。
    脚本第一行自动识别为视频标题。
.PARAMETER Style
    视频风格模板。可选值: minimal-knowledge (白板讲解,默认), narrative-dark (故事叙述), data-visual (数据可视)
.PARAMETER Quality
    渲染质量。可选值: draft (快速预览,默认), high (最终发布)
.PARAMETER SkipRender
    跳过渲染步骤，仅做质检和CSV记录（用于预检）
.PARAMETER OutputDir
    视频输出目录。默认: D:\videos\douyin\renders
.PARAMETER NoCsv
    跳过CSV记录步骤
.EXAMPLE
    .\new-douyin.ps1 -ScriptPath "D:\KnowledgeBase\01-内容生产\进行中\抖音脚本_第1批_3条.md"
    用默认设置（白板+draft）生成视频
.EXAMPLE
    .\new-douyin.ps1 -ScriptPath ".\script.txt" -Style narrative-dark -Quality high
    用故事叙述风格高质量渲染
.EXAMPLE
    .\new-douyin.ps1 -ScriptPath ".\script.txt" -SkipRender
    仅做质量检查和CSV记录，不渲染视频
.NOTES
    版本: v1.0 | 创建: 2026-07-02
    依赖: Node.js >= 22, FFmpeg, HyperFrames CLI
    前置检查: 运行前确认 npx hyperframes doctor --json 全绿
#>

param(
    [Parameter(Mandatory = $true, HelpMessage = "脚本txt文件路径")]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$ScriptPath,

    [Parameter(HelpMessage = "视频风格模板")]
    [ValidateSet("minimal-knowledge", "narrative-dark", "data-visual")]
    [string]$Style = "minimal-knowledge",

    [Parameter(HelpMessage = "渲染质量")]
    [ValidateSet("draft", "high")]
    [string]$Quality = "draft",

    [Parameter(HelpMessage = "跳过渲染")]
    [switch]$SkipRender,

    [Parameter(HelpMessage = "视频输出目录")]
    [string]$OutputDir = "D:\videos\douyin\renders",

    [Parameter(HelpMessage = "跳过CSV记录")]
    [switch]$NoCsv
)

# ============================================================
# 配置区
# ============================================================
$ErrorActionPreference = "Stop"
$ScriptBaseDir = "D:\videos\douyin\projects"
$CsvPath = "D:\KnowledgeBase\05-数据统计\数据统计表.csv"
$CoverPromptOutput = "D:\KnowledgeBase\01-内容生产\进行中\封面提示词_自动生成.md"
$DateStr = Get-Date -Format "yyyyMMdd"
$TimeStr = Get-Date -Format "HH:mm"
$ProjectDate = Get-Date -Format "yyyy-MM-dd"
$ScriptName = [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath)
$SafeProjectName = ($ScriptName -replace '[^a-zA-Z0-9\u4e00-\u9fff_-]', '-').Substring(0, [Math]::Min(40, $ScriptName.Length))

# ============================================================
# 函数定义
# ============================================================

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

function Test-Command {
    param([string]$Cmd)
    try {
        $null = Get-Command $Cmd -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# ============================================================
# 0. 环境自检
# ============================================================
Write-Host ""
Write-Host "╔══════════════════════════════════════╗"
Write-Host "║   董辉抖音一键发布 v1.0              ║"
Write-Host "╚══════════════════════════════════════╝"
Write-Host ""

Write-Step "0. 环境自检..."

# 检查 Node.js
$nodeVersion = try { node --version 2>&1 } catch { $null }
if (-not $nodeVersion -or ($nodeVersion -replace 'v','' -as [version]) -lt [version]"22.0.0") {
    Write-Error-Custom "Node.js >= 22 未安装或版本过低 (当前: $nodeVersion)"
    Write-Host "  请安装: winget install OpenJS.NodeJS.LTS"
    exit 1
}
Write-OK "Node.js $nodeVersion"

# 检查 FFmpeg
$ffmpegVersion = try { ffmpeg -version 2>&1 | Select-Object -First 1 } catch { $null }
if (-not $ffmpegVersion) {
    Write-Error-Custom "FFmpeg 未安装或不在 PATH 中"
    Write-Host "  请安装: winget install ffmpeg 然后重开 PowerShell"
    exit 1
}
Write-OK "FFmpeg 已就绪"

# 检查 HyperFrames
$hfCheck = try { npx hyperframes --version 2>&1 } catch { $null }
if ($LASTEXITCODE -ne 0 -and -not $hfCheck) {
    Write-Warn "HyperFrames 未检测到，尝试安装..."
    npm install -g hyperframes 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "HyperFrames 安装失败"
        Write-Host "  请手动运行: npm install -g hyperframes"
        exit 1
    }
}
Write-OK "HyperFrames 已就绪"

# 确认输出目录
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
    Write-OK "创建输出目录: $OutputDir"
}

# ============================================================
# 1. 读取并校验脚本
# ============================================================
Write-Step "1. 读取脚本..."

$ScriptContent = Get-Content $ScriptPath -Raw -Encoding UTF8
if ([string]::IsNullOrWhiteSpace($ScriptContent)) {
    Write-Error-Custom "脚本文件为空: $ScriptPath"
    exit 1
}

$ScriptLines = $ScriptContent -split "`n" | Where-Object { $_.Trim() -ne "" }
$Title = $ScriptLines[0].Trim() -replace '^#+\s*', ''

# 字数统计
$CharCount = ($ScriptContent -replace '\s', '').Length
Write-OK "标题: $Title"
Write-OK "字数: $CharCount 字"

if ($CharCount -lt 30) {
    Write-Warn "脚本较短 (${CharCount}字)，确认脚本内容完整"
} elseif ($CharCount -gt 500) {
    Write-Warn "脚本较长 (${CharCount}字)，建议控制在 60-90 秒口播长度 (~200-300字)"
}

# ============================================================
# 2. 创建 HyperFrames 项目
# ============================================================
Write-Step "2. 创建 HyperFrames 项目..."

$ProjectDir = "$ScriptBaseDir\$DateStr-$SafeProjectName"

if (Test-Path $ProjectDir) {
    Write-Warn "项目目录已存在: $ProjectDir"
    Write-Host "  将覆盖现有脚本内容..."
} else {
    $null = npx hyperframes init $ProjectDir --non-interactive --example=blank 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "HyperFrames 项目初始化失败"
        exit 1
    }
    Write-OK "项目已创建: $ProjectDir"
}

# 写入脚本到 visible-text.txt
$VisibleTextPath = "$ProjectDir\capture\extracted\visible-text.txt"
$VisibleTextDir = Split-Path $VisibleTextPath -Parent
if (-not (Test-Path $VisibleTextDir)) {
    New-Item -ItemType Directory -Force -Path $VisibleTextDir | Out-Null
}
$ScriptContent | Out-File -FilePath $VisibleTextPath -Encoding utf8
Write-OK "脚本已写入: visible-text.txt"

# ============================================================
# 3. 质量检查链
# ============================================================
Write-Step "3. 质量检查链 (lint → validate → inspect)..."

Push-Location $ProjectDir
try {
    # Lint
    Write-Host "  运行 lint..."
    $lintResult = npx hyperframes lint 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Lint 检查失败"
        Write-Host $lintResult
        Pop-Location
        exit 1
    }
    Write-OK "Lint 通过"

    # Validate
    Write-Host "  运行 validate..."
    $validateResult = npx hyperframes validate 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Validate 检查失败"
        Write-Host $validateResult
        Pop-Location
        exit 1
    }
    Write-OK "Validate 通过"

    # Inspect
    Write-Host "  运行 inspect..."
    $inspectResult = npx hyperframes inspect 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "Inspect 有警告（不阻塞渲染）"
        Write-Host $inspectResult
    } else {
        Write-OK "Inspect 通过"
    }
} finally {
    Pop-Location
}

# ============================================================
# 4. 渲染视频
# ============================================================
$OutputFile = "$OutputDir\douyin_${DateStr}_${SafeProjectName}.mp4"

if ($SkipRender) {
    Write-Step "4. 跳过渲染 (--SkipRender)"
} else {
    Write-Step "4. 渲染视频..."

    $renderArgs = @(
        "hyperframes", "render",
        "--skill=faceless-explainer",
        "--style", $Style,
        "--quality", $Quality,
        "--output", $OutputFile,
        "--", "--width=1080", "--height=1920"
    )

    Push-Location $ProjectDir
    try {
        $renderResult = npx @renderArgs 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error-Custom "渲染失败"
            Write-Host $renderResult
            Pop-Location
            exit 1
        }
        Write-OK "视频已生成: $OutputFile"

        # 文件大小
        if (Test-Path $OutputFile) {
            $fileSizeMB = [Math]::Round((Get-Item $OutputFile).Length / 1MB, 1)
            Write-OK "文件大小: ${fileSizeMB}MB"
        }
    } finally {
        Pop-Location
    }
}

# ============================================================
# 5. 生成封面提示词
# ============================================================
Write-Step "5. 生成封面提示词..."

# 根据风格选择底图提示词模板
$coverPrompt = switch ($Style) {
    "narrative-dark" {
@"
# 封面底图提示词 (AI生成)
## 视频: $Title
## 风格: 故事叙述型 | 日期: $ProjectDate

### 推荐提示词 (即梦/豆包)
A minimalist flat illustration, a 22-year-old male silhouette from behind
looking at distant golden light, warm beige environment,
deep navy blue silhouette, hopeful mood,
50% negative space, no readable text, no letters, no characters,
9:16 vertical, clean geometric --ar 9:16

### 大字标题建议
**$Title** (深蓝 #1A3A5C, 28pt, 阿里巴巴普惠体 Bold)

### Canva 模板指引
- 底色: #F5F1EB
- 大字: #1A3A5C
- 分割线: #D4A843, 200px
- 底部水印: 董辉 · 22岁 · 南华大学
"@
    }
    "data-visual" {
@"
# 封面底图提示词 (AI生成)
## 视频: $Title
## 风格: 数据可视型 | 日期: $ProjectDate

### 推荐提示词 (即梦/豆包)
A minimalist two-column comparison, left navy blue descending,
right golden ascending, clean divider line,
warm beige background, clean geometric,
no readable text, no letters, no characters,
9:16 vertical --ar 9:16

### 大字标题建议
**$Title** (深蓝 #1A3A5C, 28pt, 阿里巴巴普惠体 Bold)

### Canva 模板指引
- 底色: #F5F1EB
- 大字: #1A3A5C
- 分割线: #D4A843, 200px
- 底部水印: 董辉 · 22岁 · 南华大学
"@
    }
    default {
@"
# 封面底图提示词 (AI生成)
## 视频: $Title
## 风格: 白板讲解型 | 日期: $ProjectDate

### 推荐提示词 (即梦/豆包)
A minimalist flat illustration, warm beige background #F5F1EB,
a single elegant S-shaped rising curve in deep navy blue #1A3A5C,
four golden dots on the curve, 40% negative space,
clean geometric, hopeful, no readable text, no letters, no characters,
9:16 vertical --ar 9:16

### 大字标题建议
**$Title** (深蓝 #1A3A5C, 28pt, 阿里巴巴普惠体 Bold)

### Canva 模板指引
- 底色: #F5F1EB
- 大字: #1A3A5C  
- 分割线: #D4A843, 200px
- 底部水印: 董辉 · 22岁 · 南华大学
"@
    }
}

# 追加到封面提示词文件
$coverHeader = @"

---
## ${DateStr} - $Title
"@
Add-Content -Path $CoverPromptOutput -Value $coverHeader -Encoding utf8
Add-Content -Path $CoverPromptOutput -Value $coverPrompt -Encoding utf8
Write-OK "封面提示词已追加到: $CoverPromptOutput"

# ============================================================
# 6. 记录 CSV
# ============================================================
if (-not $NoCsv) {
    Write-Step "6. 记录数据到 CSV..."

    # 读取现有CSV以获取表头
    $csvExists = Test-Path $CsvPath
    if ($csvExists) {
        $existingHeaders = (Get-Content $CsvPath -TotalCount 1 -Encoding UTF8).Split(',')
    } else {
        # 默认表头（数据追踪系统规范）
        $existingHeaders = @("发布日期", "平台", "内容标题", "章节来源", "阅读量", "点赞", "在看", "评论", "转发", "收藏", "新增关注", "转化动作", "备注")
        $headerLine = $existingHeaders -join ","
        $headerLine | Out-File -FilePath $CsvPath -Encoding utf8
        Write-OK "创建新 CSV 文件"
    }

    # 构建新记录
    $newRecord = @{
        "发布日期" = $ProjectDate
        "平台"     = "抖音"
        "内容标题"  = $Title
        "章节来源"  = $ScriptName
        "阅读量"    = "0"
        "点赞"     = "0"
        "在看"     = "0"
        "评论"     = "0"
        "转发"     = "0"
        "收藏"     = "0"
        "新增关注"  = "0"
        "转化动作"  = ""
        "备注"     = "自动发布 | 风格:$Style | 质量:$Quality"
    }

    # 按现有表头顺序排列
    $values = foreach ($h in $existingHeaders) {
        $val = $newRecord[$h]
        if ($null -eq $val) { "" } else { $val }
    }
    $csvLine = $values -join ","
    Add-Content -Path $CsvPath -Value $csvLine -Encoding utf8
    Write-OK "CSV 记录已追加"
}

# ============================================================
# 完成
# ============================================================
Write-Host ""
Write-Host "╔══════════════════════════════════════╗"
Write-Host "║   ✅ 发布流程完成!                  ║"
Write-Host "╚══════════════════════════════════════╝"
Write-Host ""
Write-Host "  📹 视频: $OutputFile" -ForegroundColor Green
Write-Host "  📁 项目: $ProjectDir" -ForegroundColor Green
Write-Host "  🎨 封面: $CoverPromptOutput" -ForegroundColor Green
if (-not $NoCsv) {
    Write-Host "  📊 CSV:  $CsvPath" -ForegroundColor Green
}
Write-Host ""
Write-Host "  下一步:" -ForegroundColor Yellow
Write-Host "    1. 在 Canva 中打开封面模板, 用上面的提示词生成底图"
Write-Host "    2. npx hyperframes preview (在 $ProjectDir 下) 审查视频"
Write-Host "    3. 发布后 1h/24h/7d 更新 CSV 数据"
Write-Host "    4. 将文稿移至 07-已发布/"
Write-Host ""
