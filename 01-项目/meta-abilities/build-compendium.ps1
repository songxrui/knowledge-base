param(
    [string]$ProjectRoot = $PSScriptRoot
)

$ErrorActionPreference = "Stop"
$chapterFiles = @(
    "自学.md",
    "写作.md",
    "说服.md",
    "健康.md",
    "决策.md",
    "专注.md",
    "元认知.md",
    "系统思维.md",
    "创造力.md",
    "情绪调节.md",
    "执行.md",
    "戒断.md",
    "自我精神分析.md",
    "统计.md",
    "逻辑.md"
)

function Remove-Frontmatter([string]$content) {
    if ($content -notmatch "\A---\r?\n") {
        throw "Missing frontmatter"
    }
    return [regex]::Replace($content, "\A---\r?\n.*?\r?\n---\r?\n+", "", [Text.RegularExpressions.RegexOptions]::Singleline)
}

$newLine = [Environment]::NewLine
$bodies = @()
foreach ($name in $chapterFiles) {
    $path = Join-Path $ProjectRoot $name
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing chapter: $name"
    }
    $raw = Get-Content -LiteralPath $path -Raw
    if (-not $raw.Contains("source_role: chapter")) {
        throw "Not a chapter source: $name"
    }
    $bodies += (Remove-Frontmatter $raw).Trim()
}

$headerLines = @(
    "---",
    "status: generated-blocked",
    "version: ""1.0""",
    "canonical: false",
    "generated: true",
    "generated_from: README.md chapter manifest",
    "updated_at: 2026-07-18",
    "evidence_level: B-ai-derived-unverified",
    "---",
    "",
    "# 元能力个人操作系统",
    "",
    "> 自动生成文件：正文来自15份章节源。不要直接编辑。全部章节仍处于 blocked-claim-audit，主张台账闭环前不得作为权威稿发布。",
    ""
)
$output = ($headerLines -join $newLine) + $newLine + ($bodies -join ($newLine + $newLine + "---" + $newLine + $newLine)) + $newLine
$target = Join-Path $ProjectRoot "元能力个人操作系统.md"
[IO.File]::WriteAllText($target, $output, [Text.UTF8Encoding]::new($false))
Write-Output ("Generated chapters=" + $chapterFiles.Count)
Write-Output ("Target=" + $target)
