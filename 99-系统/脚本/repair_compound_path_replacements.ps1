$ErrorActionPreference = 'Stop'

$root = if ($PSScriptRoot) {
    (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
} else {
    (Get-Location).Path
}
$textExtensions = @('.md', '.txt', '.json', '.jsonl', '.csv', '.ps1', '.py', '.js', '.mjs', '.cjs', '.ts', '.tsx', '.yaml', '.yml', '.toml', '.html', '.css', '.xml', '.ini')
$utf8 = [System.Text.UTF8Encoding]::new($false)
$repairs = [ordered]@{
    '(?<=[A-Za-z0-9_-])08-媒体与产品/媒体/' = 'media/'
    '(?<=[A-Za-z0-9_-])08-媒体与产品/视频/' = 'videos/'
    '(?<=[A-Za-z0-9_-])08-媒体与产品/素材/' = 'assets/'
    '(?<=[A-Za-z0-9_-])04-知识/卡片/' = 'cards/'
    '(?<=[A-Za-z0-9_-])04-知识/原子笔记/' = 'zettel/'
    '(?<=[A-Za-z0-9_-])99-系统/脚本/' = 'scripts/'
}

$files = Get-ChildItem -Path $root -Recurse -File -Force | Where-Object {
    $_.FullName -notlike "$root\.git\*" -and $textExtensions -contains $_.Extension.ToLowerInvariant()
}

$changed = 0
foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $updated = $content
    foreach ($entry in $repairs.GetEnumerator()) {
        $updated = [regex]::Replace($updated, $entry.Key, $entry.Value)
    }
    if ($updated -ne $content) {
        [System.IO.File]::WriteAllText($file.FullName, $updated, $utf8)
        $changed++
    }
}

Write-Output "Repaired compound-path replacements in $changed files."
