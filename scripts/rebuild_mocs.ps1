# 重建 MOC 索引文件 - UTF-8 编码
$vault = "D:\KnowledgeBase"
$utf8Bom = New-Object System.Text.UTF8Encoding $true

# ============================================
# 1. _MOC_Cards.md - 深度卡索引
# ============================================
$cards = Get-ChildItem "$vault\cards" -Recurse -Filter "*.md" | Sort-Object Name
$topicCards = $cards | Where-Object { $_.Directory.Name -eq "topics" } | Sort-Object Name
$mainCards = $cards | Where-Object { $_.Directory.Name -eq "cards" } | Sort-Object Name

$mocCards = @"
# 深度卡索引 (Map of Content - Cards)

> 自动生成于 $(Get-Date -Format 'yyyy-MM-dd HH:mm') | 共 $($cards.Count) 张卡

## 主体卡 ($($mainCards.Count)张)

"@

$lastCluster = ""
foreach ($c in $mainCards) {
    $name = $c.BaseName
    $cluster = $name -replace '^(C\d+).*', '$1'
    if ($cluster -ne $lastCluster) {
        $clusterNames = @{
            "C1" = "身心健康"
            "C2" = "认知与决策"
            "C3" = "财富与投资"
            "C4" = "内容创作与个人IP"
            "C5" = "关系与形象"
            "C6" = "系统与习惯"
            "C7" = "思维模型与第一性原理"
        }
        $cn = if ($clusterNames.ContainsKey($cluster)) { $clusterNames[$cluster] } else { $cluster }
        $mocCards += "`n### $cluster — $cn`n"
        $lastCluster = $cluster
    }
    $mocCards += "- [[cards/$name]]`n"
}

$mocCards += @"

## 主题卡 ($($topicCards.Count)张)

"@

$lastTopicCluster = ""
foreach ($c in $topicCards) {
    $name = $c.BaseName
    $cluster = $name -replace '^(T\d+).*', '$1'
    if ($cluster -ne $lastTopicCluster) {
        $clusterNames = @{
            "T1" = "多巴胺与成瘾"
            "T2" = "代谢与饮食"
            "T3" = "认知心理学"
            "T4" = "效率与习惯"
            "T5" = "财富哲学"
            "T6" = "权力与社会"
            "T7" = "关系与依恋"
            "T8" = "自媒体与流量"
            "T9" = "中医系统论"
            "T10" = "自律与反脆弱"
        }
        $cn = if ($clusterNames.ContainsKey($cluster)) { $clusterNames[$cluster] } else { $cluster }
        $mocCards += "`n### $cluster — $cn`n"
        $lastTopicCluster = $cluster
    }
    $mocCards += "- [[cards/topics/$name]]`n"
}

[System.IO.File]::WriteAllText("$vault\_MOC_Cards.md", $mocCards, $utf8Bom)
Write-Host "_MOC_Cards.md rebuilt: $($mainCards.Count) main + $($topicCards.Count) topic = $($cards.Count) cards"

# ============================================
# 2. _MOC_Content.md - 内容产出索引
# ============================================
$contentBase = "$vault\01_Projects\content-creation"
$contentDirs = Get-ChildItem $contentBase -Directory | Where-Object { $_.Name -ne "publishing" -and $_.Name -ne "social-cards" }

$mocContent = @"
# 内容产出索引 (Map of Content - Creation)

> 自动生成于 $(Get-Date -Format 'yyyy-MM-dd HH:mm')

"@

foreach ($dir in $contentDirs) {
    $files = Get-ChildItem $dir.FullName -Filter "*.md" -File | Sort-Object Name
    if ($files.Count -eq 0) { continue }
    $dirRel = $dir.FullName.Replace("$vault\", "") -replace '\\','/'
    $mocContent += "`n## $($dir.Name) ($($files.Count)篇)`n"
    foreach ($f in $files) {
        $mocContent += "- [[$dirRel/$($f.BaseName)]]`n"
    }
}

[System.IO.File]::WriteAllText("$vault\_MOC_Content.md", $mocContent, $utf8Bom)
Write-Host "_MOC_Content.md rebuilt: $($contentDirs.Count) categories"

# ============================================
# 3. _MOC_Flagship.md - 旗舰作品索引
# ============================================
$flagshipBase = "$vault\media\flagship"
$versions = Get-ChildItem $flagshipBase -Directory | Sort-Object Name

$mocFlagship = @"
# 旗舰作品索引 (Map of Content - Flagship)

> 自动生成于 $(Get-Date -Format 'yyyy-MM-dd HH:mm') | 共 $($versions.Count) 个版本

"@

foreach ($v in $versions) {
    $files = Get-ChildItem $v.FullName -Filter "*.md" -File | Sort-Object Name
    $vRel = $v.FullName.Replace("$vault\", "") -replace '\\','/'
    $mocFlagship += "`n## $($v.Name) ($($files.Count)篇)`n"
    foreach ($f in $files) {
        $mocFlagship += "- [[$vRel/$($f.BaseName)]]`n"
    }
}

[System.IO.File]::WriteAllText("$vault\_MOC_Flagship.md", $mocFlagship, $utf8Bom)
Write-Host "_MOC_Flagship.md rebuilt: $($versions.Count) versions"

Write-Host "`nAll MOC files rebuilt with UTF-8 encoding." -ForegroundColor Green
