# Weekly Review Script (parameterized)
param(
    [string]$VaultPath = $env:KNOWLEDGE_VAULT
)

if (-not $VaultPath) {
    $VaultPath = "D:\KnowledgeBase"
    Write-Host "[WARN] KNOWLEDGE_VAULT not set, using default: $VaultPath" -ForegroundColor Yellow
}

if (-not (Test-Path $VaultPath)) {
    Write-Host "[ERROR] Vault path not found: $VaultPath" -ForegroundColor Red
    Write-Host "  Set `$env:KNOWLEDGE_VAULT or pass -VaultPath parameter"
    exit 1
}

Write-Host "=== Weekly Review: $(Get-Date -Format 'yyyy-MM-dd') ===" -ForegroundColor Cyan
Write-Host "  Vault: $VaultPath`n"

# Step 1: Check Inbox
$inbox = Join-Path $VaultPath "00_Inbox"
$inboxCount = (Get-ChildItem $inbox -File -ErrorAction SilentlyContinue | Measure-Object).Count
Write-Host "[1/5] Inbox: $inboxCount item(s)"
if ($inboxCount -gt 0) {
    Write-Host "  Items awaiting processing:"
    Get-ChildItem $inbox -File | ForEach-Object { Write-Host "    - $($_.Name)" }
}
if ($inboxCount -gt 10) {
    Write-Host "  [WARN] Inbox > 10 items. Consider batch archive or delete." -ForegroundColor Yellow
}

# Step 2: Check orphan zettels (empty backlinks)
$zettel = Join-Path $VaultPath "zettel"
Write-Host ""
Write-Host "[2/5] Zettel orphan check"
$orphanCount = 0
if (Test-Path $zettel) {
    Get-ChildItem $zettel -Filter "*.md" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        if ($content -notmatch "## 关联" -or $content -match "## 关联\s*$") {
            Write-Host "  [ORPHAN] $($_.Name)" -ForegroundColor Yellow
            $orphanCount++
        }
    }
}
Write-Host "  Orphans found: $orphanCount"

# Step 3: Check source annotations
Write-Host ""
Write-Host "[3/5] Source annotation audit"
$noSourceCount = 0
if (Test-Path $zettel) {
    Get-ChildItem $zettel -Filter "*.md" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        if ($content -notmatch "\[来源[:：]") {
            Write-Host "  [NO_SOURCE] $($_.Name)" -ForegroundColor Yellow
            $noSourceCount++
        }
    }
}
Write-Host "  Items without source: $noSourceCount"

# Step 4: Git status
Write-Host ""
Write-Host "[4/5] Git status"
Push-Location $VaultPath
$gitStatus = git status --short 2>$null
if ($gitStatus) {
    Write-Host "  Uncommitted changes:"
    $gitStatus -split "`n" | ForEach-Object { Write-Host "    $_" }
    $commitMsg = "weekly: $(Get-Date -Format 'yyyy-MM-dd')"
    Write-Host "`n  Auto-commit with: git add -A; git commit -m '$commitMsg'"
    git add -A
    git commit -m $commitMsg 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Committed: $commitMsg" -ForegroundColor Green
    } else {
        Write-Host "  [SKIP] No changes or commit failed" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Working tree clean"
}
Pop-Location

# Step 5: Summary
Write-Host ""
Write-Host "[5/5] Summary" -ForegroundColor Cyan
Write-Host "  Vault: $VaultPath"
Write-Host "  Inbox items: $inboxCount"
Write-Host "  Orphan zettels: $orphanCount"
Write-Host "  Missing sources: $noSourceCount"
Write-Host "  Recommended actions:"
if ($inboxCount -gt 0) { Write-Host "    - Process or archive inbox items" }
if ($orphanCount -gt 0) { Write-Host "    - Add backlinks to orphan zettels" }
if ($noSourceCount -gt 0) { Write-Host "    - Add source annotations to [$noSourceCount] notes" }
if ($inboxCount -eq 0 -and $orphanCount -eq 0 -and $noSourceCount -eq 0) {
    Write-Host "    [DONE] Everything looks clean!" -ForegroundColor Green
}

Write-Host "`n=== Review complete ===" -ForegroundColor Cyan
