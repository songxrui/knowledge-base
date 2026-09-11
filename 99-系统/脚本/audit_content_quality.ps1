param(
    [string]$Root = "D:\KnowledgeBase",
    [string]$ReportPath = "99-系统\元数据\inventory\CONTENT_QUALITY_GATE_LATEST.md",
    [switch]$BaselineReplay
)

$ErrorActionPreference = "Stop"
$rootPath = [IO.Path]::GetFullPath($Root).TrimEnd('\')
$report = if ([IO.Path]::IsPathRooted($ReportPath)) { $ReportPath } else { Join-Path $rootPath $ReportPath }
$csvReport = [IO.Path]::ChangeExtension($report, ".csv")
$textExtensions = @(".md", ".txt", ".csv", ".json", ".toml", ".yaml", ".yml", ".py", ".js", ".mjs", ".ts", ".ps1")
$excludedPrefixes = @(
    ".git/", ".obsidian/", ".dbs/", ".agents/", ".codex/", ".reasonix/",
    "90-归档/", "99-系统/vendor/", "99-系统/集成/notion-archive/", "99-系统/集成/reasonix/",
    "08-媒体与产品/媒体/flagship/book-v7/", "03-资源/创作者素材/"
)
$findings = [Collections.Generic.List[object]]::new()

function Get-RelativePath([string]$path) {
    return $path.Substring($rootPath.Length + 1).Replace('\', '/')
}

function Test-Excluded([string]$relativePath) {
    if ($relativePath -match '(?i)(?:^|/)(?:node_modules|dist|build|coverage|test-results|playwright-report|blob-report|\.cache|\.next|target|00-缓冲区)(?:/|$)') { return $true }
    foreach ($prefix in $excludedPrefixes) {
        if ($relativePath.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) { return $true }
    }
    return $false
}

function Add-Finding([string]$severity, [string]$rule, [string]$path, [int]$line, [string]$message, [string]$evidence) {
    $cleanEvidence = ($evidence -replace '\s+', ' ').Trim()
    $findings.Add([pscustomobject]@{
        severity = $severity
        rule = $rule
        path = $path
        line = $line
        message = $message
        evidence = $cleanEvidence
    })
}

function Get-LineNumber([string]$content, [int]$index) {
    if ($index -le 0) { return 1 }
    return ([regex]::Matches($content.Substring(0, $index), "\n")).Count + 1
}

$files = @(Get-ChildItem -LiteralPath $rootPath -Recurse -File | Where-Object {
    $relative = Get-RelativePath $_.FullName
    $textExtensions -contains $_.Extension.ToLowerInvariant() -and
        $relative -notmatch '^99-系统/元数据/inventory/CONTENT_QUALITY_GATE_LATEST\.(?:md|csv)$' -and
        -not (Test-Excluded $relative)
})

$markdownFiles = @($files | Where-Object Extension -eq ".md")
$markdownStemIndex = @{}
foreach ($file in $markdownFiles) {
    $stem = [IO.Path]::GetFileNameWithoutExtension($file.Name).ToLowerInvariant()
    if (-not $markdownStemIndex.ContainsKey($stem)) { $markdownStemIndex[$stem] = [Collections.Generic.List[string]]::new() }
    $markdownStemIndex[$stem].Add($file.FullName)
}

$credentialPatterns = @(
    '(?i)gh[pousr]_[A-Za-z0-9]{20,}',
    '(?i)sk-(?:proj-|live-)?[A-Za-z0-9]{20,}',
    '(?i)xox[baprs]-[A-Za-z0-9-]{20,}',
    '(?i)AKIA[0-9A-Z]{16}',
    '(?i)(?:app_secret|api_key|access_token|bearer_token|private_key)\s*[:=]\s*["''](?!<|YOUR_|REDACTED|\$env:|os\.environ)[A-Za-z0-9_./+\-=]{16,}["'']'
)
$oldPathPattern = '(?i)(?:^|[\s`"''(])(?:01-内容生产/|01-知识项目/|03-资源库/|04_Archive/|_system/|media/flagship/)'
$preciseNumberPattern = '(?i)\d+(?:\.\d+)?\s*(?:%|％|倍|元|万元|用户)|(?:收入|留存|退款|收益|成功率)[^。；\r\n]{0,20}\d+(?:\.\d+)?'
$absolutePattern = '物理定律级可靠|神经地理必然|科学证明|实验证明|唯一正确|百分之百|完全有效|必然成功|永远有效|最有效'
$allowedCaseLabels = '作者真实经历|可追溯公开案例|合成案例|模拟案例|寓言|案例身份|case_status'
$paragraphRows = [Collections.Generic.List[object]]::new()
$canonicalRows = [Collections.Generic.List[object]]::new()

foreach ($file in $files) {
    $relative = Get-RelativePath $file.FullName
    $content = [string](Get-Content -LiteralPath $file.FullName -Raw)
    if ($null -eq $content) { $content = "" }
    $lines = @($content -split "\r?\n")

    $controlScanContent = $content
    $isCapturedEvidenceLog = $relative -match '(?i)(?:^|/)docs/evidence/.+/(?:test-output|failure-case-output)\.txt$'
    if ($isCapturedEvidenceLog) {
        $controlScanContent = [regex]::Replace($controlScanContent, '\x1B\[[0-?]*[ -/]*[@-~]', '')
    }
    if ($controlScanContent.Contains([char]0)) { Add-Finding "P0" "nul-byte" $relative 1 "文件包含 NUL" "NUL" }
    $control = [regex]::Match($controlScanContent, '[\x01-\x08\x0B\x0C\x0E-\x1F]')
    if ($control.Success) { Add-Finding "P0" "control-character" $relative (Get-LineNumber $content $control.Index) "文件包含非法控制字符" ([int][char]$control.Value) }
    foreach ($pattern in $credentialPatterns) {
        foreach ($match in [regex]::Matches($content, $pattern)) {
            Add-Finding "P0" "plaintext-credential" $relative (Get-LineNumber $content $match.Index) "疑似有效明文凭据" $match.Value
        }
    }

    if ($file.Extension -eq ".md") {
        $frontmatter = [regex]::Match($content, '\A---\r?\n(?<body>.*?)\r?\n---', [Text.RegularExpressions.RegexOptions]::Singleline)
        if ($frontmatter.Success -and $frontmatter.Groups['body'].Value -match '(?m)^canonical:\s*true\s*$') {
            $idMatch = [regex]::Match($frontmatter.Groups['body'].Value, '(?m)^id:\s*["'']?(?<id>[^\r\n"'']+)')
            if ($idMatch.Success) {
                $canonicalRows.Add([pscustomobject]@{ Id = $idMatch.Groups['id'].Value.Trim().ToLowerInvariant(); Path = $relative })
            } else {
                Add-Finding "P1" "canonical-missing-id" $relative 1 "canonical 文档缺少稳定 id，无法参与冲突检查" "canonical=true"
            }
        }

        foreach ($match in [regex]::Matches($content, '(?<!\!)\[[^\]]+\]\((?<target>[^)]+)\)')) {
            $target = $match.Groups['target'].Value.Trim().Trim('<', '>')
            if ($target -match '^\{.*\}$|^文件名$|^\.\.\.$') { continue }
            if ($target -match '^(?:https?:|mailto:|#|data:)' -or -not $target) { continue }
            $target = ($target -split '#', 2)[0]
            try { $target = [uri]::UnescapeDataString($target) } catch {}
            $resolved = if ($target -match '^(?:00-收件箱/|01-项目/|03-资源/|04-知识/|05-内容生产/|08-媒体与产品/|90-归档/|99-系统/|HOME\.md$|KNOWLEDGE_MAP\.md$|SOURCE_OF_TRUTH\.md$|_MOC_)') {
                [IO.Path]::GetFullPath((Join-Path $rootPath $target))
            } else {
                [IO.Path]::GetFullPath((Join-Path $file.DirectoryName $target))
            }
            if (-not (Test-Path -LiteralPath $resolved)) {
                Add-Finding "P1" "broken-markdown-link" $relative (Get-LineNumber $content $match.Index) "本地 Markdown 链接无法解析" $match.Groups['target'].Value
            }
        }
        foreach ($match in [regex]::Matches($content, '\[\[(?<target>[^\]|#]+)(?:#[^\]|]+)?(?:\|[^\]]+)?\]\]')) {
            $target = $match.Groups['target'].Value.Trim(); if ($target -match '^\{.*\}$|^文件名$|^\.\.\.$') { continue }
            $candidateBase = if ($target -match '^(?:00-收件箱/|01-项目/|03-资源/|04-知识/|05-内容生产/|08-媒体与产品/|90-归档/|99-系统/|HOME$|KNOWLEDGE_MAP$|SOURCE_OF_TRUTH$|_MOC_)') { $rootPath } else { $file.DirectoryName }
            $candidatePath = Join-Path $candidateBase $target.Replace('/', '\')
            $candidateExists = (Test-Path -LiteralPath $candidatePath) -or (Test-Path -LiteralPath ($candidatePath + ".md"))
            $stem = [IO.Path]::GetFileNameWithoutExtension($target).ToLowerInvariant()
            if (-not $candidateExists -and (-not $markdownStemIndex.ContainsKey($stem) -or $markdownStemIndex[$stem].Count -eq 0)) {
                Add-Finding "P1" "broken-wikilink" $relative (Get-LineNumber $content $match.Index) "Wiki 链接无法解析" $target
            }
        }

        $isGenerated = $frontmatter.Success -and $frontmatter.Groups['body'].Value -match '(?m)^generated:\s*true\s*$'
        $isBlockedProductHypothesis = $frontmatter.Success -and $frontmatter.Groups['body'].Value -match '(?m)^status:\s*blocked\s*$' -and $frontmatter.Groups['body'].Value -match '(?m)^canonical:\s*false\s*$' -and $frontmatter.Groups['body'].Value -match '(?m)^evidence_level:\s*unverified-product-hypothesis\s*$'
        $isProductionDesignSpec = $relative -match '^08-媒体与产品/视频/' -and $frontmatter.Success -and $frontmatter.Groups['body'].Value -match '(?m)^content_role:\s*production-design-spec\s*$' -and $frontmatter.Groups['body'].Value -match '(?m)^number_policy:\s*design-parameter\s*$'
        $isIntentionalDuplicateEvidence = $frontmatter.Success -and $frontmatter.Groups['body'].Value -match '(?m)^status:\s*retained-before-rewrite-evidence\s*$' -and $frontmatter.Groups['body'].Value -match '(?m)^canonical:\s*false\s*$' -and $frontmatter.Groups['body'].Value -match '(?m)^duplicate_policy:\s*intentional-before-after\s*$' -and $frontmatter.Groups['body'].Value -match '(?m)^superseded_by:\s*\S+\s*$'
        if ($isBlockedProductHypothesis) {
            $statusMatch = [regex]::Match($content, '(?m)^status:\s*blocked\s*$')
            $statusLine = if ($statusMatch.Success) { Get-LineNumber $content $statusMatch.Index } else { 1 }
            Add-Finding "P1" "blocked-product-hypothesis" $relative $statusLine "未核验产品假设已在文档级阻断" "status: blocked"
            if ($relative -match '^(?:05-内容生产/运营与发布/已发布/|08-媒体与产品/媒体/flagship/)') {
                Add-Finding "P0" "blocked-content-in-published-scope" $relative 1 "阻断文档进入发布或旗舰路径" $relative
            }
        }
        if (-not $isGenerated -and -not $isIntentionalDuplicateEvidence) {
            foreach ($paragraph in [regex]::Split($content, '(?:\r?\n){2,}')) {
                $normalized = ($paragraph -replace '\s+', ' ').Trim()
                if ($normalized.Length -ge 180 -and $normalized -notmatch '^---|^\|') {
                    $paragraphRows.Add([pscustomobject]@{ Path = $relative; Text = $normalized })
                }
            }
        }

        $claimScope = $relative -match '^(?:04-知识/|05-内容生产/|08-媒体与产品/|01-项目/meta-abilities/|01-项目/宇宙底层机制-守恒/)'
        if ($isGenerated -or -not $claimScope) { continue }
        for ($index = 0; $index -lt $lines.Count; $index++) {
            $line = $lines[$index]
            if (-not $line.Trim() -or $line -match '^---$|^\|[-: ]+\|$') { continue }
            if ($line -match $oldPathPattern) { Add-Finding "P1" "legacy-path" $relative ($index + 1) "活跃文档引用旧目录" $line }
            $isMetadataOrIndexLine = $line -match '^\s*(?:source|superseded_by):' -or $line -match '^\s*[-*]\s+\[\[[^\]]+\]\]\s*$'
            if (-not $isMetadataOrIndexLine) {
                foreach ($absoluteMatch in [regex]::Matches($line, $absolutePattern)) {
                    $before = $line.Substring(0, $absoluteMatch.Index)
                    $after = $line.Substring($absoluteMatch.Index + $absoluteMatch.Length)
                    $isQualifiedAbsolute = $line -match '错误示例|禁止写' -or $before -match '(?:没有被|未被|并未|不是|不再|不能|不得|不把|不将|不可|并非|无法|不等于|不代表)[^。；！？]{0,24}$' -or $after -match '^\s*(?:并不存在|不存在|不成立|并非|不适用)'
                    if (-not $isQualifiedAbsolute) {
                        Add-Finding "P1" "absolute-claim" $relative ($index + 1) "绝对或不可验证表述" $line
                        break
                    }
                }
            }
            $numericScanLine = $line -replace '^\s*#{1,6}\s+\d+(?:\.\d+)*\s*', ''
            $numericScanLine = $numericScanLine -replace '(?i)\b(?:L|CH)\d+\s*元(?=\p{L})', ''
            if (-not $isBlockedProductHypothesis -and -not $isProductionDesignSpec -and $numericScanLine -match $preciseNumberPattern) {
                $paragraphStart = $index
                while ($paragraphStart -gt 0 -and $lines[$paragraphStart - 1].Trim()) { $paragraphStart-- }
                $paragraphEnd = $index
                while ($paragraphEnd -lt $lines.Count - 1 -and $lines[$paragraphEnd + 1].Trim()) { $paragraphEnd++ }
                $paragraphContext = ($lines[$paragraphStart..$paragraphEnd] -join ' ')
                if ($paragraphContext -notmatch '来源|source|claim_status|experiment-parameter|product-hypothesis|候选|proposed|待核实|blocked|示例|版本|更新|日期|路径|SHA-256|http|第\d+章') {
                    Add-Finding "P1" "unsourced-precise-number" $relative ($index + 1) "精确数字缺少同段来源或身份标记" $line
                }
            }
            if ($relative -notmatch '/(?:00-规则与索引|04-模板)/' -and $line -match '^#{1,6}.*案例' -and $line -notmatch '规则|模板|字段|契约|单元|案例库|用户案例|案例与承诺' -and $line -notmatch $allowedCaseLabels) {
                $contextStart = [Math]::Max(0, $index - 2)
                $contextEnd = [Math]::Min($lines.Count - 1, $index + 2)
                $context = ($lines[$contextStart..$contextEnd] -join ' ')
                if ($context -notmatch $allowedCaseLabels) { Add-Finding "P1" "unmarked-case" $relative ($index + 1) "案例或场景未标记身份" $line }
            }
        }
    }
}

foreach ($group in $canonicalRows | Group-Object Id | Where-Object Count -gt 1) {
    foreach ($row in $group.Group) { Add-Finding "P0" "canonical-id-conflict" $row.Path 1 ("canonical id 重复: " + $group.Name) ($group.Group.Path -join '; ') }
}
foreach ($group in $paragraphRows | Group-Object Text | Where-Object { ($_.Group.Path | Sort-Object -Unique).Count -gt 1 }) {
    $paths = @($group.Group.Path | Sort-Object -Unique)
    foreach ($path in $paths) { Add-Finding "P1" "duplicate-long-paragraph" $path 1 "跨文件重复长段落" ($paths -join '; ') }
}

$sorted = @($findings | Sort-Object @{Expression={switch($_.severity){'P0'{0}'P1'{1}default{2}}}}, rule, path, line, evidence)
$reportDirectory = Split-Path -Parent $report
if (-not (Test-Path -LiteralPath $reportDirectory)) { New-Item -ItemType Directory -Path $reportDirectory -Force | Out-Null }
$sorted | Export-Csv -LiteralPath $csvReport -NoTypeInformation -Encoding utf8NoBOM
$counts = @{
    P0 = @($sorted | Where-Object severity -eq "P0").Count
    P1 = @($sorted | Where-Object severity -eq "P1").Count
    P2 = @($sorted | Where-Object severity -eq "P2").Count
}
$reportLines = [Collections.Generic.List[string]]::new()
$reportLines.Add("# Content Quality Gate Report")
$reportLines.Add("")
$reportLines.Add("- Generated at: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"))
$reportLines.Add("- Root: ``" + $rootPath.Replace('\', '/') + "``")
$reportLines.Add("- Files scanned: " + $files.Count)
$reportLines.Add("- P0: " + $counts.P0)
$reportLines.Add("- P1: " + $counts.P1)
$reportLines.Add("- P2: " + $counts.P2)
$reportLines.Add("")
if ($BaselineReplay) {
    $oldMap = Join-Path $rootPath "90-归档\历史版本\content-quality-p0-20260718\05-内容生产\内容体系\05-主题地图\综合_broken-20260718.md"
    $oldBrokenLinks = -1
    if (Test-Path -LiteralPath $oldMap) {
        $oldMapContent = [string](Get-Content -Raw -LiteralPath $oldMap)
        $oldBrokenLinks = 0
        foreach ($match in [regex]::Matches($oldMapContent, '\[\[(?<target>[^\]|#]+)(?:#[^\]|]+)?(?:\|[^\]]+)?\]\]')) {
            $target = $match.Groups['target'].Value.Trim()
            $candidatePath = Join-Path $rootPath $target.Replace('/', '\')
            $candidateExists = (Test-Path -LiteralPath $candidatePath) -or (Test-Path -LiteralPath ($candidatePath + ".md"))
            $stem = [IO.Path]::GetFileNameWithoutExtension($target).ToLowerInvariant()
            if (-not $candidateExists -and (-not $markdownStemIndex.ContainsKey($stem) -or $markdownStemIndex[$stem].Count -eq 0)) { $oldBrokenLinks++ }
        }
    }
    $metaLedger = Join-Path $rootPath "99-系统\元数据\inventory\META_ABILITIES_CLAIM_LEDGER_2026-07-17.csv"
    $metaClaims = -1
    if (Test-Path -LiteralPath $metaLedger) {
        $metaRows = @(Import-Csv -LiteralPath $metaLedger)
        $metaIds = @($metaRows.claim_id | Where-Object { $_ })
        $metaLedgerValid = $metaRows.Count -gt 0 -and $metaIds.Count -eq $metaRows.Count -and @($metaIds | Sort-Object -Unique).Count -eq $metaRows.Count -and @($metaRows | Where-Object { -not $_.path -or -not $_.claim_text -or -not $_.decision }).Count -eq 0
        if ($metaLedgerValid) { $metaClaims = $metaRows.Count }
    }
    $credentialRecord = Join-Path $rootPath "99-系统\元数据\inventory\CREDENTIAL_ROTATION_RECORD_2026-07-17.md"
    $historyCommitHits = "unknown"
    $historyPathHits = "unknown"
    if (Test-Path -LiteralPath $credentialRecord) {
        $historyRecordMatch = [regex]::Match((Get-Content -Raw -LiteralPath $credentialRecord), 'Git 历史正则定位命中 (?<commits>\d+) 个提交、(?<paths>\d+) 个文件')
        if ($historyRecordMatch.Success) {
            $historyCommitHits = $historyRecordMatch.Groups['commits'].Value
            $historyPathHits = $historyRecordMatch.Groups['paths'].Value
        }
    }
    $reportLines.Add("## Historical Baseline Evidence Check")
    $reportLines.Add("")
    $reportLines.Add("- Archived broken theme-map links independently resolved as missing: " + $oldBrokenLinks)
    $reportLines.Add("- Frozen meta-abilities claim-ledger rows with valid unique ids and required fields: " + $metaClaims)
    $reportLines.Add("- Credential-history locations recorded (not independently rescanned): " + $historyCommitHits + " commits / " + $historyPathHits + " paths")
    $reportLines.Add("- Current canonical documents indexed by stable id: " + $canonicalRows.Count)
    $reportLines.Add("")
}$reportLines.Add("## Findings")
$reportLines.Add("")
if ($sorted.Count -eq 0) {
    $reportLines.Add("No findings.")
} else {
    $reportLines.Add("| Severity | Rule | Path | Line | Message |")
    $reportLines.Add("|---|---|---|---:|---|")
    foreach ($finding in $sorted) {
        $message = ($finding.message + ": " + $finding.evidence).Replace('|', '\|')
        $reportLines.Add("| " + $finding.severity + " | " + $finding.rule + " | ``" + $finding.path + "`` | " + $finding.line + " | " + $message + " |")
    }
}
[IO.File]::WriteAllLines($report, $reportLines, [Text.UTF8Encoding]::new($false))
Write-Output ("Files=" + $files.Count)
Write-Output ("P0=" + $counts.P0)
Write-Output ("P1=" + $counts.P1)
Write-Output ("P2=" + $counts.P2)
Write-Output ("Report=" + $report)
if ($counts.P0 -gt 0) { exit 1 }

