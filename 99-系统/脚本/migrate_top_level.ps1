$ErrorActionPreference = 'Stop'

$root = if ($PSScriptRoot) {
    (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
} else {
    (Get-Location).Path
}
Set-Location $root

if ((Test-Path -LiteralPath (Join-Path $root '05-内容生产')) -and -not (Test-Path -LiteralPath (Join-Path $root '01-内容生产'))) {
    Write-Output 'Top-level migration is already complete.'
    exit 0
}

$moves = [ordered]@{
    '01-知识项目' = '01-项目'
    '03-资源库' = '03-资源'
    'SOURCES' = '03-资源/来源台账'
    '04-方法论沉淀' = '04-知识/方法论'
    'cards' = '04-知识/卡片'
    'zettel' = '04-知识/原子笔记'
    '01-内容生产' = '05-内容生产'
    'topic-management' = '05-内容生产/选题管理-旧'
    '05-数据统计' = '06-运营数据'
    'media' = '08-媒体与产品/媒体'
    'videos' = '08-媒体与产品/视频'
    'assets' = '08-媒体与产品/素材'
    '04_Archive' = '90-归档/历史版本'
    'changes' = '90-归档/变更记录'
    '.dashboard-backup' = '90-归档/仪表盘备份'
    '_content-system' = '90-归档/旧内容系统入口'
    '_logs' = '99-系统/日志'
    '_system' = '99-系统/集成'
    '_superpowers-zh' = '99-系统/vendor/superpowers-zh'
    '_alchemist' = '99-系统/alchemist'
    'scripts' = '99-系统/脚本'
    '_meta' = '99-系统/元数据'
}

foreach ($entry in $moves.GetEnumerator()) {
    $source = Join-Path $root $entry.Key
    $destination = Join-Path $root $entry.Value
    if (-not (Test-Path -LiteralPath $source)) { continue }
    $parent = Split-Path -Parent $destination
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    if (Test-Path -LiteralPath $destination) {
        & robocopy $source $destination /E /MOVE /R:2 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
        if ($LASTEXITCODE -ge 8) {
            throw "Failed to merge source into destination: $source"
        }
        $remainingFiles = (Get-ChildItem -LiteralPath $source -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
        if ($remainingFiles -gt 0) {
            throw "Source still contains $remainingFiles files after merge: $source"
        }
        Remove-Item -LiteralPath $source -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Move-Item -LiteralPath $source -Destination $destination
    }
}

New-Item -ItemType Directory -Path (Join-Path $root '02-领域') -Force | Out-Null

$replacements = [ordered]@{
    '01-知识项目' = '01-项目'
    '03-资源库' = '03-资源'
    'SOURCES/' = '03-资源/来源台账/'
    '04-方法论沉淀' = '04-知识/方法论'
    'cards/' = '04-知识/卡片/'
    'zettel/' = '04-知识/原子笔记/'
    '01-内容生产' = '05-内容生产'
    'topic-management/' = '05-内容生产/选题管理-旧/'
    '05-数据统计' = '06-运营数据'
    'media/' = '08-媒体与产品/媒体/'
    'videos/' = '08-媒体与产品/视频/'
    'assets/' = '08-媒体与产品/素材/'
    '04_Archive' = '90-归档/历史版本'
    'changes/' = '90-归档/变更记录/'
    '_content-system/' = '90-归档/旧内容系统入口/'
    '_logs/' = '99-系统/日志/'
    '_system/' = '99-系统/集成/'
    '_superpowers-zh/' = '99-系统/vendor/superpowers-zh/'
    '_alchemist/' = '99-系统/alchemist/'
    'scripts/' = '99-系统/脚本/'
    '_meta/' = '99-系统/元数据/'
}

$textExtensions = @('.md', '.txt', '.json', '.jsonl', '.csv', '.ps1', '.py', '.js', '.mjs', '.cjs', '.ts', '.tsx', '.yaml', '.yml', '.toml', '.html', '.css', '.xml', '.ini')
$utf8 = [System.Text.UTF8Encoding]::new($false)
$files = Get-ChildItem -Path $root -Recurse -File -Force | Where-Object {
    $_.FullName -notlike "$root\.git\*" -and $textExtensions -contains $_.Extension.ToLowerInvariant()
}

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $updated = $content
    foreach ($entry in $replacements.GetEnumerator()) {
        $updated = $updated.Replace($entry.Key, $entry.Value)
        $updated = $updated.Replace($entry.Key.Replace('/', '\'), $entry.Value.Replace('/', '\'))
    }
    if ($updated -ne $content) {
        [System.IO.File]::WriteAllText($file.FullName, $updated, $utf8)
    }
}

Write-Output "Top-level migration completed. Processed $($files.Count) text files."
