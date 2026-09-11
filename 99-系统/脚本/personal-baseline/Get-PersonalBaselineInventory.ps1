[CmdletBinding()]
param(
    [string]$VaultRoot,
    [string]$OutputPath,
    [switch]$InitializeBaseline,
    [switch]$Force,
    [switch]$NoWrite,
    [switch]$AsJson
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'PersonalBaseline.Automation.psm1') -Force

$root = Resolve-PBVaultRoot -VaultRoot $VaultRoot
$configuration = Get-PBConfiguration -VaultRoot $root
$manifest = New-PBInventoryManifest -VaultRoot $root -Configuration $configuration

if (-not $NoWrite) {
    if ([string]::IsNullOrWhiteSpace($OutputPath)) {
        $name = if ($InitializeBaseline) { 'baseline-manifest.json' } else { 'current-manifest.json' }
        $OutputPath = Join-PBPath -VaultRoot $root -RelativePath (([string]$configuration.Policy.metadataRoot) + '/' + $name)
    } elseif (-not [IO.Path]::IsPathRooted($OutputPath)) {
        $OutputPath = Join-PBPath -VaultRoot $root -RelativePath $OutputPath
    }

    $outputRelative = ConvertTo-PBRelativePath -VaultRoot $root -Path $OutputPath
    if (-not (Test-PBPathUnderRoot -RelativePath $outputRelative -RelativeRoot ([string]$configuration.Policy.metadataRoot))) {
        throw "Inventory output must remain under the configured metadata root: $outputRelative"
    }

    if ($InitializeBaseline -and (Test-Path -LiteralPath $OutputPath)) {
        if (-not $Force) {
            throw "Baseline manifest already exists. Use -Force only after an intentional baseline reset: $OutputPath"
        }

        $existing = Read-PBJson -Path $OutputPath
        $safeVersion = ([string]$existing.productVersion -replace '[^A-Za-z0-9._-]', '_')
        $archiveName = "$safeVersion-$([string]$existing.fingerprint).json"
        $archivePath = Join-PBPath -VaultRoot $root -RelativePath (([string]$configuration.Policy.metadataRoot) + '/baselines/' + $archiveName)
        if (Test-Path -LiteralPath $archivePath) {
            $archived = Read-PBJson -Path $archivePath
            if ([string]$archived.fingerprint -ne [string]$existing.fingerprint) {
                throw "Baseline archive conflicts with the current baseline: $archivePath"
            }
        } else {
            Write-PBJson -InputObject $existing -Path $archivePath
        }
    }
    Write-PBJson -InputObject $manifest -Path $OutputPath
}

if ($AsJson) {
    $manifest | ConvertTo-Json -Depth 50
} else {
    $manifest
}
