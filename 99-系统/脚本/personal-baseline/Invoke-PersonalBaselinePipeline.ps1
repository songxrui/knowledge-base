[CmdletBinding()]
param(
    [ValidateSet('audit','safe-fix','candidate','full-local','verify')][string]$Mode = 'audit',
    [string]$VaultRoot,
    [switch]$CheckExternal,
    [switch]$NoWrite,
    [switch]$AsJson
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'PersonalBaseline.Automation.psm1') -Force
$root = Resolve-PBVaultRoot -VaultRoot $VaultRoot
$configuration = Get-PBConfiguration -VaultRoot $root
$report = Invoke-PBPipeline -VaultRoot $root -Configuration $configuration -Mode $Mode -CheckExternal:$CheckExternal -NoWrite:$NoWrite
if ($AsJson) { $report | ConvertTo-Json -Depth 50 } else { $report }
if ($report.status -ne 'pass') { exit 1 }
