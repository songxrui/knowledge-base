<#
.SYNOPSIS
    一键发布公众号文章：输入文章md → 自动转HTML + 生成配图提示词 + 记录CSV
.DESCRIPTION
    将 Markdown 文章自动转化为公众号兼容的 HTML 格式，
    同时生成配图提示词（针对即梦/豆包 AI 生成底图 + Canva 文字叠加），
    并将发布记录追加到数据统计 CSV。
.PARAMETER ArticlePath
    文章 Markdown 文件路径。文件编码需为 UTF-8。
    第一行 # 标题 自动识别为文章标题。
.PARAMETER OutputDir
    HTML 输出目录。默认: D:\KnowledgeBase\01-内容生产\进行中\html-output
.PARAMETER Style
    配图风格。可选值: cognitive (理性认知类,默认), story (故事经历类), data (数据方法类)
.PARAMETER NoCsv
    跳过CSV记录步骤
.PARAMETER OpenHtml
    生成后自动用默认浏览器打开 HTML 预览
.EXAMPLE
    .\new-wechat.ps1 -ArticlePath "D:\KnowledgeBase\01-内容生产\进行中\公众号文章_杠铃策略深度版.md"
    默认设置: 认知类配图 + 记录CSV
.EXAMPLE
    .\new-wechat.ps1 -ArticlePath ".\article.md" -Style story -OpenHtml
    故事类配图 + 生成后打开预览
.NOTES
    版本: v1.0 | 创建: 2026-07-02
    公众号 HTML 兼容要点:
    - 内联样式（公众号不支持外部CSS）
    - 图片需先上传到公众号素材库
    - 代码块使用公众号兼容格式
    - 字体大小建议 15-17px
#>

param(
    [Parameter(Mandatory = $true, HelpMessage = "文章 Markdown 文件路径")]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$ArticlePath,

    [Parameter(HelpMessage = "HTML 输出目录")]
    [string]$OutputDir = "D:\KnowledgeBase\01-内容生产\进行中\html-output",

    [Parameter(HelpMessage = "配图风格")]
    [ValidateSet("cognitive", "story", "data")]
    [string]$Style = "cognitive",

    [Parameter(HelpMessage = "跳过CSV记录")]
    [switch]$NoCsv,

    [Parameter(HelpMessage = "生成后打开预览")]
    [switch]$OpenHtml
)

# ============================================================
# 配置区
# ============================================================
$ErrorActionPreference = "Stop"
$CsvPath = "D:\KnowledgeBase\05-数据统计\数据统计表.csv"
$CoverPromptOutput = "D:\KnowledgeBase\01-内容生产\进行中\配图提示词_自动生成.md"
$DateStr = Get-Date -Format "yyyy-MM-dd"
$TimeStr = Get-Date -Format "HH:mm"
$ArticleName = [System.IO.Path]::GetFileNameWithoutExtension($ArticlePath)

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

function ConvertTo-WechatHtml {
    param([string]$Markdown, [string]$Title)

    # 转义 HTML 特殊字符（在非代码块区域）
    # 简单的 Markdown → 公众号 HTML 转换
    $html = $Markdown

    # 去掉第一行 # 标题（已提取）
    $html = $html -replace '^#\s+.*\r?\n', ''

    # 二级标题
    $html = $html -replace '(?m)^##\s+(.+)$', '<h2 style="font-size:20px;color:#1A3A5C;margin:24px 0 12px;padding-left:8px;border-left:3px solid #D4A843;">$1</h2>'

    # 三级标题
    $html = $html -replace '(?m)^###\s+(.+)$', '<h3 style="font-size:18px;color:#2D2D2D;margin:20px 0 10px;">$1</h3>'

    # 加粗
    $html = $html -replace '\*\*(.+?)\*\*', '<strong style="color:#1A3A5C;">$1</strong>'

    # 斜体
    $html = $html -replace '\*(.+?)\*', '<em>$1</em>'

    # 行内代码
    $html = $html -replace '`([^`]+)`', '<code style="background:#F5F1EB;padding:2px 6px;border-radius:3px;font-size:14px;color:#D4A843;">$1</code>'

    # 引用块
    $html = $html -replace '(?m)^>\s*(.+)$', '<blockquote style="background:#F5F1EB;padding:12px 16px;margin:12px 0;border-left:3px solid #D4A843;color:#666;">$1</blockquote>'

    # 分割线
    $html = $html -replace '(?m)^---$', '<hr style="border:none;border-top:1px solid #E8E0D9;margin:24px 0;">'

    # 有序列表
    $inOrderedList = $false
    $lines = $html -split "`n"
    $result = @()
    foreach ($line in $lines) {
        if ($line -match '^\d+\.\s+(.+)') {
            if (-not $inOrderedList) {
                $result += '<ol style="padding-left:24px;color:#2D2D2D;line-height:1.8;">'
                $inOrderedList = $true
            }
            $result += "<li>$($Matches[1])</li>"
        } else {
            if ($inOrderedList) {
                $result += '</ol>'
                $inOrderedList = $false
            }
            $result += $line
        }
    }
    if ($inOrderedList) { $result += '</ol>' }
    $html = $result -join "`n"

    # 无序列表
    $inUnorderedList = $false
    $lines = $html -split "`n"
    $result = @()
    foreach ($line in $lines) {
        if ($line -match '^[\-\*]\s+(.+)') {
            if (-not $inUnorderedList) {
                $result += '<ul style="padding-left:24px;color:#2D2D2D;line-height:1.8;">'
                $inUnorderedList = $true
            }
            $result += "<li>$($Matches[1])</li>"
        } else {
            if ($inUnorderedList) {
                $result += '</ul>'
                $inUnorderedList = $false
            }
            $result += $line
        }
    }
    if ($inUnorderedList) { $result += '</ul>' }
    $html = $result -join "`n"

    # 普通段落（非标签开头的行）
    $lines = $html -split "`n"
    $result = @()
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        if ($trimmed -eq '') {
            $result += '<br>'
        } elseif ($trimmed -match '^<') {
            $result += $line
        } else {
            $result += "<p style=""font-size:16px;color:#2D2D2D;line-height:1.85;margin:8px 0;"">$trimmed</p>"
        }
    }
    $html = $result -join "`n"

    # 组装完整 HTML
    $fullHtml = @"
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>$Title</title>
</head>
<body style="max-width:680px;margin:0 auto;padding:20px;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI','PingFang SC','Hiragino Sans GB','Microsoft YaHei',sans-serif;background:#fff;">

<div style="text-align:center;margin-bottom:32px;">
  <h1 style="font-size:24px;color:#1A3A5C;margin:0 0 8px;">$Title</h1>
  <p style="font-size:13px;color:#999;margin:0;">董辉 · $DateStr</p>
  <hr style="border:none;border-top:1px solid #E8E0D9;margin:16px auto;width:60px;">
</div>

$html

<div style="margin-top:40px;padding:16px;background:#F5F1EB;border-radius:4px;text-align:center;">
  <p style="font-size:13px;color:#999;margin:0;">— 董辉 · 22岁 · 南华大学 —</p>
  <p style="font-size:12px;color:#999;margin:4px 0 0;">关注公众号，每周一篇深度思考</p>
</div>

</body>
</html>
"@
    return $fullHtml
}

# ============================================================
# 0. 环境自检
# ============================================================
Write-Host ""
Write-Host "╔══════════════════════════════════════╗"
Write-Host "║   董辉公众号一键发布 v1.0           ║"
Write-Host "╚══════════════════════════════════════╝"
Write-Host ""

Write-Step "0. 环境自检..."

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
    Write-OK "创建输出目录: $OutputDir"
} else {
    Write-OK "输出目录就绪: $OutputDir"
}

# ============================================================
# 1. 读取文章
# ============================================================
Write-Step "1. 读取文章..."

$ArticleContent = Get-Content $ArticlePath -Raw -Encoding UTF8
if ([string]::IsNullOrWhiteSpace($ArticleContent)) {
    Write-Error-Custom "文章文件为空: $ArticlePath"
    exit 1
}

# 提取标题
$titleMatch = [regex]::Match($ArticleContent, '^#\s+(.+)$', [System.Text.RegularExpressions.RegexOptions]::Multiline)
if ($titleMatch.Success) {
    $Title = $titleMatch.Groups[1].Value.Trim()
} else {
    $Title = $ArticleName
    Write-Warn "未找到 # 标题，使用文件名: $Title"
}

# 统计
$CharCount = ($ArticleContent -replace '\s', '').Length
$ParaCount = ($ArticleContent -split "`n`n" | Where-Object { $_.Trim() -ne "" }).Count
Write-OK "标题: $Title"
Write-OK "字数: $CharCount 字 | 段落: $ParaCount 段"

if ($CharCount -lt 500) {
    Write-Warn "文章较短 (${CharCount}字)，公众号建议 1500-3000 字"
}

# ============================================================
# 2. 转换为公众号 HTML
# ============================================================
Write-Step "2. 转换为公众号 HTML..."

$HtmlOutput = ConvertTo-WechatHtml -Markdown $ArticleContent -Title $Title
$HtmlPath = "$OutputDir\$ArticleName.html"
$HtmlOutput | Out-File -FilePath $HtmlPath -Encoding utf8
Write-OK "HTML 已生成: $HtmlPath"

# ============================================================
# 3. 生成配图提示词
# ============================================================
Write-Step "3. 生成配图提示词..."

$coverPrompt = switch ($Style) {
    "story" {
@"
# 公众号配图提示词 (AI生成底图 + Canva 文字叠加)
## 文章: $Title
## 风格: 故事经历类 | 日期: $DateStr
## 规格: 公众号封面 1200x630 (或 900x383)

### AI 底图提示词 (即梦/豆包)
A minimalist flat illustration, a 22-year-old male silhouette
from behind looking at distant golden light,
warm beige environment, deep navy blue silhouette,
hopeful mood, 50% negative space,
no readable text, no letters, no characters,
16:9 --ar 16:9

### Canva 叠加指引
- 上传底图 → 画布 1200×630
- 标题: "$Title" (深蓝 #1A3A5C, 36pt, 阿里巴巴普惠体 Bold)
- 金色分割线: 300px × 2px, #D4A843
- 底部水印条: 深蓝 #1A3A5C 底, 白字"董辉" 12pt
- 导出: PNG, 质量 90%
"@
    }
    "data" {
@"
# 公众号配图提示词 (AI生成底图 + Canva 文字叠加)
## 文章: $Title
## 风格: 数据方法类 | 日期: $DateStr
## 规格: 公众号封面 1200x630 (或 900x383)

### AI 底图提示词 (即梦/豆包)
A minimalist two-column comparison, left navy blue descending,
right golden ascending, clean divider line,
warm beige background, clean geometric,
no readable text, no letters, no characters,
16:9 --ar 16:9

### Canva 叠加指引
- 上传底图 → 画布 1200×630
- 标题: "$Title" (深蓝 #1A3A5C, 36pt, 阿里巴巴普惠体 Bold)
- 金色分割线: 300px × 2px, #D4A843
- 底部水印条: 深蓝 #1A3A5C 底, 白字"董辉" 12pt
- 导出: PNG, 质量 90%
"@
    }
    default {
@"
# 公众号配图提示词 (AI生成底图 + Canva 文字叠加)
## 文章: $Title
## 风格: 理性认知类 | 日期: $DateStr
## 规格: 公众号封面 1200x630 (或 900x383)

### AI 底图提示词 (即梦/豆包)
A minimalist flat illustration, warm beige background #F5F1EB,
a single elegant S-shaped rising curve in deep navy blue #1A3A5C,
four golden dots on the curve, 40% negative space,
clean geometric, hopeful,
no readable text, no letters, no characters,
16:9 --ar 16:9

### Canva 叠加指引
- 上传底图 → 画布 1200×630
- 标题: "$Title" (深蓝 #1A3A5C, 36pt, 阿里巴巴普惠体 Bold)
- 金色分割线: 300px × 2px, #D4A843
- 底部水印条: 深蓝 #1A3A5C 底, 白字"董辉" 12pt
- 导出: PNG, 质量 90%
"@
    }
}

$coverHeader = @"

---
## $DateStr - $Title (公众号)
"@
Add-Content -Path $CoverPromptOutput -Value $coverHeader -Encoding utf8
Add-Content -Path $CoverPromptOutput -Value $coverPrompt -Encoding utf8
Write-OK "配图提示词已追加到: $CoverPromptOutput"

# ============================================================
# 4. 记录 CSV
# ============================================================
if (-not $NoCsv) {
    Write-Step "4. 记录数据到 CSV..."

    $csvExists = Test-Path $CsvPath
    if ($csvExists) {
        $existingHeaders = (Get-Content $CsvPath -TotalCount 1 -Encoding UTF8).Split(',')
    } else {
        $existingHeaders = @("发布日期", "平台", "内容标题", "章节来源", "阅读量", "点赞", "在看", "评论", "转发", "收藏", "新增关注", "转化动作", "备注")
        ($existingHeaders -join ",") | Out-File -FilePath $CsvPath -Encoding utf8
        Write-OK "创建新 CSV 文件"
    }

    $newRecord = @{
        "发布日期" = $DateStr
        "平台"     = "公众号"
        "内容标题"  = $Title
        "章节来源"  = $ArticleName
        "阅读量"    = "0"
        "点赞"     = "0"
        "在看"     = "0"
        "评论"     = "0"
        "转发"     = "0"
        "收藏"     = "0"
        "新增关注"  = "0"
        "转化动作"  = ""
        "备注"     = "自动发布 | 风格:$Style | 字数:$CharCount"
    }

    $values = foreach ($h in $existingHeaders) {
        $val = $newRecord[$h]
        if ($null -eq $val) { "" } else { $val }
    }
    $csvLine = $values -join ","
    Add-Content -Path $CsvPath -Value $csvLine -Encoding utf8
    Write-OK "CSV 记录已追加"
}

# ============================================================
# 5. 打开预览
# ============================================================
if ($OpenHtml -and (Test-Path $HtmlPath)) {
    Write-Step "5. 打开 HTML 预览..."
    Start-Process $HtmlPath
    Write-OK "已在浏览器中打开"
}

# ============================================================
# 完成
# ============================================================
Write-Host ""
Write-Host "╔══════════════════════════════════════╗"
Write-Host "║   ✅ 公众号发布流程完成!            ║"
Write-Host "╚══════════════════════════════════════╝"
Write-Host ""
Write-Host "  📄 HTML: $HtmlPath" -ForegroundColor Green
Write-Host "  🎨 配图: $CoverPromptOutput" -ForegroundColor Green
if (-not $NoCsv) {
    Write-Host "  📊 CSV:  $CsvPath" -ForegroundColor Green
}
Write-Host ""
Write-Host "  下一步:" -ForegroundColor Yellow
Write-Host "    1. 复制 HTML 到公众号编辑器 (Ctrl+A → Ctrl+C → 粘贴)"
Write-Host "    2. 用即梦/豆包生成底图 → Canva 加文字 → 上传封面"
Write-Host "    3. 在公众号后台设置摘要、作者、原创声明"
Write-Host "    4. 发布后 1h/24h/7d 更新 CSV 数据"
Write-Host "    5. 将文稿移至 07-已发布/"
Write-Host ""
