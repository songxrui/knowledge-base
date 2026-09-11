param(
    [string]$Root = "D:\KnowledgeBase"
)

$ErrorActionPreference = "Stop"
$rootPath = [IO.Path]::GetFullPath($Root).TrimEnd('\')
$scanner = "C:\tmp\gitleaks-8.30.1\bin\gitleaks.exe"
if (-not (Test-Path -LiteralPath $scanner)) { throw "Gitleaks executable not found" }

$promptPath = Join-Path $rootPath "99-系统\元数据\知识库外科医生提示词_v2.0_DH定制.md"
$bufferPath = Join-Path $rootPath "03-资源\来源台账\00-缓冲区\WEREAD_VERIFICATION_REPORT.md"
$legacyPath = Join-Path $rootPath "99-系统\脚本\legacy-meta\one-off-2026-07-15"
$prompt = Get-Content -LiteralPath $promptPath -Raw -Encoding UTF8
$buffer = Get-Content -LiteralPath $bufferPath -Raw -Encoding UTF8
if ($prompt -notmatch 'App Secret:\s*\$\{FEISHU_APP_SECRET\}') { throw "prompt App Secret placeholder missing" }
if ($prompt -notmatch 'Token:\s*\$\{SERVICE_TOKEN\}') { throw "prompt Token placeholder missing" }
if ($buffer -notmatch 'Token:\s*\$\{WEREAD_COOKIE\}') { throw "buffer Token placeholder missing" }
if ($prompt -match '(?i)(?:Secret|Token):\s*[A-Za-z0-9_./+=-]{8,}') { throw "literal prompt credential pattern remains" }
if ($buffer -match '(?i)Token:\s*[A-Za-z0-9_./+=-]{8,}') { throw "literal buffer token pattern remains" }

$legacyNames = @("weread_batch2.py", "weread_batch3.py", "weread_extract_v2.py", "weread_highlights.py", "weread_extract_top.py", "weread_test.py")
$legacyFiles = @($legacyNames | ForEach-Object { Get-Item -LiteralPath (Join-Path $legacyPath $_) })
if ($legacyFiles.Count -ne $legacyNames.Count) { throw "expected legacy script targets are missing" }
foreach ($file in $legacyFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    if ($content -notmatch 'WEREAD_TOKEN\s*=\s*(?:os\.environ\["WEREAD_COOKIE"\]|__import__\("os"\)\.environ\["WEREAD_COOKIE"\])') { throw "environment injection missing: $($file.Name)" }
    if ($content -match 'WEREAD_TOKEN\s*=\s*["''][^"'']{8,}') { throw "literal legacy token remains: $($file.Name)" }
}

$scanTargets = @($promptPath, $bufferPath, $legacyPath)
foreach ($target in $scanTargets) {
    & $scanner dir $target --no-banner --redact --timeout 60
    if ($LASTEXITCODE -ne 0) { throw "Gitleaks found a target finding: $target" }
}

foreach ($reportPath in @(
    (Join-Path $rootPath "99-系统\元数据\inventory\GITLEAKS_WORKTREE_SCAN_2026-07-20.json"),
    (Join-Path $rootPath "99-系统\元数据\inventory\GITLEAKS_HISTORY_SCAN_2026-07-20.json")
)) {
    $report = @(Get-Content -LiteralPath $reportPath -Raw -Encoding UTF8 | ConvertFrom-Json)
    $unredacted = @($report | Where-Object { [string]$_.Secret -ne "REDACTED" })
    if ($unredacted.Count -ne 0) { throw "unredacted report field: $reportPath" }
}

Write-Output "PASS: credential remediation targets and redacted reports are clean"
