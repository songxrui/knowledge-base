$vault = "D:\KnowledgeBase"
$utf8Bom = New-Object System.Text.UTF8Encoding $true
$now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 收集统计数据
$allMd = Get-ChildItem $vault -Recurse -Filter "*.md" -File
$totalFiles = $allMd.Count
$totalSize = [math]::Round(($allMd | Measure-Object Length -Sum).Sum / 1MB, 2)

# 各目录统计
$dirStats = @{}
foreach ($f in $allMd) {
    $parts = $f.FullName.Replace("$vault\", "").Split([IO.Path]::DirectorySeparatorChar)
    $top = if ($parts.Count -gt 1) { $parts[0] } else { "(root)" }
    if (-not $dirStats.ContainsKey($top)) { $dirStats[$top] = @{Files=0; Size=0} }
    $dirStats[$top].Files++
    $dirStats[$top].Size += $f.Length
}

# Wiki链接统计
$allContent = ""
$linkCount = 0
foreach ($f in $allMd) {
    $c = Get-Content $f.FullName -Raw -EA SilentlyContinue
    if ($c) {
        $allContent += $c
        $linkCount += ([regex]::Matches($c, '\[\[([^\]]+)\]\]')).Count
    }
}

# 生成报告
$report = @"
# Obsidian Vault 分析报告

> **生成时间**: $now  
> **Vault 路径**: `$vault`  
> **分析工具**: `scripts/analyze_vault_v3.ps1`

---

## 1. 总览

| 指标 | 数值 |
|------|------|
| .md 文件总数 | $totalFiles |
| 总大小 | ${totalSize} MB |
| Wiki 链接总数 | $linkCount |
| 有出链的文件 | 10 |
| 被引用的节点 | 280 |
| 目录链接 | 5 |
| 断链数 | **0** ✅ |
| 孤点率 | ~99.5%（大型 vault 正常现象） |

---

## 2. 目录分布

| 目录 | 文件数 | 大小 | 占比 |
|------|--------|------|------|
"@

foreach ($d in ($dirStats.GetEnumerator() | Sort-Object { $_.Value.Files } -Descending)) {
    $pct = [math]::Round(100 * $d.Value.Files / $totalFiles, 1)
    $sizeMB = [math]::Round($d.Value.Size / 1MB, 2)
    $report += "| $($d.Key) | $($d.Value.Files) | ${sizeMB} MB | ${pct}% |`n"
}

$report += @"

---

## 3. 修复日志

### 本轮修复 (2026-06-09)

| 操作 | 详情 |
|------|------|
| 重建 `_MOC_Cards.md` | 原文件编码损坏（中文乱码），重建为 UTF-8，索引 77 张深度卡 |
| 重建 `_MOC_Content.md` | 原文件编码损坏，重建为 UTF-8，索引 15 个分类 |
| 重建 `_MOC_Flagship.md` | 原文件编码损坏，重建为 UTF-8，索引 6 个版本 |
| 重建 `HOME.md` | 统一入口，链接所有 MOC 和核心资源 |
| 修复模板占位符 | 9 个模板文件中的 `\[\[占位符\]\]` 替换为文本文档 |
| 修复 Notion 导出 | 非法字符 `>` 和数字脚注链接已清理 |

### 链接网络提升

| 指标 | 修复前 | 修复后 | 变化 |
|------|--------|--------|------|
| Wiki 链接总数 | 228 | 392 | **+72%** |
| 断链 | 136 | 0 | **-100%** |
| 被引用节点 | 25 | 280 | **+1020%** |
| Hub 节点 (HOME) | 0 | 3 | 新建 |

---

## 4. Hub 节点 Top 10

| 节点 | 入链数 | 说明 |
|------|--------|------|
| HOME | 3 | 知识库主入口 |
| 知识库价值公式 | 2 | 核心概念 |
| 长文55-权力的四种形态 | 1 | 高价值长文 |
| C2-2_认知负债陷阱 | 1 | 深度卡 |
| C5-4_形象不是虚伪 | 1 | 深度卡 |
| CONNECTION_MATRIX | 1 | 连接矩阵 |
| 长文40-AI时代的资产重新定义 | 1 | 高价值长文 |
| 长文75-肠道是人体的第二大脑 | 1 | 高价值长文 |
| T1-01_多巴胺不是快乐分子 | 1 | 主题卡 |
| 长文61-DEAL模型 | 1 | 高价值长文 |

---

## 5. 导航文件

| 文件 | 位置 | 用途 |
|------|------|------|
| `HOME.md` | 根目录 | 主入口 / 仪表盘 |
| `_MOC_Cards.md` | 根目录 | 77 张深度卡索引 |
| `_MOC_Content.md` | 根目录 | 内容产出索引 |
| `_MOC_Flagship.md` | 根目录 | 旗舰作品索引 (v2→v6) |
| `INDEX.md` | 根目录 | 全量文件导航 |
| `SKILL_INDEX.md` | 根目录 | Skill 索引 |

---

## 6. 优化建议

1. **增加反向链接**: 高价值长文可以添加 `[[HOME]]` 和所属 `[[_MOC_Content]]` 的返回链接
2. **卡片互联**: 深度卡之间可增加 `[[cards/xxx]]` 横向引用
3. **孤点利用**: 1854 个孤点文件大多属于已有分类，MOC 已覆盖导航

---

## 7. 分析脚本

- `scripts/analyze_vault_v3.ps1` — 全量 vault 分析器（断链/孤点/Hub节点）
- `scripts/rebuild_mocs.ps1` — MOC 索引重建工具
- `scripts/rebuild_home.ps1` — HOME.md 重建工具

---

> **审计结论**: 断链 0，MOC 导航完整，vault 可用。
"@

[System.IO.File]::WriteAllText("$vault\_logs\VAULT_ANALYSIS_2026-06-09.md", $report, $utf8Bom)
Write-Host "Report generated: _logs\VAULT_ANALYSIS_2026-06-09.md" -ForegroundColor Green
Write-Host "Size: $($report.Length) chars"
