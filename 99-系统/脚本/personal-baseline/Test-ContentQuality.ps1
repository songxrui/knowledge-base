[CmdletBinding()]
param([string]$VaultRoot, [switch]$AsJson, [switch]$FailOnError)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'PersonalBaseline.Automation.psm1') -Force
$root = Resolve-PBVaultRoot -VaultRoot $VaultRoot
$configuration = Get-PBConfiguration -VaultRoot $root
$issues = [Collections.Generic.List[object]]::new()
foreach ($issue in Test-PBContentQuality -VaultRoot $root -Configuration $configuration) { $issues.Add($issue) }
foreach ($duplicate in Get-PBExactDuplicateParagraphs -VaultRoot $root -Configuration $configuration) {
    $paths = @($duplicate.occurrences | ForEach-Object path) -join ', '
    $issues.Add((New-PBIssue -Severity info -Rule 'quality-exact-duplicate' -Path $duplicate.occurrences[0].path -Message "Exact paragraph appears in: $paths" -Action candidate))
}
$result = New-PBCheckResult -Check 'content-quality' -Issues @($issues)
if ($AsJson) { $result | ConvertTo-Json -Depth 50 } else { $result }
if ($FailOnError -and $result.summary.errors -gt 0) { exit 1 }
