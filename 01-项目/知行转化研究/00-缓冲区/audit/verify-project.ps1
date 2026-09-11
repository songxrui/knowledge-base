$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Results = [Collections.Generic.List[object]]::new()

function Add-Check {
    param([string]$Name, [bool]$Pass, [string]$Evidence)
    $Results.Add([pscustomobject]@{
        Check = $Name
        Result = if ($Pass) { "PASS" } else { "FAIL" }
        Evidence = $Evidence
    })
}

function Read-ProjectText {
    param([string]$RelativePath)
    return [IO.File]::ReadAllText((Join-Path $Root $RelativePath))
}

function Match-Count {
    param([string]$Text, [string]$Pattern)
    return [regex]::Matches($Text, $Pattern, [Text.RegularExpressions.RegexOptions]::Multiline).Count
}

function Invoke-NodeCheck {
    param([string]$WorkingDirectory, [string[]]$Arguments)
    Push-Location $WorkingDirectory
    try {
        $output = (& node @Arguments 2>&1 | Out-String).Trim()
        return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = $output }
    }
    finally {
        Pop-Location
    }
}

$requiredDirs = @(
    "research", "model", "content-universe", "flagship", "short-form",
    "podcast", "experiment", "diagnostic-tool", "product", "00-缓冲区/audit", "final-report"
)
$missingDirs = @($requiredDirs | Where-Object { -not (Test-Path -LiteralPath (Join-Path $Root $_) -PathType Container) })
Add-Check "Required directories" ($missingDirs.Count -eq 0) $(if ($missingDirs.Count) { $missingDirs -join ", " } else { "11/11 present" })

$evidence = Read-ProjectText "research/01-evidence-ledger.md"
$booksCases = Read-ProjectText "research/02-books-counterevidence-and-cases.md"
$claims = Read-ProjectText "research/04-claim-evidence-map.md"
$rCount = Match-Count $evidence '^### R\d{2}｜'
$bCount = Match-Count $booksCases '^### B\d{2}｜'
$cCount = Match-Count $booksCases '^### C\d{2}｜'
$counterCount = Match-Count $booksCases '^\d+\. \*\*'
Add-Check "Research inventory" ($rCount -ge 6 -and $bCount -ge 3 -and $cCount -ge 3 -and $counterCount -ge 2) "R=$rCount, B=$bCount, cases=$cCount, learning counter-sources=$counterCount"
$claimSections = @("已有证据支持的事实", "研究者的理论模型", "书籍作者与内部材料的观点", "本项目的原创推断")
$missingClaimSections = @($claimSections | Where-Object { $claims -notmatch [regex]::Escape($_) })
Add-Check "Fact/theory/view/inference separation" ($missingClaimSections.Count -eq 0) $(if ($missingClaimSections.Count) { $missingClaimSections -join ", " } else { "4/4 sections present" })

$initialModel = Read-ProjectText "model/01-initial-unnamed-model.md"
$neighbor = Read-ProjectText "00-缓冲区/02-neighbor-theory-audit.md"
$redTeam = Read-ProjectText "model/03-red-team-attack.md"
$finalModel = Read-ProjectText "model/04-final-model.md"
$causal = Read-ProjectText "model/05-causal-map-and-decision-router.md"
$neighborCount = Match-Count $neighbor '^## \d+｜'
$attackCount = Match-Count $redTeam '^### \d+｜'
$predictionCount = Match-Count $finalModel '^### P\d+｜'
$stateVariables = @('`K`', '`A`', '`P`', '`R`', '`E`', '`F`', '`Q`', '`H`')
$stateCount = @($stateVariables | Where-Object { $finalModel.Contains($_) }).Count
$gateCount = Match-Count $finalModel '^\d+\. \*\*(目标价值|资源与权限|风险与伦理|知识与能力|反馈有效性)\*\*'
$mermaidCount = Match-Count $causal '^```mermaid'
Add-Check "Model revision chain" ((Test-Path (Join-Path $Root "model/01-initial-unnamed-model.md")) -and $neighborCount -ge 8 -and $attackCount -ge 10) "neighbor audits=$neighborCount, steelman attacks=$attackCount"
Add-Check "Final model operability" ($predictionCount -ge 5 -and $stateCount -eq 8 -and $gateCount -eq 5 -and $mermaidCount -ge 1) "predictions=$predictionCount, states=$stateCount, gates=$gateCount, mermaid=$mermaidCount"
Add-Check "Final model boundaries" ($finalModel -match '## 适用边界' -and $finalModel -match '撤销独立理论身份' -and $finalModel -match '不是已获学界验证') "boundary and withdrawal clauses present"

$pillars = Read-ProjectText "content-universe/01-pillars-and-roadmap.md"
$topics = Read-ProjectText "content-universe/02-topic-bank.md"
$evolution = Read-ProjectText "content-universe/03-L1-to-L6-evolution.md"
$pillarCount = Match-Count $pillars '^\| P[1-5] '
$monthCount = Match-Count $pillars '^\| M[1-6] '
$topicCount = Match-Count $topics '^### T\d{2}｜'
$fieldNames = @("场景", "冲突", "推进判断", "差异", "媒介", "真实材料", "废话风险")
$fieldCounts = @{}
foreach ($field in $fieldNames) { $fieldCounts[$field] = Match-Count $topics ("^- " + [regex]::Escape($field) + "：") }
$badFields = @($fieldNames | Where-Object { $fieldCounts[$_] -ne 36 })
$categoryCount = Match-Count $topics '^## (认知颠覆|经历叙事|机制解释|行为实验|案例诊断|反方辩论|工具产品|失败复盘|长期跟踪)$'
$lCount = @((1..6) | Where-Object { $evolution -match ("L" + $_) }).Count
Add-Check "Six-month content universe" ($pillarCount -ge 4 -and $pillarCount -le 6 -and $monthCount -eq 6) "pillars=$pillarCount, months=$monthCount"
Add-Check "Topic bank fields" ($topicCount -ge 30 -and $categoryCount -eq 9 -and $badFields.Count -eq 0) "topics=$topicCount, categories=$categoryCount, bad fields=" + ($badFields -join ",")
Add-Check "L1-L6 evolution" ($lCount -eq 6) "levels=$lCount"

$articleV1 = Read-ProjectText "flagship/article-v1.md"
$article = Read-ProjectText "flagship/article.md"
$articleHan = [regex]::Matches($article, '[\p{IsCJKUnifiedIdeographs}]').Count
$bannedArticle = @("在这个信息爆炸的时代", "我们都知道", "真正的改变始于行动")
$bannedHits = @($bannedArticle | Where-Object { $article.Contains($_) })
Add-Check "Flagship length and language" ($articleHan -ge 4000 -and $articleHan -le 7000 -and $bannedHits.Count -eq 0) "Han=$articleHan, banned hits=$($bannedHits.Count)"
Add-Check "Flagship before/after" ($articleV1 -ne $article -and (Test-Path (Join-Path $Root "00-缓冲区/audit/03-anti-ai-surgery.md"))) "v1 preserved; surgery audit present"

$video = Read-ProjectText "short-form/90-second-video.md"
$carousel = Read-ProjectText "short-form/8-slide-carousel.md"
$podcast = Read-ProjectText "podcast/monologue-10-to-15-min.md"
$experiment = Read-ProjectText "experiment/7-day-evidence-interface-experiment.md"
$carouselPages = Match-Count $carousel '^## 第 [1-8] 页｜'
$podcastHan = [regex]::Matches($podcast, '[\p{IsCJKUnifiedIdeographs}]').Count
$podcastFast = [Math]::Round($podcastHan / 250, 1)
$podcastSlow = [Math]::Round($podcastHan / 220, 1)
$experimentDays = Match-Count $experiment '^### 第 [1-7] 天｜'
Add-Check "90-second video structure" ($video -match '0-3 秒' -and $video -match '画面与节奏' -and $video -match '今天') "hook, visual, pace and same-day test present"
Add-Check "Eight-slide carousel" ($carouselPages -eq 8) "pages=$carouselPages"
Add-Check "Podcast duration" ($podcastFast -ge 10 -and $podcastSlow -le 15) "Han=$podcastHan; estimated=$podcastFast-$podcastSlow min"
Add-Check "Seven-day experiment" ($experimentDays -eq 7 -and $experiment -match '每日上限：20 分钟' -and $experiment -match '阴性结果') "days=$experimentDays; daily cap and negative route present"

$diagnosticRequired = @("index.html", "styles.css", "logic.js", "app.js", "tests.mjs", "README.md")
$productRequired = @("product/01-shape-comparison-and-choice.md", "product/02-product-spec-and-validation.md", "product/03-系统产品说明.md", "product/05-个人工作台与苹果视觉重构-PRD.md", "experiment/14天个人双条件试用记录模板.md", "00-缓冲区/prototype/index.html", "00-缓冲区/prototype/styles.css", "00-缓冲区/prototype/logic.js", "00-缓冲区/prototype/ui-state.js", "00-缓冲区/prototype/app.js", "00-缓冲区/prototype/tests.mjs", "00-缓冲区/prototype/README.md")
$missingDiagnostic = @($diagnosticRequired | Where-Object { -not (Test-Path (Join-Path $Root ("diagnostic-tool/" + $_))) })
$missingProduct = @($productRequired | Where-Object { -not (Test-Path (Join-Path $Root $_)) })
$shapeDoc = Read-ProjectText "product/01-shape-comparison-and-choice.md"
$shapeCount = Match-Count $shapeDoc '^\| (纸质或便携式文档|电子表格|对话式人工智能|社群或真人|本地单页)'
Add-Check "Diagnostic artifact" ($missingDiagnostic.Count -eq 0) "missing=" + ($missingDiagnostic -join ",")
Add-Check "Product artifact and comparison" ($missingProduct.Count -eq 0 -and $shapeCount -ge 4) "missing=" + ($missingProduct -join ",") + "; shapes=$shapeCount"

$auditRequired = @("01-citation-audit.md", "02-originality-audit.md", "03-anti-ai-surgery.md", "21-个人工作台0.2-预检与基线.md", "prototype-v0.1-baseline.zip", "cross-app-integration.test.mjs", "browser-smoke.mjs", "prototype-smoke-v2.mjs")
$missingAudits = @($auditRequired | Where-Object { -not (Test-Path (Join-Path $Root ("00-缓冲区/audit/" + $_))) })
Add-Check "Independent audits" ($missingAudits.Count -eq 0) "missing=" + ($missingAudits -join ",")

$readmePath = Join-Path $Root "README.md"
$reportPath = Join-Path $Root "final-report/FINAL-REPORT.md"
$readmeReady = Test-Path -LiteralPath $readmePath
$reportReady = Test-Path -LiteralPath $reportPath
Add-Check "Unified README" $readmeReady $(if ($readmeReady) { "present" } else { "missing" })
if ($reportReady) {
    $report = [IO.File]::ReadAllText($reportPath)
    $reportHeadings = Match-Count $report '^## '
    $reportFields = @("成果入口", "最重要的新理论", "相比初版发生的 3 个关键修正", "实际创建并验证的成果", "理论最脆弱的地方", "只能保留一个文件")
    $missingReportFields = @($reportFields | Where-Object { $report -notmatch [regex]::Escape($_) })
    Add-Check "Restricted final report" ($reportHeadings -eq 6 -and $missingReportFields.Count -eq 0) "headings=$reportHeadings; missing=" + ($missingReportFields -join ",")
} else {
    Add-Check "Restricted final report" $false "missing"
}

$linkErrors = [Collections.Generic.List[string]]::new()
Get-ChildItem -LiteralPath $Root -Recurse -Filter *.md | ForEach-Object {
    $source = $_
    $text = [IO.File]::ReadAllText($source.FullName)
    [regex]::Matches($text, '\[[^\]]+\]\(([^)]+)\)') | ForEach-Object {
        $target = $_.Groups[1].Value.Trim()
        if ($target -match '^(https?://|mailto:|#)') { return }
        $target = ($target -split '#', 2)[0]
        if (-not $target) { return }
        $candidate = [IO.Path]::GetFullPath((Join-Path $source.DirectoryName $target))
        if (-not (Test-Path -LiteralPath $candidate)) {
            $linkErrors.Add(($source.FullName.Substring($Root.Length + 1) + " -> " + $target))
        }
    }
}
Add-Check "Local Markdown links" ($linkErrors.Count -eq 0) $(if ($linkErrors.Count) { ($linkErrors | Select-Object -First 8) -join "; " } else { "all resolve" })

$guardTokens = @(
    ("产出" + "Skill链"), ("取材" + "单元"), ("SCORE" + ":"),
    ("来源" + "::"), ("自测" + "::"), ("归并自" + "W"), ("卡" + "号"),
    ("TO" + "DO"), ("FIX" + "ME"), ("占位" + "符")
)
$guardHits = [Collections.Generic.List[string]]::new()
Get-ChildItem -LiteralPath $Root -Recurse -File | Where-Object {
    $_.Extension -in @(".md", ".js", ".mjs", ".html", ".css") -and
    $_.Name -notin @("verify-project.ps1", "05-content-guard-and-diff-review.md")
} | ForEach-Object {
    $text = [IO.File]::ReadAllText($_.FullName)
    foreach ($token in $guardTokens) {
        if ($text.Contains($token)) { $guardHits.Add($_.FullName.Substring($Root.Length + 1) + ":" + $token) }
    }
}
Add-Check "Content-guard keyword scan" ($guardHits.Count -eq 0) $(if ($guardHits.Count) { ($guardHits | Select-Object -First 10) -join "; " } else { "0 hits" })

$diagnosticTest = Invoke-NodeCheck (Join-Path $Root "diagnostic-tool") @("--test", "tests.mjs")
$productTest = Invoke-NodeCheck (Join-Path $Root "00-缓冲区/prototype") @("--test", "tests.mjs")
$integrationTest = Invoke-NodeCheck (Join-Path $Root "00-缓冲区/audit") @("--test", "cross-app-integration.test.mjs")
Add-Check "Diagnostic rules" ($diagnosticTest.ExitCode -eq 0 -and $diagnosticTest.Output -match '30/30 tests passed') "exit=$($diagnosticTest.ExitCode)"
Add-Check "Product rules" ($productTest.ExitCode -eq 0 -and $productTest.Output -match '# pass 29') "exit=$($productTest.ExitCode)"
Add-Check "Cross-app integration" ($integrationTest.ExitCode -eq 0 -and $integrationTest.Output -match '# pass 2') "exit=$($integrationTest.ExitCode)"

$browserTest = Invoke-NodeCheck (Join-Path $Root "00-缓冲区/audit") @("prototype-smoke-v2.mjs")
$browserPass = $browserTest.ExitCode -eq 0 -and $browserTest.Output -match '"name": "history-1440"' -and $browserTest.Output -match '"type": "dark"' -and $browserTest.Output -match '"name": "recovery"'
Add-Check "Product v2 browser matrix" $browserPass "exit=$($browserTest.ExitCode); file-protocol CDP"

$screenshotNames = @("diagnostic-result-desktop.png", "diagnostic-result-mobile.png", "product-result-desktop.png", "product-result-mobile.png", "product-workflow-desktop.png", "product-workflow-mobile.png", "v2-screenshots/goal-320.png", "v2-screenshots/history-390.png", "v2-screenshots/history-735.png", "v2-screenshots/history-1024.png", "v2-screenshots/history-1440.png", "v2-screenshots/history-dark-390.png", "v2-screenshots/recovery-390.png")
$badScreenshots = @($screenshotNames | Where-Object {
    $p = Join-Path $Root ("00-缓冲区/audit/" + $_)
    -not (Test-Path $p) -or (Get-Item $p).Length -lt 10000
})
Add-Check "Browser screenshots" ($badScreenshots.Count -eq 0) "bad=" + ($badScreenshots -join ",")

$Results | Format-Table -Wrap -AutoSize
$failed = @($Results | Where-Object { $_.Result -eq "FAIL" })
Write-Output ""
Write-Output ("SUMMARY: {0} passed, {1} failed" -f ($Results.Count - $failed.Count), $failed.Count)
if ($failed.Count -gt 0) { exit 1 }
