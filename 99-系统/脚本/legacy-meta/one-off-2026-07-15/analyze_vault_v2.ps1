# Obsidian Vault Analyzer v2 - 正确解析Wiki链接（按Obsidian规则）
$vault = "D:\KnowledgeBase"
$ErrorActionPreference = "Continue"

# 1. 扫描所有md文件
$allMd = Get-ChildItem -Path $vault -Recurse -Filter "*.md" -File
# 建两个索引：纯文件名->路径, 相对路径->true
$byName = @{}   # basename -> @(relpaths)
$byPath = @{}   # relpath without .md -> true
foreach ($f in $allMd) {
    $base = $f.BaseName
    $rel = $f.FullName.Replace("$vault\", "") -replace '\.md$',''
    if (-not $byName.ContainsKey($base)) { $byName[$base] = @() }
    $byName[$base] += $rel
    $byPath[$rel] = $true
}

Write-Host "文件总数: $($allMd.Count), 唯一文件名: $($byName.Count)" -ForegroundColor Cyan

# 2. 扫描所有Wiki链接并解析
$brokenLinks = @()
$allOutgoing = @{}
$allIncoming = @{}
$dirLinks = @{}  # 目录链接（指向文件夹）

foreach ($f in $allMd) {
    $content = Get-Content $f.FullName -Raw -EA SilentlyContinue
    if (-not $content) { continue }
    $rel = $f.FullName.Replace("$vault\", "")
    $matches = [regex]::Matches($content, '\[\[([^\]|#]+)(?:[|#][^\]]+)?\]\]')
    foreach ($m in $matches) {
        $rawTarget = $m.Groups[1].Value.Trim()
        # Obsidian解析规则：取最后的文件名部分（去掉路径），匹配任意.md文件
        $parts = $rawTarget -split '/'
        $baseTarget = $parts[-1]
        
        if (-not $allOutgoing.ContainsKey($rel)) { $allOutgoing[$rel] = @() }
        $allOutgoing[$rel] += $rawTarget
        
        # 检查是否存在
        $found = $false
        # 1) 精确路径匹配
        if ($byPath.ContainsKey($rawTarget)) {
            $found = $true
        }
        # 2) 文件名匹配（Obsidian默认行为）
        elseif ($byName.ContainsKey($baseTarget)) {
            $found = $true
        }
        # 3) 可能是目录链接（Obsidian folder note）
        elseif (Test-Path (Join-Path $vault $rawTarget) -PathType Container) {
            $found = $true
            if (-not $dirLinks.ContainsKey($rel)) { $dirLinks[$rel] = @() }
            $dirLinks[$rel] += $rawTarget
        }
        
        if ($found) {
            if (-not $allIncoming.ContainsKey($baseTarget)) { $allIncoming[$baseTarget] = @() }
            $allIncoming[$baseTarget] += $rel
        } else {
            $brokenLinks += [PSCustomObject]@{ Source=$rel; Target=$rawTarget }
        }
    }
}

# 统计
$totalLinks = ($allOutgoing.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
$uniqueBroken = $brokenLinks | Sort-Object Source, Target -Unique

Write-Host "=== 准确统计 ===" -ForegroundColor Green
Write-Host "Wiki链接总数: $totalLinks"
Write-Host "有出链的文件: $($allOutgoing.Count)"
Write-Host "被引用的目标: $($allIncoming.Count)"
Write-Host "目录链接数: $(($dirLinks.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum)"
Write-Host ""

# 孤点
$linkedFiles = @{}
foreach ($k in $allOutgoing.Keys) { $linkedFiles[$k] = $true }
foreach ($v in $allIncoming.Values) { foreach ($r in $v) { $linkedFiles[$r] = $true } }
$orphans = $allMd | Where-Object { -not $linkedFiles.ContainsKey(($_.FullName.Replace("$vault\", ""))) }

Write-Host "=== 断链 ===" -ForegroundColor Red
Write-Host "真正断链数: $($uniqueBroken.Count)"
$uniqueBroken | Format-Table -AutoSize
Write-Host ""

Write-Host "=== 孤点（无任何链接） ===" -ForegroundColor Yellow
Write-Host "孤点文件: $($orphans.Count) / $($allMd.Count)"
Write-Host ""

# Hub节点 Top 20
Write-Host "=== Hub节点 Top 20 ===" -ForegroundColor Green
$hubs = $allIncoming.GetEnumerator() | ForEach-Object {
    $sources = $_.Value | Sort-Object -Unique
    [PSCustomObject]@{ Node=$_.Key; Inbound=($sources.Count) }
} | Sort-Object Inbound -Descending | Select-Object -First 20
$hubs | Format-Table -AutoSize

# 保存报告
$reportPath = "$vault\_logs"
if (-not (Test-Path $reportPath)) { New-Item -ItemType Directory -Path $reportPath -Force | Out-Null }
$uniqueBroken | Export-Csv "$reportPath\broken_links_v2.csv" -NoTypeInformation -Encoding UTF8
