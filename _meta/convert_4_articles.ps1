$ErrorActionPreference = "Stop"
$htmlDir = "D:\KnowledgeBase\01-内容生产\进行中\html"

$css = @"
body{font-family:Georgia,"Times New Roman","Songti SC","Noto Serif CJK SC",SimSun,serif;font-size:16px;line-height:1.92;color:#242424;max-width:680px;margin:0 auto;padding:34px 24px;background:#fff;}h1{font-size:28px;line-height:1.28;font-weight:700;text-align:left;margin:42px 0 28px;color:#111;}h2{font-size:22px;line-height:1.35;font-weight:700;margin:52px 0 18px;color:#111;}h3{font-size:18px;line-height:1.45;font-weight:700;margin:34px 0 12px;color:#333;}p{margin:15px 0;line-height:1.92;}blockquote{margin:28px 0;padding:0 0 0 22px;border-left:3px solid #242424;color:#444;font-size:17px;line-height:1.86;font-style:italic;}ul{margin:15px 0;padding-left:24px;}li{margin:8px 0;line-height:1.9;}strong{font-weight:800;color:#111;}code{font-family:"SFMono-Regular",Consolas,"Liberation Mono",Menlo,monospace;background:#f2f2f2;color:#222;padding:2px 6px;border-radius:3px;font-size:14px;}pre{background:#f2f2f2;color:#222;padding:14px 16px;overflow:auto;font-size:14px;line-height:1.6;}pre code{background:none;padding:0;}hr{border:none;border-top:1px solid #d8d8d8;margin:40px auto;width:34%;}
"@

function Convert-MDToHTMLBody {
    param([string[]]$lines)
    $html = ""
    $i = 0
    $inList = $false
    while ($i -lt $lines.Count) {
        $line = $lines[$i]
        # Skip empty lines at boundaries
        if ($line -eq "" -and $html -eq "") { $i++; continue }
        
        # ### heading -> h3
        if ($line -match '^### (.+)') {
            if ($inList) { $html += "`n</ul>`n"; $inList = $false }
            $html += "<h3>" + (InlineFormat $matches[1]) + "</h3>`n"
            $i++; continue
        }
        
        # --- -> hr
        if ($line.Trim() -eq "---") {
            if ($inList) { $html += "`n</ul>`n"; $inList = $false }
            $html += "<hr>`n"
            $i++; continue
        }
        
        # Bullet list: "- text" or "* text"
        if ($line -match '^- (.+)' -or $line -match '^\* (.+)') {
            $itemText = if ($matches[1]) { $matches[1] } else { $matches[2] }
            if (-not $inList) { $html += "`n<ul>`n"; $inList = $true }
            $html += "<li>" + (InlineFormat $itemText) + "</li>`n"
            $i++; continue
        }
        
        # Numbered list: "1. text" or "1) text"
        if ($line -match '^\d+[.\)] (.+)') {
            if ($inList) { $html += "`n</ul>`n"; $inList = $false }
            $html += "<p>" + (InlineFormat $line) + "</p>`n"
            $i++; continue
        }
        
        # Blockquote: > text
        if ($line.TrimStart() -match '^> ?(.*)') {
            if ($inList) { $html += "`n</ul>`n"; $inList = $false }
            # Collect multi-line blockquote
            $bqLines = @($matches[1])
            $i++
            while ($i -lt $lines.Count -and $lines[$i].TrimStart() -match '^> ?(.*)') {
                $bqLines += $matches[1]
                $i++
            }
            $bqText = ($bqLines -join "<br>")
            $html += "<blockquote>" + (InlineFormat $bqText) + "</blockquote>`n"
            continue
        }
        
        # Empty line
        if ($line.Trim() -eq "") {
            if ($inList) { $html += "`n</ul>`n"; $inList = $false }
            $html += "`n"
            $i++; continue
        }
        
        # Bold-only line (like **text**)
        if ($line -match '^\*\*(.+)\*\*$') {
            if ($inList) { $html += "`n</ul>`n"; $inList = $false }
            $html += "<p><strong>" + $matches[1] + "</strong></p>`n"
            $i++; continue
        }
        
        # Regular paragraph
        if ($inList) { $html += "`n</ul>`n"; $inList = $false }
        $html += "<p>" + (InlineFormat $line) + "</p>`n"
        $i++
    }
    if ($inList) { $html += "`n</ul>`n" }
    return $html
}

function InlineFormat {
    param([string]$text)
    # **text** -> <strong>text</strong>
    $text = [regex]::Replace($text, '\*\*(.+?)\*\*', '<strong>$1</strong>')
    # `code` -> <code>code</code>
    $text = [regex]::Replace($text, '`([^`]+)`', '<code>$1</code>')
    return $text
}

function Convert-File {
    param([string]$mdPath, [string]$htmlName)
    
    $content = Get-Content $mdPath -Raw -Encoding UTF8
    $lines = $content -split "`r?`n"
    
    # Extract title: first # line
    $title = ""
    $bodyStart = -1
    $bodyEnd = -1
    for ($j = 0; $j -lt $lines.Count; $j++) {
        if ($title -eq "" -and $lines[$j] -match '^# (.+)') {
            $title = $matches[1].Trim()
            # Strip markdown formatting from title for HTML title attribute
            $titleClean = $title -replace '\*\*',''
        }
        if ($lines[$j].Trim() -eq "## 正文") { $bodyStart = $j + 1 }
        if ($lines[$j].Trim() -eq "## 发布信息" -and $bodyEnd -eq -1) { $bodyEnd = $j }
    }
    
    if ($bodyStart -lt 0) {
        # Fallback: find first --- after metadata and use content after it
        $dashCount = 0
        for ($j = 0; $j -lt $lines.Count; $j++) {
            if ($lines[$j].Trim() -eq "---") { 
                $dashCount++
                if ($dashCount -eq 1) { $bodyStart = $j + 1 }
            }
        }
        $bodyEnd = $lines.Count
    }
    if ($bodyEnd -lt 0) { $bodyEnd = $lines.Count }
    
    $bodyLines = $lines[$bodyStart..($bodyEnd - 1)] | Where-Object { $_ -ne $null }
    $bodyHtml = Convert-MDToHTMLBody $bodyLines
    
    $htmlDoc = @"
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>$titleClean - 微信公众号版</title>
<style>
$css
</style>
</head>
<body>

<h1>$title</h1>

$bodyHtml
</body>
</html>
"@
    
    $outPath = Join-Path $htmlDir $htmlName
    [System.IO.File]::WriteAllText($outPath, $htmlDoc, [System.Text.UTF8Encoding]::new($false))
    Write-Host "OK: $outPath ($($bodyLines.Count) lines)"
}

# Convert all 4 files
Convert-File "D:\KnowledgeBase\01-内容生产\进行中\公众号文章_杠铃策略深度版.md" "杠铃策略深度版.html"
Convert-File "D:\KnowledgeBase\01-内容生产\进行中\公众号文章_一人企业的最大卡点.md" "一人企业的最大卡点.html"
Convert-File "D:\KnowledgeBase\01-内容生产\进行中\公众号文章_注意力防火墙.md" "注意力防火墙.html"
Convert-File "D:\KnowledgeBase\01-内容生产\进行中\公众号文章_60天10个反直觉结论.md" "60天10个反直觉结论.html"

Write-Host "`nAll 4 conversions complete."
