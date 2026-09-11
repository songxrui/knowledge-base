[CmdletBinding()]
param([string]$VaultRoot, [switch]$AsJson, [switch]$FailOnError)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'PersonalBaseline.Automation.psm1') -Force
$root = Resolve-PBVaultRoot -VaultRoot $VaultRoot
$configuration = Get-PBConfiguration -VaultRoot $root
$result = New-PBCheckResult -Check 'contract-schema' -Issues @(Test-PBContractSchema -VaultRoot $root -Configuration $configuration)
if ($AsJson) { $result | ConvertTo-Json -Depth 50 } else { $result }
if ($FailOnError -and $result.summary.errors -gt 0) { exit 1 }
