param(
    [string]$Root = "D:\KnowledgeBase",
    [string]$InputPath = "99-系统\元数据\inventory\GITLEAKS_HISTORY_SCAN_2026-07-20.json",
    [string]$OutputPath = "99-系统\元数据\inventory\GITLEAKS_HISTORY_FILE_DISPOSITION_2026-07-20.csv"
)

$ErrorActionPreference = "Stop"
$rootPath = [IO.Path]::GetFullPath($Root).TrimEnd('\')
$input = if ([IO.Path]::IsPathRooted($InputPath)) { $InputPath } else { Join-Path $rootPath $InputPath }
$output = if ([IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { Join-Path $rootPath $OutputPath }
$findings = @(Get-Content -LiteralPath $input -Raw -Encoding UTF8 | ConvertFrom-Json)

if ($findings.Count -eq 0) { throw "history report is empty" }
$unredacted = @($findings | Where-Object { [string]$_.Secret -ne "REDACTED" })
if ($unredacted.Count -ne 0) { throw "history report contains unredacted Secret fields" }

function Get-Disposition([string]$file) {
    if ($file -match '^\.codex/skills/hyperframes/registry/') {
        return @("hyperframes-code-snippet", "candidate-rule-review", "Confirm generic-api-key matches are code examples; retain source semantics")
    }
    if ($file -match '(?:^|/)(?:tests?|fixtures?)(?:/|$)|\.test\.|\.spec\.') {
        return @("test-fixture", "candidate-test-fixture", "Confirm value is non-production test data; retain test semantics")
    }
    if ($file -match '^(?:output/prompts/|_meta/).*(?:PROMPT|提示词|config\.toml)') {
        return @("historical-prompt-config", "rotation-required", "Verify service-side revocation; do not rewrite shared history")
    }
    if ($file -match '(?i)weread') {
        return @("weread-history", "rotation-required-protected-source", "Verify old value rejection before protected-source disposition")
    }
    if ($file -match '^_logs/') {
        return @("historical-log", "rotation-required-historical-log", "Verify service-side revocation, then retain redacted summary or archive")
    }
    if ($file -match '^media/flagship/.+SOURCE_LEDGER\.md$|^media/flagship/.+(?:FULL_MANUSCRIPT|GIT_TIME_LOG)\.md$') {
        return @("media-source-ledger", "protected-source-review", "Confirm whether candidate is a source identifier, example, or revoked historical value")
    }
    if ($file -match '(?i)telemetry|capabilities\.md$') {
        return @("source-code-reference", "candidate-source-review", "Confirm candidate is source code or documentation example")
    }
    if ($file -match '(?:SKILL|skills?)\.md$|/SKILL\.md$') {
        return @("skill-documentation", "manual-disposition-required", "Review candidate context without exporting Match or Secret")
    }
    return @("other-history", "manual-disposition-required", "Review candidate context without exporting Match or Secret")
}

$rows = foreach ($group in ($findings | Group-Object File | Sort-Object Name)) {
    $disposition = Get-Disposition $group.Name
    $dates = @($group.Group.Date | Where-Object { $_ } | Sort-Object)
    [pscustomobject]@{
        file = $group.Name
        findings = $group.Count
        rule_ids = (@($group.Group.RuleID | Sort-Object -Unique) -join ';')
        commits = @($group.Group.Commit | Where-Object { $_ } | Sort-Object -Unique).Count
        first_date = if ($dates.Count) { $dates[0] } else { "" }
        last_date = if ($dates.Count) { $dates[-1] } else { "" }
        category = $disposition[0]
        disposition = $disposition[1]
        next_action = $disposition[2]
    }
}

$findingTotal = ($rows | Measure-Object findings -Sum).Sum
if ($rows.Count -ne 38) { throw "unexpected file row count: $($rows.Count)" }
if ($findingTotal -ne 604) { throw "unexpected finding total: $findingTotal" }

$outputDirectory = Split-Path -Parent $output
if (-not (Test-Path -LiteralPath $outputDirectory)) { New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null }
$rows | Export-Csv -LiteralPath $output -NoTypeInformation -Encoding utf8NoBOM
Write-Output "rows=$($rows.Count)"
Write-Output "findings=$findingTotal"
Write-Output "output=$output"
