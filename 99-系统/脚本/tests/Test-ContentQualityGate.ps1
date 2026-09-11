param(
    [string]$Root = "D:\KnowledgeBase"
)

$ErrorActionPreference = "Stop"
$rootPath = [IO.Path]::GetFullPath($Root).TrimEnd('\')
$gateScript = Join-Path $rootPath "99-系统\脚本\audit_content_quality.ps1"
$gateCsv = Join-Path $rootPath "99-系统\元数据\inventory\CONTENT_QUALITY_GATE_LATEST.csv"
$gateMarkdown = Join-Path $rootPath "99-系统\元数据\inventory\CONTENT_QUALITY_GATE_LATEST.md"
$worktreeReport = Join-Path $rootPath "99-系统\元数据\inventory\GITLEAKS_WORKTREE_SCAN_2026-07-20.json"
$historyReport = Join-Path $rootPath "99-系统\元数据\inventory\GITLEAKS_HISTORY_SCAN_2026-07-20.json"

& pwsh -NoProfile -File $gateScript -Root $rootPath -BaselineReplay
if ($LASTEXITCODE -ne 0) { throw "content quality gate failed with exit code $LASTEXITCODE" }

$findings = @(Import-Csv -LiteralPath $gateCsv)
$p0 = @($findings | Where-Object severity -eq "P0").Count
$p1 = @($findings | Where-Object severity -eq "P1").Count
$p2 = @($findings | Where-Object severity -eq "P2").Count
if ($p0 -ne 0 -or $p1 -ne 1 -or $p2 -ne 0) { throw "unexpected gate counts: P0=$p0 P1=$p1 P2=$p2" }

$blocked = @($findings | Where-Object {
    $_.severity -eq "P1" -and
    $_.rule -eq "blocked-product-hypothesis" -and
    $_.path -eq "05-内容生产/进行中/199社群产品设计文档_v2.md" -and
    $_.evidence -eq "status: blocked"
})
if ($blocked.Count -ne 1) { throw "blocked product finding identity changed" }

$baselineText = Get-Content -LiteralPath $gateMarkdown -Raw -Encoding UTF8
$baselineAssertions = @(
    "Archived broken theme-map links independently resolved as missing: 524",
    "Frozen meta-abilities claim-ledger rows with valid unique ids and required fields: 343",
    "Credential-history locations recorded (not independently rescanned): 37 commits / 43 paths",
    "Current canonical documents indexed by stable id: 74"
)
foreach ($assertion in $baselineAssertions) {
    if ($baselineText -notlike "*$assertion*") { throw "missing baseline assertion: $assertion" }
}

foreach ($reportPath in @($worktreeReport, $historyReport)) {
    if (-not (Test-Path -LiteralPath $reportPath)) { throw "missing redacted scanner report: $reportPath" }
    $report = @(Get-Content -LiteralPath $reportPath -Raw -Encoding UTF8 | ConvertFrom-Json)
    if ($report.Count -eq 0) { throw "empty scanner report: $reportPath" }
    $unredacted = @($report | Where-Object { [string]$_.Secret -ne "REDACTED" })
    if ($unredacted.Count -ne 0) { throw "scanner report contains unredacted secret fields: $reportPath" }
}

Write-Output "PASS: gate baseline and redacted scanner reports are consistent"
