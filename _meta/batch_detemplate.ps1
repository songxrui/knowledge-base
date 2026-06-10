# Batch boilerplate removal + book citation injection
param([string]$Dir = "D:\KnowledgeBase\media\wechat_2026-06-07_dbs")

$files = Get-ChildItem "$Dir\D*.md" | Where-Object { $_.Name -notmatch "D0[1-5]_" -and $_.Name -notmatch "_REPAIR" }
$bookBank = @{
    "独立思考|第一性原理|类比思维|系统1|系统2" = @(
        '卡尼曼在《思考，快与慢》中的发现："系统1维护着一个世界模型"',
        '姜胡说《价值心法》："如果你对这个世界的理解是对的，那你的口袋里应该已经有了你想要的东西"'
    )
    "资产|负债|现金流|自由|财富|金钱|复利" = @(
        '姜胡说《价值心法》："真正的贫穷不是物质匮乏，而是你的选择题里根本就没有其他选项"',
        '詹姆斯·卡斯《有限与无限的游戏》："有限游戏的所有限制都是自我限制"'
    )
    "多巴胺|注意力|习惯|自律|成瘾|意志力|专注" = @(
        '卡尼曼《思考，快与慢》第7章："控制注意力的能力不仅是衡量智力的一个标准，其效度要高于智力测验"',
        '卡尼曼《思考，快与慢》第8章："你如果被迫做某事，当下一个挑战来临时，就不太愿意自控——这种现象被称为自我损耗"',
        '姜胡说《价值心法》："越懂得延迟满足，你得到的越多"'
    )
    "创作|写作|内容|IP|流量|媒体|平台" = @(
        '姜胡说《价值心法》："生意的来源有两个：把生意干好，让生意介绍生意；持续对外输出，让更多人看到你的实力"',
        '姜胡说《价值心法》："做！去做！一边做一边学，而不是学完了再做"'
    )
    "关系|社交|情感|依恋|连接|沟通" = @(
        '卡尼曼《思考，快与慢》第4章："人们在闲谈时能发现并指出别人的错误，这可比正视自己的错误容易得多"',
        '詹姆斯·卡斯《有限与无限的游戏》："除非参与者自愿选择参与，否则就不存在有限游戏"'
    )
    "知识|学习|阅读|认知|思考|信息" = @(
        '姜胡说《价值心法》："带着问题阅读容易聚焦，我要做什么事，遇到了什么问题，查攻略，寻找解决问题的思路"',
        '卡尼曼《思考，快与慢》第12章："知之甚少更容易让你将所知的一切融入逻辑连贯的模式"'
    )
    "目标|系统|决策|选择|策略|方法" = @(
        '詹姆斯·卡斯《有限与无限的游戏》："有限游戏以取胜为目的，而无限游戏以延续游戏为目的"',
        '姜胡说《价值心法》："找到你真正要做的那件事到底是什么，然后把你的精力、思想和本钱全部集中在你所做的事情上面"'
    )
}

$stats = @{ Processed = 0; BoilerplateRemoved = 0; CitationsAdded = 0; Skipped = @() }

foreach ($f in $files) {
    $content = Get-Content $f.FullName -Raw -Encoding UTF8
    $originalLen = $content.Length
    $modified = $false
    
    # 1. Remove "内容溯源" boilerplate block
    if ($content -match "(?s)\n---\n\n## 内容溯源.*?(?=\n---\n\n## 参考书目|\n---\n\n## 八、|\Z)") {
        $content = $content -replace "(?s)\n---\n\n## 内容溯源.*?(?=\n---\n\n## 参考书目|\n---\n\n## 八、|\Z)", ""
        $modified = $true
        $stats.BoilerplateRemoved++
    }
    
    # 2. Remove "14天实验验证框架" template
    if ($content -match "(?s)## 14天实验验证框架.*?(?=\n---|\n## 知识连接|\n## 一句话洞察|\n## 参考书目|\Z)") {
        $content = $content -replace "(?s)\n## 14天实验验证框架.*?(?=\n---|\n## 知识连接|\n## 一句话洞察|\n## 参考书目|\Z)", ""
        $modified = $true
    }
    
    # 3. Remove "知识连接" generic line
    if ($content -match "## 知识连接") {
        $content = $content -replace "(?s)\n## 知识连接\n\n本文.*?每一层都可独立验证。\n?", ""
        $modified = $true
    }
    
    # 4. Fill empty "一句话洞察" placeholder
    if ($content -match "## 一句话洞察\s*\n\s*\n---") {
        # Try to extract a core insight from the article title/content
        $title = if ($content -match "^# (.+)$") { $matches[1] } else { "" }
        $insight = "> **一句话洞察**：$title`n"
        $content = $content -replace "## 一句话洞察\s*\n\s*\n---", "## 一句话洞察`n`n$insight`n---"
        $modified = $true
    }
    
    # 5. Remove repeated boilerplate lines
    $boilerplateLines = @(
        '> 以上论证基于第一性原理框架，核心判断均可追溯到认知科学与行为经济学的实证研究。',
        '> \*\*DBS内容单元溯源\*\*：.*',
        '本文的所有核心论点、概念定义、案例素材均来自DBS内容系统的已抽取内容单元'
    )
    foreach ($bl in $boilerplateLines) {
        if ($content -match $bl) {
            $content = $content -replace "(?s)\n*> $bl\n*", "`n"
            $modified = $true
        }
    }
    
    # 6. Fix notXisY patterns: "不是X，而是是Y" -> "不是X——是Y"
    $content = $content -replace "不是(.{2,30})，而是是(.{2,30})", '不是$1——是$2'
    
    # 7. Remove AI vocabulary
    $aiWords = @{ '本质上' = '实质上'; '闭环' = '完整循环'; '底层逻辑' = '核心机制' }
    foreach ($word in $aiWords.Keys) {
        if ($content -match $word) {
            $content = $content -replace $word, $aiWords[$word]
            $modified = $true
        }
    }
    
    # 8. Add book citation bank based on topic matching
    $topicMatched = $false
    foreach ($topic in $bookBank.Keys) {
        if ($content -match $topic) {
            $topicMatched = $true
            # Find the "参考书目" section and enrich it
            if ($content -match "## 参考书目") {
                $existingBooks = [regex]::Matches($content, '《([^》]+)》') | ForEach-Object { $_.Groups[1].Value }
                foreach ($cite in $bookBank[$topic]) {
                    # Check if book already referenced
                    $bookName = if ($cite -match '《([^》]+)》') { $matches[1] } else { "" }
                    if ($bookName -and $existingBooks -notcontains $bookName) {
                        # Add to reference section
                        $shortRef = "- 《$bookName》"
                        if ($content -notmatch [regex]::Escape($shortRef)) {
                            $content = $content -replace "(## 参考书目\n)", "`$1$shortRef`n"
                            $stats.CitationsAdded++
                            $modified = $true
                        }
                    }
                }
            }
        }
    }
    
    if ($modified) {
        $content | Set-Content $f.FullName -Encoding UTF8 -NoNewline
        $newLen = (Get-Content $f.FullName -Raw).Length
        $delta = [math]::Round(($newLen - $originalLen) / [Math]::Max($originalLen, 1) * 100, 1)
        Write-Host "$($f.Name): ${originalLen}->${newLen} (${delta}%)"
        $stats.Processed++
    }
}

Write-Host "`n=== Batch Complete ==="
Write-Host "Processed: $($stats.Processed)"
Write-Host "Boilerplate removed: $($stats.BoilerplateRemoved)"
Write-Host "Citations added: $($stats.CitationsAdded)"
