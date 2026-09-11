Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-PBVaultRoot {
    [CmdletBinding()]
    param([string]$VaultRoot)

    if ([string]::IsNullOrWhiteSpace($VaultRoot)) {
        $VaultRoot = Join-Path $PSScriptRoot '..\..\..'
    }

    $resolved = (Resolve-Path -LiteralPath $VaultRoot).Path
    if (-not (Test-Path -LiteralPath (Join-Path $resolved '.git'))) {
        throw "Vault root is not a Git worktree: $resolved"
    }
    return $resolved.TrimEnd([IO.Path]::DirectorySeparatorChar)
}

function ConvertTo-PBRelativePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)][string]$Path
    )

    $root = [IO.Path]::GetFullPath($VaultRoot).TrimEnd([IO.Path]::DirectorySeparatorChar)
    $full = [IO.Path]::GetFullPath($Path)
    if ($full.Equals($root, [StringComparison]::OrdinalIgnoreCase)) { return '' }

    $prefix = $root + [IO.Path]::DirectorySeparatorChar
    if (-not $full.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Path escapes vault root: $full"
    }
    return $full.Substring($prefix.Length).Replace([IO.Path]::DirectorySeparatorChar, '/')
}

function Join-PBPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)][string]$RelativePath
    )

    $root = [IO.Path]::GetFullPath($VaultRoot).TrimEnd([IO.Path]::DirectorySeparatorChar)
    $native = $RelativePath.Replace('/', [IO.Path]::DirectorySeparatorChar)
    $full = [IO.Path]::GetFullPath((Join-Path $root $native))
    $prefix = $root + [IO.Path]::DirectorySeparatorChar
    if (-not $full.Equals($root, [StringComparison]::OrdinalIgnoreCase) -and -not $full.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Relative path escapes vault root: $RelativePath"
    }
    return $full
}

function Read-PBJson {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "JSON file not found: $Path"
    }
    return Get-Content -LiteralPath $Path -Raw -Encoding utf8 | ConvertFrom-Json -Depth 50
}

function Write-PBJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$InputObject,
        [Parameter(Mandatory)][string]$Path
    )

    $directory = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    $json = $InputObject | ConvertTo-Json -Depth 50
    Write-PBTextAtomic -Text ($json + [Environment]::NewLine) -Path $Path
}

function Write-PBTextAtomic {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string]$Text,
        [Parameter(Mandatory)][string]$Path
    )

    $directory = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    $temporary = Join-Path $directory ('.' + [IO.Path]::GetRandomFileName() + '.tmp')
    try {
        [IO.File]::WriteAllText($temporary, $Text, [Text.UTF8Encoding]::new($false))
        Move-Item -LiteralPath $temporary -Destination $Path -Force
    } finally {
        if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force }
    }
}

function Get-PBConfiguration {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$VaultRoot)

    $metadataRoot = Join-PBPath -VaultRoot $VaultRoot -RelativePath '99-系统/元数据/personal-baseline'
    return [pscustomobject]@{
        Policy = Read-PBJson -Path (Join-Path $metadataRoot 'policy.json')
        Allowlist = Read-PBJson -Path (Join-Path $metadataRoot 'path-allowlist.json')
        Protected = Read-PBJson -Path (Join-Path $metadataRoot 'protected-paths.json')
        Contract = Read-PBJson -Path (Join-Path $metadataRoot 'contract-schema.json')
        Claim = Read-PBJson -Path (Join-Path $metadataRoot 'claim-schema.json')
        Quality = Read-PBJson -Path (Join-Path $metadataRoot 'quality-rules.json')
    }
}

function Get-PBFileRole {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$RelativePath)

    if ($RelativePath -like '03-资源/*') { return 'source' }
    if ($RelativePath -like '*/00-缓冲区/*') { return 'buffer' }
    if ($RelativePath -like '*/04-运行记录/*') { return 'run-record' }
    if ($RelativePath -like '*/05-研究与信源/*') { return 'research' }
    if ($RelativePath -like '*/90-内部治理/*') { return 'governance' }
    if ($RelativePath -like '*/03-实践协议/*') { return 'protocol' }
    if ($RelativePath -like '*/02-核心模型/*') { return 'model' }
    return 'product'
}

function Get-PBHash {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-PBTargetMarkdownFiles {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)]$Configuration
    )

    $files = @{}
    foreach ($relativeRoot in $Configuration.Policy.auditRoots) {
        $root = Join-PBPath -VaultRoot $VaultRoot -RelativePath ([string]$relativeRoot)
        if (-not (Test-Path -LiteralPath $root -PathType Container)) { continue }
        foreach ($file in Get-ChildItem -LiteralPath $root -Recurse -File -Filter '*.md') {
            $relative = ConvertTo-PBRelativePath -VaultRoot $VaultRoot -Path $file.FullName
            $segments = $relative -split '/'
            if (@($segments | Where-Object { $_ -in $Configuration.Policy.excludeDirectoryNames }).Count -gt 0) { continue }
            $files[$relative] = $file
        }
    }
    return @($files.GetEnumerator() | Sort-Object Key | ForEach-Object Value)
}

function Get-PBFileMetrics {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)][IO.FileInfo]$File
    )

    $bytes = [IO.File]::ReadAllBytes($File.FullName)
    $text = [IO.File]::ReadAllText($File.FullName, [Text.UTF8Encoding]::new($false, $true))
    $lines = if ($text.Length -eq 0) { @() } else { @([regex]::Split($text, '\r?\n')) }
    $paragraphs = if ([string]::IsNullOrWhiteSpace($text)) { @() } else { @([regex]::Split($text.Trim(), '(?:\r?\n){2,}') | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) }
    $externalUrls = @([regex]::Matches($text, 'https?://[^\s\)\]<>"''`]+') | ForEach-Object Value | ForEach-Object { $_.TrimEnd('.', ',', ';', '：', '，', '。') } | Sort-Object -Unique)
    $claimRefs = @([regex]::Matches($text, '\b(?:DK|NT|LS|PB|BL)-\d{3}\b') | ForEach-Object Value | Sort-Object -Unique)

    return [pscustomobject][ordered]@{
        path = ConvertTo-PBRelativePath -VaultRoot $VaultRoot -Path $File.FullName
        role = Get-PBFileRole -RelativePath (ConvertTo-PBRelativePath -VaultRoot $VaultRoot -Path $File.FullName)
        sha256 = Get-PBHash -Path $File.FullName
        bytes = $bytes.Length
        characters = $text.Length
        lines = $lines.Count
        paragraphs = $paragraphs.Count
        wikiLinks = ([regex]::Matches($text, '\[\[[^\]]+\]\]')).Count
        externalUrls = $externalUrls.Count
        claimReferences = $claimRefs.Count
        bookReferences = ([regex]::Matches($text, '《[^》]+》')).Count
        trailingWhitespaceLines = @($lines | Where-Object { $_ -match '[ \t]+$' }).Count
        hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    }
}

function Get-PBProductVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)]$Configuration
    )

    $sot = Join-PBPath -VaultRoot $VaultRoot -RelativePath (([string]$Configuration.Policy.productRoot) + '/SOURCE_OF_TRUTH.md')
    $text = [IO.File]::ReadAllText($sot, [Text.UTF8Encoding]::new($false, $true))
    $match = [regex]::Match($text, '当前产品版本：`([^`]+)`')
    if ($match.Success) { return $match.Groups[1].Value }
    return 'unknown'
}

function Get-PBObjectHash {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$InputObject)

    $json = $InputObject | ConvertTo-Json -Depth 50 -Compress
    $bytes = [Text.Encoding]::UTF8.GetBytes($json)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([Convert]::ToHexString($sha.ComputeHash($bytes))).ToLowerInvariant() }
    finally { $sha.Dispose() }
}

function New-PBInventoryManifest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)]$Configuration
    )

    $metrics = @(Get-PBTargetMarkdownFiles -VaultRoot $VaultRoot -Configuration $Configuration | ForEach-Object {
        Get-PBFileMetrics -VaultRoot $VaultRoot -File $_
    })

    $payload = [ordered]@{
        schemaVersion = '1.0.0'
        productVersion = Get-PBProductVersion -VaultRoot $VaultRoot -Configuration $Configuration
        roots = @($Configuration.Policy.auditRoots)
        files = $metrics
        totals = [ordered]@{
            files = $metrics.Count
            bytes = ($metrics | Measure-Object -Property bytes -Sum).Sum
            characters = ($metrics | Measure-Object -Property characters -Sum).Sum
            paragraphs = ($metrics | Measure-Object -Property paragraphs -Sum).Sum
            wikiLinks = ($metrics | Measure-Object -Property wikiLinks -Sum).Sum
            externalUrls = ($metrics | Measure-Object -Property externalUrls -Sum).Sum
            claimReferences = ($metrics | Measure-Object -Property claimReferences -Sum).Sum
            bookReferences = ($metrics | Measure-Object -Property bookReferences -Sum).Sum
        }
    }
    $payload.fingerprint = Get-PBObjectHash -InputObject $payload
    return [pscustomobject]$payload
}

function New-PBIssue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet('error','warning','info')][string]$Severity,
        [Parameter(Mandatory)][string]$Rule,
        [Parameter(Mandatory)][string]$Path,
        [int]$Line = 0,
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('none','safe-fix','candidate','human')][string]$Action = 'none'
    )

    return [pscustomobject][ordered]@{
        severity = $Severity
        rule = $Rule
        path = $Path
        line = $Line
        message = $Message
        action = $Action
    }
}

function Get-PBLineNumber {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][int]$Index
    )

    if ($Index -le 0) { return 1 }
    return ([regex]::Matches($Text.Substring(0, $Index), '\n')).Count + 1
}

function Test-PBMarkdownStructure {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)]$Configuration
    )

    $issues = [Collections.Generic.List[object]]::new()
    foreach ($file in Get-PBTargetMarkdownFiles -VaultRoot $VaultRoot -Configuration $Configuration) {
        $relative = ConvertTo-PBRelativePath -VaultRoot $VaultRoot -Path $file.FullName
        $bytes = [IO.File]::ReadAllBytes($file.FullName)
        $text = [IO.File]::ReadAllText($file.FullName, [Text.UTF8Encoding]::new($false, $true))
        if ([string]::IsNullOrWhiteSpace($text)) {
            $issues.Add((New-PBIssue -Severity error -Rule 'markdown-empty' -Path $relative -Message 'Markdown file is empty.' -Action human))
            continue
        }
        if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            $issues.Add((New-PBIssue -Severity warning -Rule 'markdown-bom' -Path $relative -Line 1 -Message 'UTF-8 BOM is present.' -Action safe-fix))
        }

        $lines = @([regex]::Split($text, '\r?\n'))
        $inFence = $false
        $headings = [Collections.Generic.List[int]]::new()
        for ($index = 0; $index -lt $lines.Count; $index++) {
            $line = $lines[$index]
            $lineNumber = $index + 1
            if ($line -match '^\s*```') { $inFence = -not $inFence; continue }
            if ($inFence) { continue }
            if ($line -match '[ \t]+$') {
                $issues.Add((New-PBIssue -Severity warning -Rule 'markdown-trailing-whitespace' -Path $relative -Line $lineNumber -Message 'Line ends with whitespace.' -Action safe-fix))
            }
            if ($line -match '^(#{1,6})\s+') {
                $level = $Matches[1].Length
                if ($headings.Count -gt 0 -and $level -gt ($headings[$headings.Count - 1] + 1)) {
                    $issues.Add((New-PBIssue -Severity warning -Rule 'markdown-heading-jump' -Path $relative -Line $lineNumber -Message "Heading jumps from H$($headings[$headings.Count - 1]) to H$level." -Action candidate))
                }
                $headings.Add($level)
            }
            if ($index -gt 0 -and $line -match '^\s*\|(?:\s*:?-+:?\s*\|)+\s*$' -and $lines[$index - 1] -match '^\s*\|') {
                $headerPipes = ([regex]::Matches($lines[$index - 1], '(?<!\\)\|')).Count
                $separatorPipes = ([regex]::Matches($line, '(?<!\\)\|')).Count
                if ($headerPipes -ne $separatorPipes) {
                    $issues.Add((New-PBIssue -Severity error -Rule 'markdown-table-columns' -Path $relative -Line $lineNumber -Message "Table header has $headerPipes pipes but separator has $separatorPipes." -Action safe-fix))
                }
            }
        }
        if ($inFence) {
            $issues.Add((New-PBIssue -Severity error -Rule 'markdown-unclosed-fence' -Path $relative -Message 'Code fence is not closed.' -Action human))
        }
        if (@($headings | Where-Object { $_ -eq 1 }).Count -gt 1) {
            $issues.Add((New-PBIssue -Severity warning -Rule 'markdown-multiple-h1' -Path $relative -Message 'File contains more than one H1 heading.' -Action candidate))
        }
    }
    return @($issues)
}

function Test-PBReferenceExists {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)][string]$ProductRoot,
        [Parameter(Mandatory)][string]$SourceDirectory,
        [Parameter(Mandatory)][string]$Target,
        [Parameter(Mandatory)]$BaseNameIndex
    )

    $clean = [Uri]::UnescapeDataString($Target.Trim().Trim('<', '>'))
    $clean = ($clean -replace '#.*$', '') -replace ':\d+(?::\d+)?$', ''
    if ([string]::IsNullOrWhiteSpace($clean)) { return $true }
    $native = $clean.Replace('/', [IO.Path]::DirectorySeparatorChar)
    $variants = [Collections.Generic.List[string]]::new()
    $variants.Add($native)
    if (-not [IO.Path]::HasExtension($native)) {
        $variants.Add($native + '.md')
        $variants.Add((Join-Path $native 'README.md'))
    }

    foreach ($variant in $variants) {
        foreach ($base in @($SourceDirectory, $ProductRoot, $VaultRoot)) {
            try {
                if (Test-Path -LiteralPath (Join-Path $base $variant)) { return $true }
            } catch { }
        }
    }

    if ($clean -notmatch '[/\\]') {
        $baseName = [IO.Path]::GetFileNameWithoutExtension($clean)
        if ($BaseNameIndex.ContainsKey($baseName)) { return $true }
    }
    return $false
}

function Test-PBLocalReferences {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)]$Configuration
    )

    $issues = [Collections.Generic.List[object]]::new()
    $files = @(Get-PBTargetMarkdownFiles -VaultRoot $VaultRoot -Configuration $Configuration)
    $productRoot = Join-PBPath -VaultRoot $VaultRoot -RelativePath ([string]$Configuration.Policy.productRoot)
    $baseNameIndex = @{}
    foreach ($file in $files) {
        if (-not $baseNameIndex.ContainsKey($file.BaseName)) { $baseNameIndex[$file.BaseName] = @() }
        $baseNameIndex[$file.BaseName] += $file.FullName
    }

    foreach ($file in $files) {
        $relative = ConvertTo-PBRelativePath -VaultRoot $VaultRoot -Path $file.FullName
        $text = [IO.File]::ReadAllText($file.FullName, [Text.UTF8Encoding]::new($false, $true))
        foreach ($match in [regex]::Matches($text, '\[\[([^\]|#]+)(?:#[^\]|]+)?(?:\|[^\]]+)?\]\]')) {
            $target = $match.Groups[1].Value.Trim()
            if (-not (Test-PBReferenceExists -VaultRoot $VaultRoot -ProductRoot $productRoot -SourceDirectory $file.DirectoryName -Target $target -BaseNameIndex $baseNameIndex)) {
                $issues.Add((New-PBIssue -Severity error -Rule 'reference-broken-wiki' -Path $relative -Line (Get-PBLineNumber -Text $text -Index $match.Index) -Message "Wiki target does not resolve: $target" -Action human))
            }
        }
        foreach ($match in [regex]::Matches($text, '\[[^\]]+\]\((?!https?://|mailto:|#)([^\)\s]+)(?:\s+"[^"]*")?\)')) {
            $target = $match.Groups[1].Value.Trim()
            if (-not (Test-PBReferenceExists -VaultRoot $VaultRoot -ProductRoot $productRoot -SourceDirectory $file.DirectoryName -Target $target -BaseNameIndex $baseNameIndex)) {
                $issues.Add((New-PBIssue -Severity error -Rule 'reference-broken-markdown' -Path $relative -Line (Get-PBLineNumber -Text $text -Index $match.Index) -Message "Markdown target does not resolve: $target" -Action human))
            }
        }
        foreach ($match in [regex]::Matches($text, '`([^`\r\n]+)`')) {
            $target = $match.Groups[1].Value.Trim()
            if ($target -notmatch '\.(?:md|txt|csv|json|ps1|py)(?::\d+)?$') { continue }
            if ($target -match '^RUN-') { continue }
            if ($target -match '[*{}<>|]') { continue }
            if (-not (Test-PBReferenceExists -VaultRoot $VaultRoot -ProductRoot $productRoot -SourceDirectory $file.DirectoryName -Target $target -BaseNameIndex $baseNameIndex)) {
                $issues.Add((New-PBIssue -Severity error -Rule 'reference-broken-code-path' -Path $relative -Line (Get-PBLineNumber -Text $text -Index $match.Index) -Message "Code path does not resolve: $target" -Action human))
            }
        }
    }
    return @($issues)
}

function Get-PBExternalUrlOccurrences {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)]$Configuration
    )

    $urls = @{}
    foreach ($file in Get-PBTargetMarkdownFiles -VaultRoot $VaultRoot -Configuration $Configuration) {
        $relative = ConvertTo-PBRelativePath -VaultRoot $VaultRoot -Path $file.FullName
        $text = [IO.File]::ReadAllText($file.FullName, [Text.UTF8Encoding]::new($false, $true))
        foreach ($match in [regex]::Matches($text, 'https?://[^\s\)\]<>"''`]+')) {
            $url = $match.Value.TrimEnd('.', ',', ';', '：', '，', '。')
            if (-not $urls.ContainsKey($url)) { $urls[$url] = [Collections.Generic.List[object]]::new() }
            $urls[$url].Add([pscustomobject]@{ path = $relative; line = Get-PBLineNumber -Text $text -Index $match.Index })
        }
    }
    return $urls
}

function Test-PBExternalSources {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)]$Configuration,
        [int]$MaxUrls = 0
    )

    $issues = [Collections.Generic.List[object]]::new()
    $occurrences = Get-PBExternalUrlOccurrences -VaultRoot $VaultRoot -Configuration $Configuration
    $urls = @($occurrences.Keys | Sort-Object)
    if ($MaxUrls -gt 0) { $urls = @($urls | Select-Object -First $MaxUrls) }

    $handler = [Net.Http.HttpClientHandler]::new()
    $handler.AllowAutoRedirect = $true
    $client = [Net.Http.HttpClient]::new($handler)
    $client.Timeout = [TimeSpan]::FromSeconds([int]$Configuration.Policy.networkTimeoutSeconds)
    $client.DefaultRequestHeaders.UserAgent.ParseAdd('PersonalBaselineAudit/1.0')
    try {
        foreach ($url in $urls) {
            $first = $occurrences[$url][0]
            $request = $null
            $response = $null
            try {
                $request = [Net.Http.HttpRequestMessage]::new([Net.Http.HttpMethod]::Head, $url)
                $response = $client.SendAsync($request).GetAwaiter().GetResult()
                if ([int]$response.StatusCode -in @(405, 501)) {
                    $response.Dispose()
                    $request.Dispose()
                    $request = [Net.Http.HttpRequestMessage]::new([Net.Http.HttpMethod]::Get, $url)
                    $response = $client.SendAsync($request, [Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()
                }
                $code = [int]$response.StatusCode
                if ($code -in @(401, 403)) {
                    $issues.Add((New-PBIssue -Severity info -Rule 'external-access-restricted' -Path $first.path -Line $first.line -Message "External source returned HTTP ${code}: $url" -Action none))
                } elseif ($code -in @(404, 410)) {
                    $issues.Add((New-PBIssue -Severity error -Rule 'external-not-found' -Path $first.path -Line $first.line -Message "External source returned HTTP ${code}: $url" -Action candidate))
                } elseif ($code -eq 429 -or $code -ge 500) {
                    $issues.Add((New-PBIssue -Severity warning -Rule 'external-temporary-failure' -Path $first.path -Line $first.line -Message "External source returned HTTP ${code}: $url" -Action none))
                } elseif ($code -lt 200 -or $code -ge 400) {
                    $issues.Add((New-PBIssue -Severity warning -Rule 'external-unexpected-status' -Path $first.path -Line $first.line -Message "External source returned HTTP ${code}: $url" -Action none))
                }
            } catch [System.Threading.Tasks.TaskCanceledException] {
                $issues.Add((New-PBIssue -Severity warning -Rule 'external-timeout' -Path $first.path -Line $first.line -Message "External source timed out and was not classified as dead: $url" -Action none))
            } catch {
                $issues.Add((New-PBIssue -Severity warning -Rule 'external-network-error' -Path $first.path -Line $first.line -Message "External source could not be verified: $url ($($_.Exception.Message))" -Action none))
            } finally {
                if ($null -ne $response) { $response.Dispose() }
                if ($null -ne $request) { $request.Dispose() }
            }
        }
    } finally {
        $client.Dispose()
        $handler.Dispose()
    }
    return @($issues)
}

function Get-PBYamlBlockKeys {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Text)

    $match = [regex]::Match($Text, '(?ms)^```yaml\s*\r?\n(.*?)^```')
    if (-not $match.Success) { return $null }
    $top = [Collections.Generic.List[string]]::new()
    $states = [Collections.Generic.List[string]]::new()
    foreach ($line in [regex]::Split($match.Groups[1].Value, '\r?\n')) {
        if ($line -match '^([a-z_]+):') { $top.Add($Matches[1]) }
        if ($line -match '^  ([KAPREFQH]):') { $states.Add($Matches[1]) }
    }
    return [pscustomobject]@{ top = @($top); states = @($states) }
}

function Test-PBContractSchema {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)]$Configuration
    )

    $issues = [Collections.Generic.List[object]]::new()
    $canonicalPath = Join-PBPath -VaultRoot $VaultRoot -RelativePath ([string]$Configuration.Contract.canonicalFile)
    $templatePath = Join-PBPath -VaultRoot $VaultRoot -RelativePath ([string]$Configuration.Contract.templateFile)
    $canonicalText = [IO.File]::ReadAllText($canonicalPath, [Text.UTF8Encoding]::new($false, $true))
    $templateText = [IO.File]::ReadAllText($templatePath, [Text.UTF8Encoding]::new($false, $true))
    $canonical = Get-PBYamlBlockKeys -Text $canonicalText
    $template = Get-PBYamlBlockKeys -Text $templateText
    if ($null -eq $canonical) {
        $issues.Add((New-PBIssue -Severity error -Rule 'contract-canonical-block' -Path ([string]$Configuration.Contract.canonicalFile) -Message 'Canonical YAML block is missing.' -Action human))
        return @($issues)
    }
    if ($null -eq $template) {
        $issues.Add((New-PBIssue -Severity error -Rule 'contract-template-block' -Path ([string]$Configuration.Contract.templateFile) -Message 'Template YAML block is missing.' -Action human))
        return @($issues)
    }

    $required = @($Configuration.Contract.requiredFields)
    foreach ($field in $required) {
        if ($field -notin $canonical.top) {
            $issues.Add((New-PBIssue -Severity error -Rule 'contract-canonical-field' -Path ([string]$Configuration.Contract.canonicalFile) -Message "Canonical contract is missing field: $field" -Action human))
        }
        if ($field -notin $template.top) {
            $issues.Add((New-PBIssue -Severity error -Rule 'contract-template-field' -Path ([string]$Configuration.Contract.templateFile) -Message "Run template is missing field: $field" -Action human))
        }
    }
    foreach ($field in $canonical.top | Group-Object | Where-Object Count -gt 1) {
        $issues.Add((New-PBIssue -Severity error -Rule 'contract-duplicate-field' -Path ([string]$Configuration.Contract.canonicalFile) -Message "Canonical contract repeats field: $($field.Name)" -Action human))
    }
    foreach ($state in $Configuration.Contract.stateKeys) {
        if ($state -notin $canonical.states -or $state -notin $template.states) {
            $issues.Add((New-PBIssue -Severity error -Rule 'contract-state-key' -Path ([string]$Configuration.Contract.canonicalFile) -Message "State key is not present in both schemas: $state" -Action human))
        }
    }

    $dailyPath = Join-PBPath -VaultRoot $VaultRoot -RelativePath (([string]$Configuration.Policy.productRoot) + '/03-实践协议/02-每日记录表.md')
    $reviewPath = Join-PBPath -VaultRoot $VaultRoot -RelativePath (([string]$Configuration.Policy.productRoot) + '/03-实践协议/03-第七天复盘表.md')
    $runReadmePath = Join-PBPath -VaultRoot $VaultRoot -RelativePath (([string]$Configuration.Policy.productRoot) + '/04-运行记录/README.md')
    $dailyText = [IO.File]::ReadAllText($dailyPath)
    $reviewText = [IO.File]::ReadAllText($reviewPath)
    $runReadmeText = [IO.File]::ReadAllText($runReadmePath)
    foreach ($decision in $Configuration.Contract.nextDecisions) {
        if (-not $dailyText.Contains([string]$decision) -or -not $reviewText.Contains([string]$decision)) {
            $issues.Add((New-PBIssue -Severity error -Rule 'contract-next-decision' -Path (ConvertTo-PBRelativePath -VaultRoot $VaultRoot -Path $dailyPath) -Message "Next-decision enum is inconsistent: $decision" -Action human))
        }
    }
    foreach ($status in $Configuration.Contract.runStatuses) {
        if (-not $runReadmeText.Contains([string]$status)) {
            $issues.Add((New-PBIssue -Severity error -Rule 'contract-run-status' -Path (ConvertTo-PBRelativePath -VaultRoot $VaultRoot -Path $runReadmePath) -Message "Run status is missing: $status" -Action human))
        }
    }
    return @($issues)
}

function Get-PBLedgerClaims {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$LedgerPath)

    $claims = [Collections.Generic.List[object]]::new()
    $lines = @([IO.File]::ReadAllLines($LedgerPath, [Text.UTF8Encoding]::new($false, $true)))
    for ($index = 0; $index -lt $lines.Count; $index++) {
        $line = $lines[$index]
        if ($line -notmatch '^\| `([A-Z][A-Z0-9]*-\d{3})` \|') { continue }
        $cells = @($line.Trim().Trim('|').Split('|') | ForEach-Object { $_.Trim() })
        $claims.Add([pscustomobject]@{
            id = $Matches[1]
            line = $index + 1
            cells = $cells
            levelStatus = if ($cells.Count -ge 3) { $cells[2].Trim('`') } else { '' }
            source = if ($cells.Count -ge 4) { $cells[3] } else { '' }
        })
    }
    return @($claims)
}

function Test-PBClaimLedger {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)]$Configuration
    )

    $issues = [Collections.Generic.List[object]]::new()
    $ledgerPath = Join-PBPath -VaultRoot $VaultRoot -RelativePath ([string]$Configuration.Claim.ledgerFile)
    $claims = @(Get-PBLedgerClaims -LedgerPath $ledgerPath)
    $ledgerRelative = [string]$Configuration.Claim.ledgerFile
    foreach ($group in $claims | Group-Object id | Where-Object Count -gt 1) {
        $issues.Add((New-PBIssue -Severity error -Rule 'claim-duplicate-id' -Path $ledgerRelative -Line $group.Group[1].line -Message "Claim ID is duplicated: $($group.Name)" -Action human))
    }
    foreach ($claim in $claims) {
        if ($claim.id -notmatch [string]$Configuration.Claim.idPattern) {
            $issues.Add((New-PBIssue -Severity error -Rule 'claim-id-format' -Path $ledgerRelative -Line $claim.line -Message "Claim ID does not match schema: $($claim.id)" -Action human))
        }
        if ($claim.id -notlike 'BL-*') {
            $levelMatch = [regex]::Match($claim.levelStatus, '\b(E[1-5])\s+([a-z-]+)\b')
            if (-not $levelMatch.Success) {
                $issues.Add((New-PBIssue -Severity error -Rule 'claim-level-status' -Path $ledgerRelative -Line $claim.line -Message "Evidence level/status is invalid: $($claim.levelStatus)" -Action human))
            } elseif ($levelMatch.Groups[2].Value -notin $Configuration.Claim.allowedStatuses) {
                $issues.Add((New-PBIssue -Severity error -Rule 'claim-status-enum' -Path $ledgerRelative -Line $claim.line -Message "Claim status is not allowed: $($levelMatch.Groups[2].Value)" -Action human))
            }
        }
        $prefix = $claim.id.Split('-')[0]
        if ($prefix -in $Configuration.Claim.requireLocatorForPrefixes -and [string]::IsNullOrWhiteSpace($claim.source)) {
            $issues.Add((New-PBIssue -Severity error -Rule 'claim-source-missing' -Path $ledgerRelative -Line $claim.line -Message "Claim has no source cell: $($claim.id)" -Action human))
        }
    }

    $known = @{}; foreach ($claim in $claims) { $known[$claim.id] = $true }
    $referenced = @{}
    foreach ($file in Get-PBTargetMarkdownFiles -VaultRoot $VaultRoot -Configuration $Configuration) {
        if ($file.FullName -eq $ledgerPath) { continue }
        $relative = ConvertTo-PBRelativePath -VaultRoot $VaultRoot -Path $file.FullName
        $text = [IO.File]::ReadAllText($file.FullName)
        foreach ($match in [regex]::Matches($text, '\b(?:DK|NT|LS|PB|BL)-\d{3}\b')) {
            $referenced[$match.Value] = $true
            if (-not $known.ContainsKey($match.Value)) {
                $issues.Add((New-PBIssue -Severity error -Rule 'claim-reference-missing' -Path $relative -Line (Get-PBLineNumber -Text $text -Index $match.Index) -Message "Referenced claim is absent from ledger: $($match.Value)" -Action human))
            }
        }
    }
    foreach ($claim in $claims) {
        if (-not $referenced.ContainsKey($claim.id)) {
            $issues.Add((New-PBIssue -Severity info -Rule 'claim-orphan' -Path $ledgerRelative -Line $claim.line -Message "Claim is not referenced outside the ledger: $($claim.id)" -Action candidate))
        }
    }
    return @($issues)
}

function Test-PBContentQuality {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)]$Configuration
    )

    $issues = [Collections.Generic.List[object]]::new()
    foreach ($file in Get-PBTargetMarkdownFiles -VaultRoot $VaultRoot -Configuration $Configuration) {
        $relative = ConvertTo-PBRelativePath -VaultRoot $VaultRoot -Path $file.FullName
        if ((Get-PBFileRole -RelativePath $relative) -eq 'source') { continue }
        if ($relative -in $Configuration.Policy.qualityScanExcludeFiles) { continue }
        $text = [IO.File]::ReadAllText($file.FullName)
        $lines = @([regex]::Split($text, '\r?\n'))
        $inFence = $false
        for ($index = 0; $index -lt $lines.Count; $index++) {
            $line = $lines[$index]
            if ($line -match '^\s*```') { $inFence = -not $inFence; continue }
            if ($inFence) { continue }
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            $contextStart = [Math]::Max(0, $index - 5)
            $context = @($lines[$contextStart..$index]) -join ' '
            $qualified = $false
            foreach ($pattern in $Configuration.Quality.negativeQualifierPatterns) {
                if ($context.Contains([string]$pattern)) { $qualified = $true; break }
            }
            if ($context -match '不服务谁|边界|常见误用|停止与|禁止升级|当前阻断事实') { $qualified = $true }
            foreach ($pattern in $Configuration.Quality.scaffoldPatterns) {
                if ($line.Contains([string]$pattern)) {
                    $issues.Add((New-PBIssue -Severity warning -Rule 'quality-scaffold' -Path $relative -Line ($index + 1) -Message "Scaffold marker found: $pattern" -Action candidate))
                }
            }
            if (-not $qualified) {
                foreach ($pattern in $Configuration.Quality.fabricationSignals) {
                    if ($line.Contains([string]$pattern)) {
                        $issues.Add((New-PBIssue -Severity error -Rule 'quality-fabrication-signal' -Path $relative -Line ($index + 1) -Message "Potential fabricated result or story: $pattern" -Action human))
                    }
                }
                foreach ($pattern in $Configuration.Quality.overclaimPatterns) {
                    if ($line.Contains([string]$pattern)) {
                        $issues.Add((New-PBIssue -Severity warning -Rule 'quality-overclaim' -Path $relative -Line ($index + 1) -Message "Potential overclaim: $pattern" -Action candidate))
                    }
                }
                foreach ($pattern in $Configuration.Quality.highRiskTerms) {
                    if ($line.Contains([string]$pattern)) {
                        $issues.Add((New-PBIssue -Severity warning -Rule 'quality-high-risk-unqualified' -Path $relative -Line ($index + 1) -Message "High-risk term lacks a same-line qualifier: $pattern" -Action human))
                    }
                }
            }
        }
    }
    return @($issues)
}

function Get-PBExactDuplicateParagraphs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)]$Configuration
    )

    $minimum = [int]$Configuration.Quality.minimumDuplicateParagraphCharacters
    $index = @{}
    foreach ($file in Get-PBTargetMarkdownFiles -VaultRoot $VaultRoot -Configuration $Configuration) {
        $relative = ConvertTo-PBRelativePath -VaultRoot $VaultRoot -Path $file.FullName
        if ((Get-PBFileRole -RelativePath $relative) -in @('source','buffer')) { continue }
        $text = [IO.File]::ReadAllText($file.FullName)
        foreach ($paragraph in [regex]::Split($text, '(?:\r?\n){2,}')) {
            $normalized = ([regex]::Replace($paragraph.Trim(), '\s+', ' '))
            if ($normalized.Length -lt $minimum -or $normalized.StartsWith('|') -or $normalized.StartsWith('```')) { continue }
            $hash = Get-PBObjectHash -InputObject $normalized
            if (-not $index.ContainsKey($hash)) { $index[$hash] = [Collections.Generic.List[object]]::new() }
            $index[$hash].Add([pscustomobject]@{ path = $relative; preview = $normalized.Substring(0, [Math]::Min(120, $normalized.Length)) })
        }
    }
    return @($index.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 } | Sort-Object Key | ForEach-Object {
        [pscustomobject]@{ hash = $_.Key; occurrences = @($_.Value) }
    })
}

function New-PBCheckResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Check,
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Issues
    )

    return [pscustomobject][ordered]@{
        check = $Check
        summary = [ordered]@{
            errors = @($Issues | Where-Object severity -eq 'error').Count
            warnings = @($Issues | Where-Object severity -eq 'warning').Count
            info = @($Issues | Where-Object severity -eq 'info').Count
            total = $Issues.Count
        }
        issues = @($Issues | Sort-Object severity, path, line, rule)
    }
}

function Test-PBPathUnderRoot {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RelativePath,
        [Parameter(Mandatory)][string]$RelativeRoot
    )

    $path = $RelativePath.Trim('/').Replace('\', '/')
    $root = $RelativeRoot.Trim('/').Replace('\', '/')
    return $path.Equals($root, [StringComparison]::OrdinalIgnoreCase) -or $path.StartsWith($root + '/', [StringComparison]::OrdinalIgnoreCase)
}

function Test-PBProtectedPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RelativePath,
        [Parameter(Mandatory)]$Configuration
    )

    if ($RelativePath -in $Configuration.Protected.exactFiles) { return $true }
    foreach ($root in $Configuration.Protected.directoryRoots) {
        if (Test-PBPathUnderRoot -RelativePath $RelativePath -RelativeRoot ([string]$root)) { return $true }
    }
    return $false
}

function Test-PBSafeFixAllowed {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RelativePath,
        [Parameter(Mandatory)]$Configuration
    )

    if (Test-PBProtectedPath -RelativePath $RelativePath -Configuration $Configuration) { return $false }
    foreach ($root in $Configuration.Allowlist.safeFixRoots) {
        if (Test-PBPathUnderRoot -RelativePath $RelativePath -RelativeRoot ([string]$root)) { return $true }
    }
    return $false
}

function Convert-PBDeterministicMarkdownFixes {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Text)

    $actions = [Collections.Generic.List[string]]::new()
    $newline = if ($Text.Contains("`r`n")) { "`r`n" } else { "`n" }
    $hadFinalNewline = $Text.EndsWith("`n")
    $lines = @([regex]::Split($Text, '\r?\n'))
    $inFence = $false
    for ($index = 0; $index -lt $lines.Count; $index++) {
        $line = $lines[$index]
        if ($line -match '^\s*```') { $inFence = -not $inFence; continue }
        if ($inFence) { continue }
        $match = [regex]::Match($line, '[ \t]+$')
        if ($match.Success) {
            $suffix = $match.Value
            $preserveHardBreak = ($suffix -eq '  ' -and $line.Trim().Length -gt 0)
            if (-not $preserveHardBreak) {
                $lines[$index] = $line.Substring(0, $match.Index)
                if (-not $actions.Contains('remove-trailing-whitespace')) { $actions.Add('remove-trailing-whitespace') }
            }
        }
        if ($index -gt 0 -and $lines[$index] -match '^\s*\|(?:\s*:?-+:?\s*\|)+\s*$' -and $lines[$index - 1] -match '^\s*\|') {
            $headerPipes = ([regex]::Matches($lines[$index - 1], '(?<!\\)\|')).Count
            $separatorPipes = ([regex]::Matches($lines[$index], '(?<!\\)\|')).Count
            if ($headerPipes -ne $separatorPipes -and $headerPipes -ge 2) {
                $columns = $headerPipes - 1
                $lines[$index] = '|' + (('---|' * $columns))
                if (-not $actions.Contains('repair-table-separator')) { $actions.Add('repair-table-separator') }
            }
        }
    }

    $result = $lines -join $newline
    if (-not $hadFinalNewline) { $result = $result.TrimEnd("`r", "`n") }
    return [pscustomobject]@{ text = $result; actions = @($actions) }
}

function Get-PBSafeFixPlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)]$Configuration
    )

    $changes = [Collections.Generic.List[object]]::new()
    foreach ($file in Get-PBTargetMarkdownFiles -VaultRoot $VaultRoot -Configuration $Configuration) {
        $relative = ConvertTo-PBRelativePath -VaultRoot $VaultRoot -Path $file.FullName
        if (-not (Test-PBSafeFixAllowed -RelativePath $relative -Configuration $Configuration)) { continue }
        $bytes = [IO.File]::ReadAllBytes($file.FullName)
        $hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
        $original = [IO.File]::ReadAllText($file.FullName, [Text.UTF8Encoding]::new($false, $true))
        $fixed = Convert-PBDeterministicMarkdownFixes -Text $original
        $actions = [Collections.Generic.List[string]]::new()
        foreach ($action in $fixed.actions) { $actions.Add($action) }
        if ($hasBom) { $actions.Insert(0, 'remove-utf8-bom') }
        if ($actions.Count -eq 0 -and $fixed.text -eq $original) { continue }
        $ratio = if ($original.Length -eq 0) { 0 } else { [Math]::Abs($fixed.text.Length - $original.Length) / $original.Length }
        $changes.Add([pscustomobject]@{
            path = $relative
            fullPath = $file.FullName
            actions = @($actions)
            beforeHash = Get-PBHash -Path $file.FullName
            beforeCharacters = $original.Length
            afterCharacters = $fixed.text.Length
            characterChangeRatio = [Math]::Round($ratio, 6)
            content = $fixed.text
        })
    }
    return @($changes)
}

function Get-PBLocalAuditIssues {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)]$Configuration
    )

    $issues = [Collections.Generic.List[object]]::new()
    foreach ($issue in Test-PBMarkdownStructure -VaultRoot $VaultRoot -Configuration $Configuration) { $issues.Add($issue) }
    foreach ($issue in Test-PBLocalReferences -VaultRoot $VaultRoot -Configuration $Configuration) { $issues.Add($issue) }
    foreach ($issue in Test-PBClaimLedger -VaultRoot $VaultRoot -Configuration $Configuration) { $issues.Add($issue) }
    foreach ($issue in Test-PBContractSchema -VaultRoot $VaultRoot -Configuration $Configuration) { $issues.Add($issue) }
    foreach ($issue in Test-PBContentQuality -VaultRoot $VaultRoot -Configuration $Configuration) { $issues.Add($issue) }
    return @($issues)
}

function Invoke-PBSafeFixes {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)]$Configuration,
        [switch]$Apply
    )

    $plan = @(Get-PBSafeFixPlan -VaultRoot $VaultRoot -Configuration $Configuration)
    if ($plan.Count -gt [int]$Configuration.Policy.maxFilesPerBatch) {
        throw "Safe-fix plan exceeds maxFilesPerBatch: $($plan.Count)"
    }
    foreach ($change in $plan) {
        if ($change.characterChangeRatio -gt [double]$Configuration.Policy.maxCharacterChangeRatio) {
            throw "Safe-fix change ratio exceeds policy for $($change.path): $($change.characterChangeRatio)"
        }
    }

    if (-not $Apply -or $plan.Count -eq 0) {
        return [pscustomobject]@{ applied = $false; rolledBack = $false; changes = @($plan | Select-Object path, actions, beforeHash, beforeCharacters, afterCharacters, characterChangeRatio); validationIssues = @() }
    }

    $snapshots = @{}
    try {
        foreach ($change in $plan) {
            if (-not (Test-PBSafeFixAllowed -RelativePath $change.path -Configuration $Configuration)) {
                throw "Path left safe-fix allowlist after planning: $($change.path)"
            }
            if ((Get-PBHash -Path $change.fullPath) -ne $change.beforeHash) {
                throw "File changed after planning: $($change.path)"
            }
            $snapshots[$change.fullPath] = [IO.File]::ReadAllBytes($change.fullPath)
            Write-PBTextAtomic -Text $change.content -Path $change.fullPath
        }
        $validation = @(Get-PBLocalAuditIssues -VaultRoot $VaultRoot -Configuration $Configuration)
        $errors = @($validation | Where-Object severity -eq 'error')
        if ($errors.Count -gt 0) {
            foreach ($entry in $snapshots.GetEnumerator()) { [IO.File]::WriteAllBytes($entry.Key, $entry.Value) }
            return [pscustomobject]@{ applied = $false; rolledBack = $true; changes = @($plan | Select-Object path, actions, beforeHash, beforeCharacters, afterCharacters, characterChangeRatio); validationIssues = $validation }
        }
        return [pscustomobject]@{ applied = $true; rolledBack = $false; changes = @($plan | Select-Object path, actions, beforeHash, beforeCharacters, afterCharacters, characterChangeRatio); validationIssues = $validation }
    } catch {
        foreach ($entry in $snapshots.GetEnumerator()) { [IO.File]::WriteAllBytes($entry.Key, $entry.Value) }
        throw
    }
}

function Compare-PBContentBaseline {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)]$Configuration
    )

    $baselinePath = Join-PBPath -VaultRoot $VaultRoot -RelativePath (([string]$Configuration.Policy.metadataRoot) + '/baseline-manifest.json')
    $baseline = Read-PBJson -Path $baselinePath
    $current = New-PBInventoryManifest -VaultRoot $VaultRoot -Configuration $Configuration
    $issues = [Collections.Generic.List[object]]::new()
    $baselineFiles = @{}; foreach ($file in $baseline.files) { $baselineFiles[$file.path] = $file }
    $currentFiles = @{}; foreach ($file in $current.files) { $currentFiles[$file.path] = $file }
    foreach ($path in $baselineFiles.Keys) {
        if (-not $currentFiles.ContainsKey($path)) {
            $issues.Add((New-PBIssue -Severity error -Rule 'baseline-file-missing' -Path $path -Message 'Baseline file is missing from current inventory.' -Action human))
        }
    }
    foreach ($path in $currentFiles.Keys) {
        if (-not $baselineFiles.ContainsKey($path)) {
            $issues.Add((New-PBIssue -Severity info -Rule 'baseline-file-added' -Path $path -Message 'File was added after baseline.' -Action none))
        } elseif ($currentFiles[$path].sha256 -ne $baselineFiles[$path].sha256) {
            $issues.Add((New-PBIssue -Severity info -Rule 'baseline-file-changed' -Path $path -Message 'File content differs from baseline.' -Action none))
        }
    }

    $characterRatio = if ([double]$baseline.totals.characters -eq 0) { 1 } else { [double]$current.totals.characters / [double]$baseline.totals.characters }
    $paragraphRatio = if ([double]$baseline.totals.paragraphs -eq 0) { 1 } else { [double]$current.totals.paragraphs / [double]$baseline.totals.paragraphs }
    if ($characterRatio -lt (1 - [double]$Configuration.Policy.maxCharacterChangeRatio)) {
        $issues.Add((New-PBIssue -Severity error -Rule 'baseline-character-regression' -Path ([string]$Configuration.Policy.productRoot) -Message "Character ratio fell to $([Math]::Round($characterRatio, 4))." -Action human))
    }
    if ($paragraphRatio -lt 0.95) {
        $issues.Add((New-PBIssue -Severity error -Rule 'baseline-paragraph-regression' -Path ([string]$Configuration.Policy.productRoot) -Message "Paragraph ratio fell to $([Math]::Round($paragraphRatio, 4))." -Action human))
    }
    if ([int]$current.totals.bookReferences -lt [int]$baseline.totals.bookReferences) {
        $issues.Add((New-PBIssue -Severity error -Rule 'baseline-book-reference-regression' -Path ([string]$Configuration.Policy.productRoot) -Message 'Book-reference count decreased.' -Action human))
    }
    if ([int]$current.totals.wikiLinks -lt [int]$baseline.totals.wikiLinks) {
        $issues.Add((New-PBIssue -Severity error -Rule 'baseline-wiki-link-regression' -Path ([string]$Configuration.Policy.productRoot) -Message 'Wiki-link count decreased.' -Action human))
    }
    if ([int]$current.totals.externalUrls -lt [int]$baseline.totals.externalUrls) {
        $issues.Add((New-PBIssue -Severity error -Rule 'baseline-external-source-regression' -Path ([string]$Configuration.Policy.productRoot) -Message 'External-source URL count decreased.' -Action human))
    }
    if ([int]$current.totals.claimReferences -lt [int]$baseline.totals.claimReferences) {
        $issues.Add((New-PBIssue -Severity error -Rule 'baseline-claim-reference-regression' -Path ([string]$Configuration.Policy.productRoot) -Message 'Claim-reference count decreased.' -Action human))
    }
    return [pscustomobject]@{
        baselineFingerprint = $baseline.fingerprint
        currentFingerprint = $current.fingerprint
        sameFingerprint = ($baseline.fingerprint -eq $current.fingerprint)
        ratios = [ordered]@{ characters = [Math]::Round($characterRatio, 6); paragraphs = [Math]::Round($paragraphRatio, 6) }
        issues = @($issues)
    }
}

function New-PBCandidateId {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$InputObject)
    return (Get-PBObjectHash -InputObject $InputObject).Substring(0, 16)
}

function New-PBRefactorCandidates {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)]$Configuration,
        [switch]$Write
    )

    $issues = [Collections.Generic.List[object]]::new()
    foreach ($issue in Test-PBMarkdownStructure -VaultRoot $VaultRoot -Configuration $Configuration) { $issues.Add($issue) }
    foreach ($issue in Test-PBLocalReferences -VaultRoot $VaultRoot -Configuration $Configuration) { $issues.Add($issue) }
    foreach ($issue in Test-PBClaimLedger -VaultRoot $VaultRoot -Configuration $Configuration) { $issues.Add($issue) }
    foreach ($issue in Test-PBContractSchema -VaultRoot $VaultRoot -Configuration $Configuration) { $issues.Add($issue) }
    foreach ($issue in Test-PBContentQuality -VaultRoot $VaultRoot -Configuration $Configuration) { $issues.Add($issue) }

    $semantic = [Collections.Generic.List[object]]::new()
    $blocked = [Collections.Generic.List[object]]::new()
    foreach ($issue in $issues) {
        $candidate = [ordered]@{
            id = New-PBCandidateId -InputObject ([ordered]@{ rule = $issue.rule; path = $issue.path; line = $issue.line; message = $issue.message })
            rule = $issue.rule
            path = $issue.path
            line = $issue.line
            severity = $issue.severity
            message = $issue.message
            requiredEvidence = if ($issue.rule -like 'claim-*') { 'Confirm usage location or add an explicit claim_id reference.' } else { 'Use the cited file and line; do not invent missing facts.' }
            promotion = 'candidate-only'
        }
        if ($issue.severity -eq 'error' -or $issue.action -eq 'human') { $blocked.Add([pscustomobject]$candidate) }
        elseif ($issue.action -eq 'candidate') { $semantic.Add([pscustomobject]$candidate) }
    }

    $duplicates = [Collections.Generic.List[object]]::new()
    foreach ($duplicate in Get-PBExactDuplicateParagraphs -VaultRoot $VaultRoot -Configuration $Configuration) {
        $entry = [ordered]@{
            id = New-PBCandidateId -InputObject $duplicate
            kind = 'exact-paragraph-duplicate'
            occurrences = @($duplicate.occurrences)
            action = 'Compare context and create a merge candidate; never delete automatically.'
            promotion = 'candidate-only'
        }
        $duplicates.Add([pscustomobject]$entry)
    }

    $payload = [ordered]@{
        schemaVersion = '1.0.0'
        sourceManifest = (New-PBInventoryManifest -VaultRoot $VaultRoot -Configuration $Configuration).fingerprint
        policy = [ordered]@{
            formalWrites = $false
            autoDelete = $false
            autoPublish = $false
            evidencePromotion = $false
        }
        summary = [ordered]@{
            semanticFixes = $semantic.Count
            duplicateGroups = $duplicates.Count
            blocked = $blocked.Count
        }
        semanticFixes = @($semantic | Sort-Object path, line, rule)
        duplicateGroups = @($duplicates | Sort-Object id)
        blocked = @($blocked | Sort-Object path, line, rule)
    }
    $payload.fingerprint = Get-PBObjectHash -InputObject $payload
    $result = [pscustomobject]$payload

    if ($Write) {
        $bufferRoot = Join-PBPath -VaultRoot $VaultRoot -RelativePath ([string]$Configuration.Policy.bufferRoot)
        Write-PBJson -InputObject ([pscustomobject]@{ schemaVersion = '1.0.0'; candidates = $result.semanticFixes }) -Path (Join-Path $bufferRoot 'semantic-fixes/candidates.json')
        Write-PBJson -InputObject ([pscustomobject]@{ schemaVersion = '1.0.0'; candidates = $result.duplicateGroups }) -Path (Join-Path $bufferRoot 'merged-drafts/duplicates.json')
        Write-PBJson -InputObject ([pscustomobject]@{ schemaVersion = '1.0.0'; candidates = $result.blocked }) -Path (Join-Path $bufferRoot 'source-blocked/issues.json')
        Write-PBJson -InputObject $result -Path (Join-Path $bufferRoot 'review-manifest.json')
    }
    return $result
}

function Invoke-PBAuditSuite {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)]$Configuration,
        [switch]$CheckExternal
    )

    $checks = [Collections.Generic.List[object]]::new()
    $checks.Add((New-PBCheckResult -Check 'markdown-structure' -Issues @(Test-PBMarkdownStructure -VaultRoot $VaultRoot -Configuration $Configuration)))
    $checks.Add((New-PBCheckResult -Check 'local-references' -Issues @(Test-PBLocalReferences -VaultRoot $VaultRoot -Configuration $Configuration)))
    $checks.Add((New-PBCheckResult -Check 'claim-ledger' -Issues @(Test-PBClaimLedger -VaultRoot $VaultRoot -Configuration $Configuration)))
    $checks.Add((New-PBCheckResult -Check 'contract-schema' -Issues @(Test-PBContractSchema -VaultRoot $VaultRoot -Configuration $Configuration)))

    $contentIssues = [Collections.Generic.List[object]]::new()
    foreach ($issue in Test-PBContentQuality -VaultRoot $VaultRoot -Configuration $Configuration) { $contentIssues.Add($issue) }
    foreach ($duplicate in Get-PBExactDuplicateParagraphs -VaultRoot $VaultRoot -Configuration $Configuration) {
        $paths = @($duplicate.occurrences | ForEach-Object path) -join ', '
        $contentIssues.Add((New-PBIssue -Severity info -Rule 'quality-exact-duplicate' -Path $duplicate.occurrences[0].path -Message "Exact paragraph appears in: $paths" -Action candidate))
    }
    $checks.Add((New-PBCheckResult -Check 'content-quality' -Issues @($contentIssues)))
    if ($CheckExternal) {
        $checks.Add((New-PBCheckResult -Check 'external-sources' -Issues @(Test-PBExternalSources -VaultRoot $VaultRoot -Configuration $Configuration)))
    }

    $allIssues = @($checks | ForEach-Object issues)
    return [pscustomobject][ordered]@{
        checks = @($checks)
        summary = [ordered]@{
            errors = @($allIssues | Where-Object severity -eq 'error').Count
            warnings = @($allIssues | Where-Object severity -eq 'warning').Count
            info = @($allIssues | Where-Object severity -eq 'info').Count
            total = $allIssues.Count
        }
    }
}

function ConvertTo-PBMarkdownReport {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Report)

    $lines = [Collections.Generic.List[string]]::new()
    $lines.Add('# Personal Baseline Automation Report')
    $lines.Add('')
    $lines.Add("- Mode: ``$($Report.mode)``")
    $lines.Add("- Status: ``$($Report.status)``")
    $lines.Add("- Product version: ``$($Report.productVersion)``")
    $lines.Add("- Content fingerprint: ``$($Report.contentFingerprint)``")
    $lines.Add("- Generated at: $($Report.generatedAt)")
    $lines.Add('')
    $lines.Add('## Summary')
    $lines.Add('')
    $lines.Add('| Errors | Warnings | Info | Safe fixes | Semantic candidates | Blocked candidates |')
    $lines.Add('|---:|---:|---:|---:|---:|---:|')
    $lines.Add("| $($Report.audit.summary.errors) | $($Report.audit.summary.warnings) | $($Report.audit.summary.info) | $($Report.operations.safeFixChanges) | $($Report.operations.semanticCandidates) | $($Report.operations.blockedCandidates) |")
    $lines.Add('')
    $lines.Add('## Checks')
    $lines.Add('')
    $lines.Add('| Check | Errors | Warnings | Info |')
    $lines.Add('|---|---:|---:|---:|')
    foreach ($check in $Report.audit.checks) {
        $lines.Add("| $($check.check) | $($check.summary.errors) | $($check.summary.warnings) | $($check.summary.info) |")
    }
    $lines.Add('')
    $lines.Add('## Baseline')
    $lines.Add('')
    $lines.Add("- Same fingerprint: ``$($Report.baseline.sameFingerprint)``")
    $lines.Add("- Character ratio: ``$($Report.baseline.ratios.characters)``")
    $lines.Add("- Paragraph ratio: ``$($Report.baseline.ratios.paragraphs)``")
    $lines.Add("- Baseline issues: ``$(@($Report.baseline.issues).Count)``")
    $lines.Add('')
    $lines.Add('## Boundaries')
    $lines.Add('')
    $lines.Add('- No external write, publish, delete, pricing, or evidence-promotion action was executed.')
    $lines.Add('- Semantic output remains in `00-缓冲区/自动化候选/`.')
    $lines.Add('- Real run records, source material, the claim ledger, contract schema, and frozen book files remain protected.')
    $lines.Add('')
    $lines.Add('## Issues')
    $lines.Add('')
    $allIssues = @($Report.audit.checks | ForEach-Object issues)
    if ($allIssues.Count -eq 0) {
        $lines.Add('No audit issues.')
    } else {
        $lines.Add('| Severity | Rule | Path | Line | Message |')
        $lines.Add('|---|---|---|---:|---|')
        foreach ($issue in $allIssues) {
            $message = ([string]$issue.message).Replace('|', '\|').Replace("`r", ' ').Replace("`n", ' ')
            $lines.Add("| $($issue.severity) | $($issue.rule) | $($issue.path) | $($issue.line) | $message |")
        }
    }
    return ($lines -join [Environment]::NewLine) + [Environment]::NewLine
}

function Invoke-PBPipeline {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultRoot,
        [Parameter(Mandatory)]$Configuration,
        [Parameter(Mandatory)][ValidateSet('audit','safe-fix','candidate','full-local','verify')][string]$Mode,
        [switch]$CheckExternal,
        [switch]$NoWrite
    )

    $safeModes = $Mode -in @('safe-fix','full-local')
    $candidateModes = $Mode -in @('candidate','full-local')
    $formalSnapshots = @{}
    $safeResult = [pscustomobject]@{ applied = $false; rolledBack = $false; changes = @(); validationIssues = @() }
    $candidateResult = [pscustomobject]@{ summary = [pscustomobject]@{ semanticFixes = 0; duplicateGroups = 0; blocked = 0 }; fingerprint = '' }

    $preAudit = Invoke-PBAuditSuite -VaultRoot $VaultRoot -Configuration $Configuration -CheckExternal:$CheckExternal
    try {
        if ($safeModes -and $preAudit.summary.errors -eq 0) {
            $safePlan = @(Get-PBSafeFixPlan -VaultRoot $VaultRoot -Configuration $Configuration)
            foreach ($change in $safePlan) { $formalSnapshots[$change.fullPath] = [IO.File]::ReadAllBytes($change.fullPath) }
            $safeResult = Invoke-PBSafeFixes -VaultRoot $VaultRoot -Configuration $Configuration -Apply:(-not $NoWrite)
        }
        if ($candidateModes) {
            $candidateResult = New-PBRefactorCandidates -VaultRoot $VaultRoot -Configuration $Configuration -Write:(-not $NoWrite)
        }

        $audit = Invoke-PBAuditSuite -VaultRoot $VaultRoot -Configuration $Configuration -CheckExternal:$CheckExternal
        $baseline = Compare-PBContentBaseline -VaultRoot $VaultRoot -Configuration $Configuration
        $baselineErrors = @($baseline.issues | Where-Object severity -eq 'error')
        $mustRollback = ($safeModes -and -not $NoWrite -and ($audit.summary.errors -gt 0 -or $baselineErrors.Count -gt 0 -or $safeResult.rolledBack))
        if ($mustRollback) {
            foreach ($entry in $formalSnapshots.GetEnumerator()) { [IO.File]::WriteAllBytes($entry.Key, $entry.Value) }
            $safeResult = [pscustomobject]@{ applied = $false; rolledBack = $true; changes = $safeResult.changes; validationIssues = $safeResult.validationIssues }
            $audit = Invoke-PBAuditSuite -VaultRoot $VaultRoot -Configuration $Configuration -CheckExternal:$CheckExternal
            $baseline = Compare-PBContentBaseline -VaultRoot $VaultRoot -Configuration $Configuration
        }

        $inventory = New-PBInventoryManifest -VaultRoot $VaultRoot -Configuration $Configuration
        $status = if ($audit.summary.errors -eq 0 -and @($baseline.issues | Where-Object severity -eq 'error').Count -eq 0 -and -not $safeResult.rolledBack) { 'pass' } else { 'fail' }
        $report = [pscustomobject][ordered]@{
            schemaVersion = '1.0.0'
            generatedAt = (Get-Date).ToString('o')
            mode = $Mode
            status = $status
            productVersion = $inventory.productVersion
            contentFingerprint = $inventory.fingerprint
            audit = $audit
            baseline = $baseline
            operations = [ordered]@{
                safeFixApplied = $safeResult.applied
                safeFixRolledBack = $safeResult.rolledBack
                safeFixChanges = @($safeResult.changes).Count
                semanticCandidates = [int]$candidateResult.summary.semanticFixes
                duplicateCandidates = [int]$candidateResult.summary.duplicateGroups
                blockedCandidates = [int]$candidateResult.summary.blocked
                candidateFingerprint = $candidateResult.fingerprint
            }
            boundaries = [ordered]@{
                externalWrite = $false
                delete = $false
                publish = $false
                pricing = $false
                evidencePromotion = $false
            }
        }

        if (-not $NoWrite) {
            $metadataRoot = Join-PBPath -VaultRoot $VaultRoot -RelativePath ([string]$Configuration.Policy.metadataRoot)
            $reportsRoot = Join-PBPath -VaultRoot $VaultRoot -RelativePath ([string]$Configuration.Policy.reportsRoot)
            Write-PBJson -InputObject $inventory -Path (Join-Path $metadataRoot 'current-manifest.json')
            Write-PBJson -InputObject $report -Path (Join-Path $reportsRoot 'latest-report.json')
            Write-PBTextAtomic -Text (ConvertTo-PBMarkdownReport -Report $report) -Path (Join-Path $reportsRoot 'latest-report.md')
        }
        return $report
    } catch {
        foreach ($entry in $formalSnapshots.GetEnumerator()) { [IO.File]::WriteAllBytes($entry.Key, $entry.Value) }
        throw
    }
}

Export-ModuleMember -Function @(
    'Resolve-PBVaultRoot',
    'ConvertTo-PBRelativePath',
    'Join-PBPath',
    'Read-PBJson',
    'Write-PBJson',
    'Write-PBTextAtomic',
    'Get-PBConfiguration',
    'Get-PBFileRole',
    'Get-PBHash',
    'Get-PBTargetMarkdownFiles',
    'Get-PBFileMetrics',
    'Get-PBProductVersion',
    'Get-PBObjectHash',
    'New-PBInventoryManifest',
    'New-PBIssue',
    'Get-PBLineNumber',
    'Test-PBMarkdownStructure',
    'Test-PBReferenceExists',
    'Test-PBLocalReferences',
    'Get-PBExternalUrlOccurrences',
    'Test-PBExternalSources',
    'Get-PBYamlBlockKeys',
    'Test-PBContractSchema',
    'Get-PBLedgerClaims',
    'Test-PBClaimLedger',
    'Test-PBContentQuality',
    'Get-PBExactDuplicateParagraphs',
    'New-PBCheckResult',
    'Test-PBPathUnderRoot',
    'Test-PBProtectedPath',
    'Test-PBSafeFixAllowed',
    'Convert-PBDeterministicMarkdownFixes',
    'Get-PBSafeFixPlan',
    'Get-PBLocalAuditIssues',
    'Invoke-PBSafeFixes',
    'Compare-PBContentBaseline',
    'New-PBCandidateId',
    'New-PBRefactorCandidates',
    'Invoke-PBAuditSuite',
    'ConvertTo-PBMarkdownReport',
    'Invoke-PBPipeline'
)
