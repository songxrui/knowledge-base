param(
    [string]$Root = "D:\KnowledgeBase",
    [string]$OutputPath = "99-系统\元数据\skills-quick-reference.md"
)

$ErrorActionPreference = "Stop"
$roots = @(
    [pscustomobject]@{ Scope = "project-agents"; Path = (Join-Path $Root ".agents\skills"); Priority = 1 },
    [pscustomobject]@{ Scope = "project-codex"; Path = (Join-Path $Root ".codex\skills"); Priority = 2 },
    [pscustomobject]@{ Scope = "user-agents"; Path = (Join-Path $HOME ".agents\skills"); Priority = 3 },
    [pscustomobject]@{ Scope = "user-codex"; Path = (Join-Path $HOME ".codex\skills"); Priority = 4 }
)

function Get-SkillDescription([string]$skillPath) {
    $lines = Get-Content -LiteralPath $skillPath
    $match = $lines | Select-String -Pattern '^description:\s*(.*)$' | Select-Object -First 1
    if (-not $match) { return "未提供 description" }
    $value = $match.Matches[0].Groups[1].Value.Trim().Trim('"').Trim("'")
    if ($value -and $value -notin @('|', '>')) { return $value }
    $start = $match.LineNumber
    $parts = [Collections.Generic.List[string]]::new()
    for ($index = $start; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -match '^\S' -or $lines[$index] -eq '---') { break }
        $part = $lines[$index].Trim()
        if ($part) { $parts.Add($part) }
    }
    if ($parts.Count -eq 0) { return "未提供 description" }
    return ($parts -join ' ')
}

$candidates = [Collections.Generic.List[object]]::new()
foreach ($entry in $roots) {
    if (-not (Test-Path -LiteralPath $entry.Path)) { continue }
    foreach ($directory in Get-ChildItem -LiteralPath $entry.Path -Directory) {
        $skillPath = Join-Path $directory.FullName "SKILL.md"
        if (-not (Test-Path -LiteralPath $skillPath)) { continue }
        $candidates.Add([pscustomobject]@{
            Name = $directory.Name
            Scope = $entry.Scope
            Priority = $entry.Priority
            Path = $skillPath
            Description = Get-SkillDescription $skillPath
        })
    }
}

$skills = @($candidates | Sort-Object Priority, Name | Group-Object { $_.Name.ToLowerInvariant() } | ForEach-Object { $_.Group | Select-Object -First 1 } | Sort-Object Name)
$lines = [Collections.Generic.List[string]]::new()
$lines.Add("---")
$lines.Add("status: generated")
$lines.Add("canonical: true")
$lines.Add("generated: true")
$lines.Add("updated_at: " + (Get-Date -Format "yyyy-MM-dd"))
$lines.Add("---")
$lines.Add("")
$lines.Add("# Skills 快捷手册")
$lines.Add("")
$lines.Add("> 由 ``99-系统/脚本/build_skills_quick_reference.ps1`` 从当前实际技能目录生成。不要手工维护技能数量或列表。")
$lines.Add("")
$lines.Add("## 使用与维护规则")
$lines.Add("")
$lines.Add("- 先读目标 Skill 的 ``SKILL.md``，不要根据旧记忆推断流程。")
$lines.Add("- Skill 负责程序性知识；外部 API、持久工具和第三方动作使用对应工具并遵守审批边界。")
$lines.Add("- 修改 Skill 时先定义触发边界、输入、步骤、输出和验证，再检查是否与现有 Skill 重复。")
$lines.Add("- 文档中的固定数量只代表生成时快照；当前数量以重新运行脚本为准。")
$lines.Add("")
$lines.Add("## 当前清单")
$lines.Add("")
$lines.Add("生成时发现 **" + $skills.Count + "** 个去重后的可用 Skill。项目级同名 Skill 优先于用户级 Skill。")
$lines.Add("")
$lines.Add("| Skill | 作用 | 来源 | SKILL.md |")
$lines.Add("|---|---|---|---|")
foreach ($skill in $skills) {
    $description = ($skill.Description -replace '\|', '\|' -replace '\s+', ' ').Trim()
    if ($description.Length -gt 180) { $description = $description.Substring(0, 177) + "..." }
    $relative = if ($skill.Path.StartsWith($Root, [StringComparison]::OrdinalIgnoreCase)) {
        $skill.Path.Substring($Root.TrimEnd('\').Length + 1).Replace('\', '/')
    } else {
        $skill.Path.Replace('\', '/')
    }
    $lines.Add("| ``" + $skill.Name + "`` | " + $description + " | " + $skill.Scope + " | ``" + $relative + "`` |")
}

$output = if ([IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { Join-Path $Root $OutputPath }
[IO.File]::WriteAllLines($output, $lines, [Text.UTF8Encoding]::new($false))
Write-Output ("Skills=" + $skills.Count)
Write-Output ("Output=" + $output)
