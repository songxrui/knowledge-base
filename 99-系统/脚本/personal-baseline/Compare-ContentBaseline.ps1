[CmdletBinding()]
param([string]$VaultRoot, [switch]$AsJson, [switch]$FailOnError)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'PersonalBaseline.Automation.psm1') -Force
$root = Resolve-PBVaultRoot -VaultRoot $VaultRoot
$configuration = Get-PBConfiguration -VaultRoot $root
$result = Compare-PBContentBaseline -VaultRoot $root -Configuration $configuration
if ($AsJson) { $result | ConvertTo-Json -Depth 50 } else { $result }
if ($FailOnError -and @($result.issues | Where-Object severity -eq 'error').Count -gt 0) { exit 1 }
