param(
    [string]$Root = "D:\KnowledgeBase",
    [string]$LedgerPath = "99-系统\元数据\inventory\CREDENTIAL_ROTATION_EVIDENCE_2026-07-20.csv",
    [switch]$AllowPending
)

$ErrorActionPreference = "Stop"
$rootPath = [IO.Path]::GetFullPath($Root).TrimEnd('\')
$ledger = if ([IO.Path]::IsPathRooted($LedgerPath)) { $LedgerPath } else { Join-Path $rootPath $LedgerPath }
$rows = @(Import-Csv -LiteralPath $ledger)
$expected = @("feishu_app", "feishu_folder", "weread", "exa", "deepseek", "github_pat")
$ids = @($rows.credential_id)

if ($rows.Count -ne $expected.Count) { throw "unexpected credential row count: $($rows.Count)" }
if (@($ids | Sort-Object -Unique).Count -ne $rows.Count) { throw "duplicate credential_id" }
foreach ($id in $expected) {
    if ($ids -notcontains $id) { throw "missing credential_id: $id" }
}

$allowedStorage = @("environment-variable", "os-credential-store", "github-cli-keyring", "other-local-secret-store")
$environmentRequirements = @{
    feishu_app = @("FEISHU_APP_ID", "FEISHU_APP_SECRET")
    feishu_folder = @("FEISHU_FOLDER_TOKEN")
    weread = @("WEREAD_COOKIE")
    exa = @("EXA_API_KEY")
    deepseek = @("DEEPSEEK_API_KEY")
}
$pending = [Collections.Generic.List[object]]::new()
foreach ($row in $rows) {
    if ($row.local_status -ne "local_redacted") { throw "unexpected local_status for $($row.credential_id)" }
    if ($allowedStorage -notcontains $row.new_storage_type) { throw "unsupported new_storage_type for $($row.credential_id)" }
    if ($row.status -eq "verified_revoked") {
        foreach ($field in @("rotation_time", "old_value_rejected_at", "rejection_evidence_path", "new_storage_verified_at")) {
            if (-not $row.$field) { throw "verified row missing $field for $($row.credential_id)" }
        }
        foreach ($field in @("rotation_time", "old_value_rejected_at", "new_storage_verified_at")) {
            $parsed = [datetime]::MinValue
            if (-not [datetime]::TryParse($row.$field, [ref]$parsed)) { throw "invalid timestamp in $field for $($row.credential_id)" }
        }
        $evidence = if ([IO.Path]::IsPathRooted($row.rejection_evidence_path)) { $row.rejection_evidence_path } else { Join-Path $rootPath $row.rejection_evidence_path }
        $evidenceFull = [IO.Path]::GetFullPath($evidence)
        if (-not $evidenceFull.StartsWith($rootPath + '\', [StringComparison]::OrdinalIgnoreCase)) { throw "evidence path escapes root for $($row.credential_id)" }
        if (-not (Test-Path -LiteralPath $evidenceFull -PathType Leaf)) { throw "missing evidence file for $($row.credential_id)" }
        if ($row.new_storage_type -eq "environment-variable") {
            if (-not $environmentRequirements.ContainsKey($row.credential_id)) { throw "environment requirements missing for $($row.credential_id)" }
            foreach ($name in $environmentRequirements[$row.credential_id]) {
                $value = [Environment]::GetEnvironmentVariable($name, "Process")
                if ([string]::IsNullOrWhiteSpace($value)) { throw "required environment variable missing for $($row.credential_id): $name" }
            }
        }
        if ($row.new_storage_type -eq "github-cli-keyring") {
            if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw "GitHub CLI unavailable" }
            & gh auth status *> $null
            if ($LASTEXITCODE -ne 0) { throw "GitHub CLI authentication unavailable" }
        }
    } elseif ($row.status -eq "rotation_required") {
        $missing = @("rotation_time", "old_value_rejected_at", "rejection_evidence_path", "new_storage_verified_at") | Where-Object { -not $row.$_ }
        $pending.Add([pscustomobject]@{ credential_id = $row.credential_id; missing = ($missing -join ';') })
    } else {
        throw "unsupported status for $($row.credential_id): $($row.status)"
    }
}

Write-Output "rows=$($rows.Count)"
Write-Output "verified=$(@($rows | Where-Object status -eq 'verified_revoked').Count)"
Write-Output "pending=$($pending.Count)"
foreach ($item in $pending) { Write-Output "$($item.credential_id):$($item.missing)" }

if ($pending.Count -gt 0 -and -not $AllowPending) { throw "credential rotation evidence is incomplete" }
Write-Output "PASS: credential rotation ledger structure is valid"
