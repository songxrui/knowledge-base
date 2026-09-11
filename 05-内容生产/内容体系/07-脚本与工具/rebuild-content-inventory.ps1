[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$contentSystemRoot = Split-Path -Parent $PSScriptRoot
$contentRoot = Split-Path -Parent $contentSystemRoot
$repoRoot = Split-Path -Parent $contentRoot
$outputDirectory = Join-Path $contentSystemRoot '03-处理状态\00-缓冲区'
$manifestPath = Join-Path $outputDirectory '内容资产当前清单.csv'
$summaryPath = Join-Path $contentSystemRoot '03-处理状态\内容资产当前清单.md'

New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

$sources = @(
    [pscustomobject]@{
        Category = 'content-unit'
        Root = Join-Path $contentSystemRoot '02-内容单元库'
    }
    [pscustomobject]@{
        Category = 'dontbesilent-source'
        Root = Join-Path $repoRoot '03-资源\创作者素材\dontbesilent-聊赚钱'
    }
    [pscustomobject]@{
        Category = 'topic-assembly'
        Root = Join-Path $contentSystemRoot '06-选题装配'
    }
)

$rows = foreach ($source in $sources) {
    if (-not (Test-Path -LiteralPath $source.Root)) {
        continue
    }

    foreach ($file in (Get-ChildItem -LiteralPath $source.Root -Filter '*.md' -File -Recurse | Sort-Object FullName)) {
        $relativePath = [System.IO.Path]::GetRelativePath($repoRoot, $file.FullName).Replace('\', '/')
        [pscustomobject]@{
            category = $source.Category
            relative_path = $relativePath
            size_bytes = $file.Length
            sha256 = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
            date_named = [bool]($source.Category -eq 'dontbesilent-source' -and $file.BaseName -match '^\d{4}-\d{2}-\d{2}')
        }
    }
}

$rows | Export-Csv -LiteralPath $manifestPath -NoTypeInformation -Encoding utf8

$generatedAt = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK'
$contentUnitCount = @($rows | Where-Object category -eq 'content-unit').Count
$dontbesilentCount = @($rows | Where-Object category -eq 'dontbesilent-source').Count
$dateNamedCount = @($rows | Where-Object { $_.category -eq 'dontbesilent-source' -and $_.date_named }).Count
$assemblyCount = @($rows | Where-Object category -eq 'topic-assembly').Count
$manifestRelativePath = [System.IO.Path]::GetRelativePath($repoRoot, $manifestPath).Replace('\', '/')
$scriptRelativePath = [System.IO.Path]::GetRelativePath($repoRoot, $PSCommandPath).Replace('\', '/')

$summaryLines = @(
    '# 内容资产当前清单'
    ''
    ('> 生成时间：{0}' -f $generatedAt)
    '> 主张身份：`inventory-snapshot`'
    ('> 明细：`{0}`' -f $manifestRelativePath)
    ''
    '## 当前快照'
    ''
    '| 对象 | 数量 | 统计规则 |'
    '|---|---:|---|'
    ('| 正式内容单元 | {0} | 递归枚举 `02-内容单元库/` 下 Markdown |' -f $contentUnitCount)
    ('| dontbesilent Markdown | {0} | 递归枚举原始创作者素材目录下 Markdown |' -f $dontbesilentCount)
    ('| 其中日期命名原稿 | {0} | 文件名以 `YYYY-MM-DD` 开头 |' -f $dateNamedCount)
    ('| 当前选题装配稿 | {0} | 递归枚举 `06-选题装配/` 下 Markdown；目录不存在时为 0 |' -f $assemblyCount)
    ''
    '## 边界'
    ''
    '- 这是生成时点的目录快照，不是历史总量、已核验数量或内容质量评分。'
    '- 明细逐文件记录仓库相对路径、字节数和 SHA-256，可用于复核计数与文件身份。'
    '- 正式文档需要库存数字时引用本文件及生成时间，不复制维护长期固定数字。'
    '- 运行脚本会重建本摘要和 CSV 明细，不修改原始素材正文。'
    ''
    '## 重建'
    ''
    '```powershell'
    ('pwsh -File "{0}"' -f $scriptRelativePath)
    '```'
)
$summary = $summaryLines -join [Environment]::NewLine

Set-Content -LiteralPath $summaryPath -Value $summary -Encoding utf8

[pscustomobject]@{
    GeneratedAt = $generatedAt
    Manifest = $manifestRelativePath
    ContentUnits = $contentUnitCount
    DontbesilentMarkdown = $dontbesilentCount
    DontbesilentDateNamed = $dateNamedCount
    TopicAssemblies = $assemblyCount
} | ConvertTo-Json
