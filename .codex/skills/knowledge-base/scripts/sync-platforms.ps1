# Cross-Platform Sync Script
# Syncs knowledge-base skill across Codex, CodeWhale, and GitHub
param(
    [ValidateSet("codex-to-codewhale", "codewhale-to-codex", "push-github", "all")]
    [string]$Direction = "all"
)

$codexSkills = "$env:USERPROFILE\.codex\skills\knowledge-base"
$codewhaleSkills = "$env:USERPROFILE\.codewhale\skills\knowledge-base"
$vault = if ($env:KNOWLEDGE_VAULT) { $env:KNOWLEDGE_VAULT } else { "D:\KnowledgeBase" }

function Sync-CodexToCodeWhale {
    Write-Host "[sync] Codex → CodeWhale"
    if (-not (Test-Path $codexSkills)) {
        Write-Host "  [ERROR] Codex skills not found at: $codexSkills"
        return
    }
    New-Item -ItemType Directory $codewhaleSkills -Force | Out-Null
    robocopy $codexSkills $codewhaleSkills /MIR /NJH /NJS /NP /NDL
    if ($LASTEXITCODE -le 3) {
        Write-Host "  [OK] Synced"
    } else {
        Write-Host "  [WARN] robocopy exit code: $LASTEXITCODE"
    }
}

function Sync-CodeWhaleToCodex {
    Write-Host "[sync] CodeWhale → Codex"
    if (-not (Test-Path $codewhaleSkills)) {
        Write-Host "  [ERROR] CodeWhale skills not found at: $codewhaleSkills"
        return
    }
    New-Item -ItemType Directory $codexSkills -Force | Out-Null
    robocopy $codewhaleSkills $codexSkills /MIR /NJH /NJS /NP /NDL
    if ($LASTEXITCODE -le 3) {
        Write-Host "  [OK] Synced"
    } else {
        Write-Host "  [WARN] robocopy exit code: $LASTEXITCODE"
    }
}

function Push-GitHub {
    Write-Host "[sync] Push to GitHub"
    if (-not (Test-Path $vault)) {
        Write-Host "  [ERROR] Vault not found at: $vault"
        return
    }
    Push-Location $vault
    $status = git status --short 2>$null
    if ($status) {
        git add -A
        git commit -m "sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm')" 2>&1 | Out-Null
        git push 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] Pushed to GitHub"
        } else {
            Write-Host "  [ERROR] Push failed. Check: gh auth status"
        }
    } else {
        Write-Host "  [SKIP] No changes to push"
    }
    Pop-Location
}

Write-Host "=== Knowledge Base Cross-Platform Sync ==="
Write-Host "  Direction: $Direction"
Write-Host ""

switch ($Direction) {
    "codex-to-codewhale" { Sync-CodexToCodeWhale }
    "codewhale-to-codex" { Sync-CodeWhaleToCodex }
    "push-github" { Push-GitHub }
    "all" {
        Sync-CodexToCodeWhale
        Write-Host ""
        Push-GitHub
    }
}

Write-Host "`n=== Sync complete ==="
