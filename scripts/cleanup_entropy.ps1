$vault = "D:\KnowledgeBase"
$log = @()
$log += "# 熵增清理日志 | $(Get-Date -Format 'yyyy-MM-dd HH:mm')"

# Step 1: Build main directory hash index (excluding _alchemist, .codex, etc.)
$mainHashes = @{}
$excludePrefixes = @("_alchemist\", ".codex\", ".dbs\", ".obsidian\", "tmp\", "04_Archive\")
foreach ($f in (Get-ChildItem $vault -Recurse -Filter "*.md" -File)) {
    $rel = $f.FullName.Replace("$vault\", "")
    $skip = $false
    foreach ($p in $excludePrefixes) { if ($rel.StartsWith($p)) { $skip = $true; break } }
    if ($skip) { continue }
    $mainHashes[(Get-FileHash $f.FullName -Algorithm MD5).Hash] = $rel
}
Write-Host "Main index: $($mainHashes.Count) unique hashes"

# Step 2: Find duplicates and uniques in _alchemist
$dupCount = 0; $dupSize = 0; $uniqueList = @()
foreach ($f in (Get-ChildItem "$vault\_alchemist" -Recurse -Filter "*.md" -File)) {
    $h = (Get-FileHash $f.FullName -Algorithm MD5).Hash
    $rel = $f.FullName.Replace("$vault\", "")
    if ($mainHashes.ContainsKey($h)) {
        # Duplicate - delete
        $dupSize += $f.Length
        Remove-Item $f.FullName -Force
        $dupCount++
    } else {
        $uniqueList += $rel
    }
}
Write-Host "_alchemist: $dupCount dupes deleted ($([math]::Round($dupSize/1KB,1)) KB)"
Write-Host "_alchemist: $($uniqueList.Count) unique files retained"
foreach ($u in $uniqueList) { Write-Host "  UNIQUE: $u" -ForegroundColor Cyan }

# Step 3: Delete temp CSVs
$temps = @("$vault\_logs\broken_links.csv", "$vault\_logs\broken_links_v2.csv", "$vault\_logs\orphan_notes.csv")
foreach ($t in $temps) {
    if (Test-Path $t) { Remove-Item $t -Force; Write-Host "Deleted: temp CSV" }
}

# Step 4: Delete empty directories in _alchemist
$emptyDirs = (Get-ChildItem "$vault\_alchemist" -Recurse -Directory | Where-Object { (Get-ChildItem $_.FullName -Recurse -File).Count -eq 0 }) | Sort-Object FullName -Descending
foreach ($d in $emptyDirs) {
    Remove-Item $d.FullName -Force
    Write-Host "Removed empty dir: $($d.FullName.Replace("$vault\",""))"
}

# Step 5: Generate cleanup report
$newTotal = (Get-ChildItem $vault -Recurse -Filter "*.md" -File).Count
$newSize = [math]::Round(((Get-ChildItem $vault -Recurse -Filter "*.md" -File | Measure-Object Length -Sum).Sum / 1MB), 2)
$report = @"
# 熵增清理报告 | $(Get-Date -Format 'yyyy-MM-dd HH:mm')

## 清理操作
| 操作 | 文件数 | 大小 |
|------|--------|------|
| 删除_alchemist重复 | $dupCount | $([math]::Round($dupSize/1KB,1)) KB |
| 删除临时CSV | 3 | - |
| 清理空目录 | $($emptyDirs.Count) | - |

## 清理后状态
- .md文件: $newTotal
- 总大小: ${newSize} MB
- _alchemist独有保留: $($uniqueList.Count) files

## 独有文件列表
$($uniqueList | ForEach-Object { "- ``$_``" } | Out-String)
"@
$utf8Bom = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText("$vault\_logs\CLEANUP_REPORT_2026-06-09.md", $report, $utf8Bom)
Write-Host "`nReport saved: _logs\CLEANUP_REPORT_2026-06-09.md" -ForegroundColor Green
