[CmdletBinding()]
param([string]$VaultRoot, [switch]$NoWrite, [switch]$AsJson)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'PersonalBaseline.Automation.psm1') -Force
$root = Resolve-PBVaultRoot -VaultRoot $VaultRoot
$configuration = Get-PBConfiguration -VaultRoot $root
$result = New-PBRefactorCandidates -VaultRoot $root -Configuration $configuration -Write:(-not $NoWrite)
if ($AsJson) { $result | ConvertTo-Json -Depth 50 } else { $result }
