param(
    [string]$Root = "D:\KnowledgeBase",
    [string]$OutputPath = "99-系统\元数据\inventory\META_ABILITIES_CLAIM_LEDGER_2026-07-17.csv"
)

$ErrorActionPreference = "Stop"
$projectPath = Join-Path $Root "01-项目\meta-abilities"
$output = if ([IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { Join-Path $Root $OutputPath }
$claimPattern = '\d+(?:\.\d+)?\s*(?:%|％|倍|天|小时|分钟|秒|周|月|年|人|次|项|种|层|步|个|条|岁|毫克|mg|克)|研究表明|研究发现|实验表明|实验发现|数据显示|实验证明|研究证明|科学证明|唯一|必然|完全|永远|终极|最有效'
$medicalPattern = 'fMRI|脑区|杏仁核|前额叶|基底节|神经|多巴胺|血清素|皮质醇|BDNF|激素|心率|睡眠|复发率|EMDR|创伤|成瘾|治疗|临床|抑郁|焦虑|药物|受体'
$psychologyFiles = @("元认知.md", "情绪调节.md", "戒断.md", "自我精神分析.md")

$chapterFiles = Get-ChildItem -LiteralPath $projectPath -Filter "*.md" |
    Where-Object { Select-String -LiteralPath $_.FullName -Pattern '^source_role: chapter$' -Quiet } |
    Sort-Object { [int]((Select-String -LiteralPath $_.FullName -Pattern '^chapter:\s*(\d+)$').Matches.Groups[1].Value) }

$claims = [Collections.Generic.List[object]]::new()
foreach ($file in $chapterFiles) {
    $lineNumber = 0
    $inFrontmatter = $false
    foreach ($line in Get-Content -LiteralPath $file.FullName) {
        $lineNumber++
        if ($lineNumber -eq 1 -and $line -eq "---") {
            $inFrontmatter = $true
            continue
        }
        if ($inFrontmatter) {
            if ($line -eq "---") { $inFrontmatter = $false }
            continue
        }
        if ($line -match '^#|^>|参考书目' -or $line -notmatch $claimPattern) { continue }

        $domain = if ($file.Name -eq "健康.md" -or $line -match $medicalPattern) {
            "medical-health"
        } elseif ($psychologyFiles -contains $file.Name) {
            "psychology-behavior"
        } elseif ($file.Name -eq "统计.md") {
            "statistics"
        } elseif ($file.Name -in @("自学.md", "专注.md", "执行.md")) {
            "learning-behavior"
        } else {
            "general-methodology"
        }
        $risk = if ($domain -eq "medical-health") { "P0" } else { "P1" }
        $relativePath = $file.FullName.Substring($Root.TrimEnd('\').Length + 1).Replace('\', '/')
        $claims.Add([pscustomobject]@{
            claim_id = "MC-{0:D4}" -f ($claims.Count + 1)
            path = $relativePath
            line = $lineNumber
            claim_text = $line.Trim()
            domain = $domain
            risk = $risk
            source_type = "unverified-secondary-note"
            source_location = ""
            scope = "blocked-chapter-source"
            status = "open"
            decision = "block"
        })
    }
}

$outputDirectory = Split-Path -Parent $output
if (-not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}
$claims | Export-Csv -LiteralPath $output -NoTypeInformation -Encoding utf8NoBOM
Write-Output ("Claims=" + $claims.Count)
Write-Output ("P0=" + @($claims | Where-Object risk -eq "P0").Count)
Write-Output ("P1=" + @($claims | Where-Object risk -eq "P1").Count)
Write-Output ("Output=" + $output)
