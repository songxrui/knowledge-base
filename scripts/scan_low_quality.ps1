$vault = "D:\KnowledgeBase"
Write-Host "========== 低质内容扫描 ==========" -ForegroundColor Cyan

# 1. 超短文件 (<100 chars)
Write-Host "`n【1. 超短文件 (<100 chars)】" -ForegroundColor Yellow
$short = @()
foreach ($f in (Get-ChildItem $vault -Recurse -Filter "*.md" -File)) {
    $content = Get-Content $f.FullName -Raw -EA SilentlyContinue
    if (-not $content) { continue }
    $len = $content.Length
    $rel = $f.FullName.Replace("$vault\", "")
    if ($len -lt 100) {
        $short += [PSCustomObject]@{File=$rel; Chars=$len; Dir=(Split-Path $rel)}
    }
}
$short | Sort-Object Chars | Format-Table -AutoSize
Write-Host "超短文件: $($short.Count)"

# 2. 空壳/模板文件（仅含frontmatter或模板占位符）
Write-Host "`n【2. 空壳/模板文件（仅含---和标签）】" -ForegroundColor Yellow
$shells = @()
$templateKeywords = @("替换为","请替换","TODO","FIXME","占位","模板","template")
foreach ($f in (Get-ChildItem $vault -Recurse -Filter "*.md" -File)) {
    $c = Get-Content $f.FullName -Raw -EA SilentlyContinue
    if (-not $c -or $c.Length -gt 300) { continue }
    $rel = $f.FullName.Replace("$vault\", "")
    # 检查是否几乎全是frontmatter
    $cNoFM = $c -replace '(?s)^---.*?---\s*', ''
    $substance = $cNoFM.Trim()
    if ($substance.Length -lt 50 -or ($templateKeywords | Where-Object { $c -match $_ })) {
        $shells += [PSCustomObject]@{File=$rel; BodyChars=$substance.Length; TotalChars=$c.Length}
    }
}
$shells | Sort-Object BodyChars | Format-Table -AutoSize
Write-Host "空壳文件: $($shells.Count)"

# 3. 重复检测（按内容hash）
Write-Host "`n【3. 完全重复文件（MD5相同）】" -ForegroundColor Yellow
$hashes = @{}
$dupes = @()
foreach ($f in (Get-ChildItem $vault -Recurse -Filter "*.md" -File -Exclude "_logs\*","_alchemist\*" | Where-Object { $_.Length -gt 50 })) {
    $hash = (Get-FileHash $f.FullName -Algorithm MD5).Hash
    $rel = $f.FullName.Replace("$vault\", "")
    if ($hashes.ContainsKey($hash)) {
        $dupes += [PSCustomObject]@{File1=$hashes[$hash]; File2=$rel; Size=$f.Length}
    } else {
        $hashes[$hash] = $rel
    }
}
$dupes | Format-Table -AutoSize
Write-Host "重复组: $($dupes.Count)"

# 4. _logs目录中可清理的日志/CSV
Write-Host "`n【4. _logs 目录可清理文件】" -ForegroundColor Yellow
Get-ChildItem "$vault\_logs" -Filter "*.csv" -Name
Get-ChildItem "$vault\_logs" -Filter "broken_links*" -Name

# 5. tmp目录
Write-Host "`n【5. tmp 目录内容】" -ForegroundColor Yellow
Get-ChildItem "$vault\tmp" -Recurse -Name 2>$null | Select-Object -First 20

# 6. 根目录异常文件夹
Write-Host "`n【6. 根目录非标准文件夹】" -ForegroundColor Yellow
$standard = @(".codex",".dbs",".obsidian","00_Inbox","01_Projects","02_Areas","03_Resources","04_Archive","assets","cards","media","notion","scripts","SOURCES","tmp","zettel","_alchemist","_content-system","_logs","_meta","选题管理")
Get-ChildItem $vault -Directory | Where-Object { $_.Name -notin $standard } | ForEach-Object { Write-Host "  $($_.Name) ($((Get-ChildItem $_.FullName -Recurse).Count) items)" }

Write-Host "`n========== 扫描完成 ==========" -ForegroundColor Cyan
