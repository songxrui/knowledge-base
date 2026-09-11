# Content Unit Mapping Script
# Finds source tags in unit filenames and scans project files for matches

$unitDir = "D:\KnowledgeBase\内容结构化系统\02-内容单元库"
$projectDir = "D:\KnowledgeBase\01_Projects\content-creation"

if (-not (Test-Path $unitDir)) { Write-Host "Unit dir not found: $unitDir"; exit 1 }

$unitSources = @{}
Get-ChildItem $unitDir -Recurse -File -Filter "*.md" | ForEach-Object {
    $n = $_.BaseName
    $tag = ""
    if ($n -match '_(D\d+)') { $tag = $matches[1] }
    elseif ($n -match '_(C\d+-\d+)') { $tag = $matches[1] }
    elseif ($n -match '_(WLH-\d+)') { $tag = $matches[1] }
    if ($tag) { $unitSources[$tag] = $true }
}

$projectMatchCount = 0
if (Test-Path $projectDir) {
    Get-ChildItem $projectDir -Recurse -File -Filter "*.md" | ForEach-Object {
        try { $c = Get-Content $_.FullName -Raw -ErrorAction Stop } catch { return }
        foreach ($tag in $unitSources.Keys) {
            if ($c -match [regex]::Escape($tag)) { $projectMatchCount++; break }
        }
    }
}

Write-Host "Source tags found: $($unitSources.Keys.Count)"
Write-Host "Project files with matches: $projectMatchCount"
