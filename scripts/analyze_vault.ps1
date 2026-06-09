# Obsidian Vault Analyzer for D:\KnowledgeBase
$vault = "D:\KnowledgeBase"
$ErrorActionPreference = "Continue"

Write-Host "========== Obsidian Vault 深度分析 ==========" -ForegroundColor Cyan
Write-Host "Vault: $vault`n"

# 1. 全量扫描
$allMd = Get-ChildItem -Path $vault -Recurse -Filter "*.md" -File
$allNames = @{}
foreach ($f in $allMd) {
    $base = $f.BaseName
    $rel = $f.FullName.Replace("$vault\", "")
    if (-not $allNames.ContainsKey($base)) { $allNames[$base] = @() }
    $allNames[$base] += $rel
}

Write-Host "【基础统计】"
Write-Host "  .md文件总数: $($allMd.Count)"
Write-Host "  唯一文件名数: $($allNames.Count)"
Write-Host ""

# 2. 扫描所有 [[Wiki链接]]
$allLinks = @{}  # source_file -> @(target_names)
$allIncoming = @{}  # target_name -> @(source_files)
$brokenLinks = @()

foreach ($f in $allMd) {
    $content = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }
    $rel = $f.FullName.Replace("$vault\", "")
    $matches = [regex]::Matches($content, '\[\[([^\]|#]+)(?:[|#][^\]]+)?\]\]')
    foreach ($m in $matches) {
        $target = $m.Groups[1].Value.Trim()
        if (-not $allLinks.ContainsKey($rel)) { $allLinks[$rel] = @() }
        $allLinks[$rel] += $target
        if (-not $allIncoming.ContainsKey($target)) { $allIncoming[$target] = @() }
        $allIncoming[$target] += $rel
    }
}

$totalLinks = ($allLinks.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
Write-Host "【链接统计】"
Write-Host "  总[[Wiki链接]]数: $totalLinks"
Write-Host "  有出链的文件数: $($allLinks.Count)"
Write-Host "  被引用的目标数: $($allIncoming.Count)"
Write-Host ""

# 3. 断链检测
$brokenDetail = @()
foreach ($source in $allLinks.Keys) {
    foreach ($target in $allLinks[$source]) {
        if (-not $allNames.ContainsKey($target)) {
            $brokenDetail += [PSCustomObject]@{ Source=$source; Target=$target }
        }
    }
}
$brokenDetail = $brokenDetail | Sort-Object Source -Unique

Write-Host "【断链/死链检测】" -ForegroundColor Red
Write-Host "  断链总数: $($brokenDetail.Count)"
if ($brokenDetail.Count -gt 0) {
    $brokenDetail | Select-Object -First 20 | Format-Table -AutoSize
}
Write-Host ""

# 4. 孤点笔记 (有出链但无入链 / 完全无链接)
$orphanCandidates = @()
foreach ($f in $allMd) {
    $rel = $f.FullName.Replace("$vault\", "")
    $base = $f.BaseName
    $hasOut = $allLinks.ContainsKey($rel)
    $hasIn = $allIncoming.ContainsKey($base)
    if ($hasOut -and -not $hasIn) {
        $orphanCandidates += [PSCustomObject]@{ File=$rel; Type="有出无入"; Links=($allLinks[$rel] -join ", ").Substring(0, [Math]::Min(80, ($allLinks[$rel] -join ", ").Length)) }
    } elseif (-not $hasOut -and -not $hasIn) {
        $orphanCandidates += [PSCustomObject]@{ File=$rel; Type="完全孤立"; Links="" }
    }
}

Write-Host "【孤点分析】"
Write-Host "  有出无入: $(($orphanCandidates | Where-Object { $_.Type -eq '有出无入' }).Count)"
Write-Host "  完全孤立: $(($orphanCandidates | Where-Object { $_.Type -eq '完全孤立' }).Count)"
Write-Host ""

# 5. 按目录热度统计
Write-Host "【目录热度（按.md文件数）】" -ForegroundColor Yellow
$dirStats = $allMd | ForEach-Object {
    $dir = ($_.FullName.Replace("$vault\", "").Split([IO.Path]::DirectorySeparatorChar))[0]
    if (-not $dir) { $dir = "(root)" }
    $dir
} | Group-Object | Sort-Object Count -Descending

foreach ($g in $dirStats) {
    $bar = "=" * [Math]::Min(40, $g.Count / 3)
    Write-Host ("  {0,-25} {1,5}  {2}" -f $g.Name, $g.Count, $bar)
}
Write-Host ""

# 6. 高价值文件（入链最多的笔记）
Write-Host "【最高入链 Hub节点 Top15】" -ForegroundColor Green
$hubNodes = $allIncoming.GetEnumerator() | ForEach-Object { 
    $uniqueSources = $_.Value | Sort-Object -Unique
    [PSCustomObject]@{ Target=$_.Key; Incoming=($uniqueSources.Count); Sources=($uniqueSources -join "; ").Substring(0, [Math]::Min(120, ($uniqueSources -join "; ").Length)) }
} | Sort-Object Incoming -Descending | Select-Object -First 15
$hubNodes | Format-Table -AutoSize
Write-Host ""

# 7. 非标准目录文件
Write-Host "【根目录裸露文件（未归类）】" -ForegroundColor Magenta
$rootFiles = Get-ChildItem -Path $vault -Filter "*.md" -File | Select-Object -ExpandProperty Name
$standardDirs = @("00_Inbox","01_Projects","02_Areas","03_Resources","04_Archive","media","cards","assets","notion","tmp","zettel","scripts","SOURCES","选题管理","_alchemist","_content-system","_logs","_meta",".obsidian",".dbs",".codex")
foreach ($f in $rootFiles) {
    Write-Host "  (root)/$f"
}
Write-Host ""

# 8. 断链详情输出到文件
$reportDir = "$vault\_logs"
if (-not (Test-Path $reportDir)) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }

$brokenDetail | Export-Csv "$reportDir\broken_links.csv" -NoTypeInformation -Encoding UTF8
$orphanCandidates | Export-Csv "$reportDir\orphan_notes.csv" -NoTypeInformation -Encoding UTF8

Write-Host "========== 报告已保存 ==========" -ForegroundColor Cyan
Write-Host "  断链清单: $reportDir\broken_links.csv"
Write-Host "  孤点清单: $reportDir\orphan_notes.csv"
