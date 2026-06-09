$vault = "D:\KnowledgeBase"
$utf8Bom = New-Object System.Text.UTF8Encoding $true

# 统计
$totalMd = (Get-ChildItem $vault -Recurse -Filter "*.md" -File).Count
$cards = (Get-ChildItem "$vault\cards" -Recurse -Filter "*.md" -File).Count
$contentFiles = (Get-ChildItem "$vault\01_Projects\content-creation" -Recurse -Filter "*.md" -File).Count
$flagshipVersions = (Get-ChildItem "$vault\media\flagship" -Directory).Count

$home = @"
# 🏠 知识库主页

> **Vault**: `D:\KnowledgeBase` | 文件: $totalMd 篇 | 深度卡: $cards 张 | 旗舰版本: $flagshipVersions | $(Get-Date -Format 'yyyy-MM-dd')

## 快速导航

| 入口 | 说明 |
|------|------|
| [[_MOC_Cards]] | 深度卡索引（$cards 张卡，按主题簇分类） |
| [[_MOC_Content]] | 内容产出索引（长文/拆书/认知/自媒体等） |
| [[_MOC_Flagship]] | 旗舰作品索引（答案之书 v2→v6 + book-of-life-answers） |
| [[INDEX]] | 全量文件导航 |

## 答案之书（旗舰）

"@

$versions = Get-ChildItem "$vault\media\flagship" -Directory | Sort-Object Name
foreach ($v in $versions) {
    $count = (Get-ChildItem $v.FullName -Filter "*.md" -File).Count
    $chapters = (Get-ChildItem $v.FullName -Filter "CH*.md" -File | Sort-Object Name | Select-Object -First 4).BaseName
    $vRel = $v.FullName.Replace("$vault\", "") -replace '\\','/'
    $home += "### $($v.Name) ($count 篇)`n"
    foreach ($ch in $chapters) {
        $home += "- [[$vRel/$ch]]`n"
    }
    if ((Get-ChildItem $v.FullName -Filter "FULL_MANUSCRIPT.md").Count -gt 0) {
        $home += "- [[$vRel/FULL_MANUSCRIPT|📖 完整手稿]]`n"
    }
    if ((Get-ChildItem $v.FullName -Filter "SOURCE_LEDGER.md").Count -gt 0) {
        $home += "- [[$vRel/SOURCE_LEDGER|🔗 来源账本]]`n"
    }
    $home += "`n"
}

$home += @"
## 内容产出

- [[_MOC_Content|内容产出索引]] — 按类别浏览全部长文
- [[01_Projects/content-creation/cognition/|认知与思维]]
- [[01_Projects/content-creation/self-media/|自媒体与流量]]
- [[01_Projects/content-creation/wealth/|财富与投资]]
- [[01_Projects/content-creation/health/|健康与身体]]
- [[01_Projects/content-creation/relationship/|关系与心理]]
- [[01_Projects/content-creation/book-decons/|拆书笔记]]

## 资源与日志

- [[_logs/reports/|分析报告]]
- [[_logs/skill-reports/|Skill 评测报告]]
- [[_logs/heartbeat/|心跳日志]]
- [[03_Resources/traffic-engineering/|流量工程]]
- [[03_Resources/feishu-dontbesilent/|飞书-DBS社群笔记]]

## 工作区

- [[INDEX]] — 全量文件列表
- [[SKILL_INDEX]] — Skill 索引
- [[_content-system/03-内容单元/|内容单元库]]
- [[_content-system/04-主题地图/|主题地图]]
- [[_meta/|元数据]]
"@

[System.IO.File]::WriteAllText("$vault\HOME.md", $home, $utf8Bom)
Write-Host "HOME.md rebuilt" -ForegroundColor Green
