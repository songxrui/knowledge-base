$vault = "D:\KnowledgeBase"
$ErrorActionPreference = "Continue"

# Build name index (same as working test)
$allMd = Get-ChildItem -Path $vault -Recurse -Filter "*.md" -File
$byName = @{}
foreach ($f in $allMd) { 
    if (-not $byName.ContainsKey($f.BaseName)) { $byName[$f.BaseName] = @() }
    $byName[$f.BaseName] += $f.FullName.Replace("$vault\", "") -replace '\.md$',''
}

$broken = @()
$totalLinks = 0
$outgoingFiles = 0
$incomingNodes = @{}
$dirLinks = 0

foreach ($f in $allMd) {
    $content = Get-Content $f.FullName -Raw -EA SilentlyContinue
    if (-not $content) { continue }
    $rel = $f.FullName.Replace("$vault\", "") -replace '\.md$',''
    $m = [regex]::Matches($content, '\[\[([^\]|#]+)(?:[|#][^\]]+)?\]\]')
    if ($m.Count -eq 0) { continue }
    $outgoingFiles++
    $totalLinks += $m.Count
    foreach ($match in $m) {
        $raw = $match.Groups[1].Value.Trim()
        $base = ($raw -split '/')[-1]
        
        # Check if folder (ends with / or is a folder note)
        if ($raw -match '/$' -or (Test-Path (Join-Path $vault $raw) -PathType Container 2>$null)) {
            $dirLinks++
            continue
        }
        
        if ($byName.ContainsKey($base)) {
            if (-not $incomingNodes.ContainsKey($base)) { $incomingNodes[$base] = @() }
            $incomingNodes[$base] += $rel
        } else {
            $broken += [PSCustomObject]@{ Source=$rel; Target=$raw; Base=$base }
        }
    }
}

$uniqueBroken = $broken | Sort-Object Source, Target -Unique

Write-Host "【Vault 深度分析 v2.1】" -ForegroundColor Cyan
Write-Host "文件总数: $($allMd.Count)"
Write-Host "Wiki链接总数: $totalLinks"
Write-Host "有出链文件: $outgoingFiles"
Write-Host "被引用节点: $($incomingNodes.Count)"
Write-Host "目录链接: $dirLinks"
Write-Host ""

Write-Host "【真正断链: $($uniqueBroken.Count)个】" -ForegroundColor Red
$uniqueBroken | Format-Table Source, Target -AutoSize -Wrap
Write-Host ""

Write-Host "【Hub Top 15】" -ForegroundColor Green
$incomingNodes.GetEnumerator() | ForEach-Object { 
    [PSCustomObject]@{ Node=$_.Key; In=($_.Value | Sort-Object -Unique).Count }
} | Sort-Object In -Descending | Select-Object -First 15 | Format-Table -AutoSize

Write-Host ""
Write-Host "【孤点率: $(($allMd.Count - $outgoingFiles - ($incomingNodes.Values | ForEach-Object { $_ } | Select-Object -Unique).Count)) / $($allMd.Count) ≈ $([math]::Round(100 * ($allMd.Count - $outgoingFiles) / $allMd.Count, 1))%】" -ForegroundColor Yellow
