param([string]$UnitDir = "内容结构化系统\02-内容单元库", [string]$ProjectDir = "01_Projects\content-creation")

# Phase 1: Extract all unit source tags from filenames
$unitSources = @{}
Get-ChildItem $UnitDir -Recurse -File -Filter "*.md" | ForEach-Object {
    $name = $_.BaseName
    $sourceTag = ""
    if ($name -match '_(D\d+)') { $sourceTag = $matches[1] }
    elseif ($name -match '_(C\d+-\d+)') { $sourceTag = $matches[1] }
    elseif ($name -match '_(WLH-\d+)') { $sourceTag = $matches[1] }
    if ($sourceTag) {
        if (-not $unitSources.ContainsKey($sourceTag)) { $unitSources[$sourceTag] = @{} }
        $unitSources[$sourceTag][$_.FullName.Replace("D:\KnowledgeBase\","")] = $true
    }
}
Write-Host "Found $($unitSources.Keys.Count) unique source tags"

# Phase 2: Scan 01_Projects content for source tag references
$projectRefs = @{}
Get-ChildItem $ProjectDir -Recurse -File -Filter "*.md" | ForEach-Object {
    try {
        $content = Get-Content $_.FullName -Raw -ErrorAction Stop
    } catch { return }
    $found = @()
    foreach ($tag in $unitSources.Keys) {
        if ($content -match "\b$tag\b") { $found += $tag }
    }
    if ($found.Count -gt 0) {
        $projectRefs[$_.FullName.Replace("D:\KnowledgeBase\","")] = $found
    }
}
Write-Host "Found $($projectRefs.Count) project files with source tag references"

# Phase 3: Generate markdown report (no Chinese in heredoc to avoid encoding issues)
$lines = @()
$lines += "# Content Unit to 01_Projects Mapping Report"
$lines += ""
$lines += "> Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
$lines += "> Method: Unit filename source tags matched against project file content"
$lines += ""
$lines += "## Overview"
$lines += ""
$totalUnits = ($unitSources.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
$lines += "- Content units with source tags: $totalUnits"
$lines += "- Unique source tags: $($unitSources.Keys.Count)"
$lines += "- 01_Projects files with matches: $($projectRefs.Count)"
$lines += "- 01_Projects files without matches: $((Get-ChildItem $ProjectDir -Recurse -File -Filter '*.md' | Measure-Object).Count - $projectRefs.Count)"
$lines += ""
$lines += "## Source Tag Distribution"
$lines += ""
$lines += "| Tag Type | Count | Examples |"
$lines += "|----------|-------|---------|"
$dTags = $unitSources.Keys | Where-Object { $_ -match '^D\d+' } | Measure-Object | Select-Object -ExpandProperty Count
$cTags = $unitSources.Keys | Where-Object { $_ -match '^C\d+-\d+' } | Measure-Object | Select-Object -ExpandProperty Count
$wTags = $unitSources.Keys | Where-Object { $_ -match '^WLH-\d+' } | Measure-Object | Select-Object -ExpandProperty Count
$lines += "| D-series (D01..Dn) | $dTags | $($unitSources.Keys | Where-Object { $_ -match '^D\d+' } | Select-Object -First 3 -Join ', ') |"
$lines += "| C-series (C1-1..Cn) | $cTags | $($unitSources.Keys | Where-Object { $_ -match '^C\d+-\d+' } | Select-Object -First 3 -Join ', ') |"
$lines += "| WLH-series | $wTags | $($unitSources.Keys | Where-Object { $_ -match '^WLH-\d+' } | Select-Object -First 3 -Join ', ') |"
$lines += ""
$lines += "## Project File -> Source Tags"
$lines += ""
$lines += "| Project File | Source Tags | Unit Count |"
$lines += "|-------------|-------------|------------|"
$projectRefs.Keys | Sort-Object | ForEach-Object {
    $path = $_
    $tags = $projectRefs[$_] | Sort-Object -Unique
    $unitCount = 0
    foreach ($tag in $tags) { $unitCount += $unitSources[$tag].Count }
    $tagStr = $tags -join ', '
    $lines += "| $path | $tagStr | $unitCount |"
}

# Write output
$output = "_content-system\UNIT_PROJECT_MAP.md"
$lines -join "`r`n" | Set-Content -Path $output -Encoding UTF8
Write-Host "Report written to $output"

# Phase 4: Show summary
Write-Host ""
Write-Host "=== Summary ==="
Write-Host "Total content units with tags: $totalUnits"
Write-Host "01_Projects matched: $($projectRefs.Count) files"
Write-Host "D-series tags: $dTags"
Write-Host "C-series tags: $cTags"
Write-Host "WLH-series tags: $wTags"
