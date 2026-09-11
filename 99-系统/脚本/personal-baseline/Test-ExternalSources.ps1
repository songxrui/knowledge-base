[CmdletBinding()]
param([string]$VaultRoot, [int]$MaxUrls = 0, [switch]$AsJson, [switch]$FailOnError)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'PersonalBaseline.Automation.psm1') -Force
$root = Resolve-PBVaultRoot -VaultRoot $VaultRoot
$configuration = Get-PBConfiguration -VaultRoot $root
$result = New-PBCheckResult -Check 'external-sources' -Issues @(Test-PBExternalSources -VaultRoot $root -Configuration $configuration -MaxUrls $MaxUrls)
if ($AsJson) { $result | ConvertTo-Json -Depth 50 } else { $result }
if ($FailOnError -and $result.summary.errors -gt 0) { exit 1 }
