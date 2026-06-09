$vault = "D:\KnowledgeBase"
$v = $vault

# Delete _alchemist/01_Projects (all near-identical content copies)
$ap = "$v\_alchemist\01_Projects"
if (Test-Path $ap) { 
    $cnt = (Get-ChildItem $ap -Recurse -File).Count
    $sz = [math]::Round(((Get-ChildItem $ap -Recurse -File | Measure-Object Length -Sum).Sum / 1KB), 1)
    Remove-Item $ap -Recurse -Force
    Write-Host "Deleted _alchemist/01_Projects: $cnt files, ${sz}KB"
}

# Delete _alchemist/03_Resources 
$ar = "$v\_alchemist\03_Resources"
if (Test-Path $ar) {
    Remove-Item $ar -Recurse -Force
    Write-Host "Deleted _alchemist/03_Resources"
}

# Check remaining
$rem = Get-ChildItem "$v\_alchemist" -Recurse -File -EA SilentlyContinue
Write-Host "Remaining _alchemist: $($rem.Count) files"

# Final stats
$total = (Get-ChildItem $v -Recurse -Filter "*.md" -File).Count
$totalSize = [math]::Round(((Get-ChildItem $v -Recurse -Filter "*.md" -File | Measure-Object Length -Sum).Sum / 1MB), 2)
Write-Host "Total: $total .md, ${totalSize} MB"
