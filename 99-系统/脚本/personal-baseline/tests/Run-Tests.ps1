[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$scriptRoot = Split-Path -Parent $PSScriptRoot
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $scriptRoot '..\..\..')).Path
$modulePath = Join-Path $scriptRoot 'PersonalBaseline.Automation.psm1'
$inventoryScript = Join-Path $scriptRoot 'Get-PersonalBaselineInventory.ps1'
$configurationSource = Join-Path $repositoryRoot '99-系统\元数据\personal-baseline'
$temporaryPrefix = 'PB-Automation-'
$fixtures = [Collections.Generic.List[string]]::new()
$results = [Collections.Generic.List[object]]::new()

Import-Module $modulePath -Force

function Write-TestText {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][AllowEmptyString()][string]$Text,
        [switch]$Bom
    )

    $directory = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    [IO.File]::WriteAllText($Path, $Text, [Text.UTF8Encoding]::new([bool]$Bom))
}

function Get-ContractBlock {
    return @'
```yaml
contract_version: v1
target_decision:
state_vector:
  K: 未知 | 暂不足 | 当前足够
  A: 未知 | 暂不足 | 当前足够
  P: 未知 | 暂不足 | 当前足够
  R: 未知 | 暂不足 | 当前足够
  E: 未知 | 暂不足 | 当前足够
  F: 未知 | 暂不足 | 当前足够
  Q: 未知 | 暂不足 | 当前足够
  H: 未知 | 暂不足 | 当前足够
focus_state: K | A | P | R | E | F | Q | H
activity_type: 探索 | 有界学习 | 基础设施 | 约束测试 | 可撤回进展
unique_activity:
planned_context:
start_definition:
completion_evidence:
contact_mode: direct | simulated | supervised
result_space:
timebox_minutes: 1-20
expected_opportunities:
risk_cap_and_third_party:
stop_condition:
supporter:
update_threshold:
leading_hypothesis:
competing_explanation:
review_date:
```
'@
}

function New-TestFixture {
    $root = Join-Path ([IO.Path]::GetTempPath()) ($temporaryPrefix + [guid]::NewGuid().ToString('N'))
    $fixtures.Add($root)
    New-Item -ItemType Directory -Path (Join-Path $root '.git') -Force | Out-Null

    $configurationTarget = Join-Path $root '99-系统\元数据\personal-baseline'
    New-Item -ItemType Directory -Path $configurationTarget -Force | Out-Null
    foreach ($name in @('policy.json','path-allowlist.json','protected-paths.json','contract-schema.json','claim-schema.json','quality-rules.json')) {
        Copy-Item -LiteralPath (Join-Path $configurationSource $name) -Destination (Join-Path $configurationTarget $name)
    }

    $productRoot = Join-Path $root '08-媒体与产品\产品\个人基线'
    Write-TestText -Path (Join-Path $productRoot 'SOURCE_OF_TRUTH.md') -Text @'
# 产品事实源

当前产品版本：`0.0.0-test`
'@
    Write-TestText -Path (Join-Path $productRoot 'README.md') -Text @'
# 最小产品

正文使用主张 DK-001，并保持证据与应用分离。[[03-实践协议/00-接口选择表]]
'@
    Write-TestText -Path (Join-Path $productRoot '03-实践协议\00-接口选择表.md') -Text ("# 接口选择表`r`n`r`n" + (Get-ContractBlock))

    $runTemplate = @'
# 运行模板

```yaml
run_id: RUN-YYYYMMDD-test
status: planned
start_date:
review_date:
contract_version: v1
target_decision:
state_vector:
  K: 未知 | 暂不足 | 当前足够
  A: 未知 | 暂不足 | 当前足够
  P: 未知 | 暂不足 | 当前足够
  R: 未知 | 暂不足 | 当前足够
  E: 未知 | 暂不足 | 当前足够
  F: 未知 | 暂不足 | 当前足够
  Q: 未知 | 暂不足 | 当前足够
  H: 未知 | 暂不足 | 当前足够
focus_state: K | A | P | R | E | F | Q | H
activity_type: 探索 | 有界学习 | 基础设施 | 约束测试 | 可撤回进展
unique_activity:
planned_context:
start_definition:
completion_evidence:
contact_mode: direct | simulated | supervised
result_space:
timebox_minutes: 1-20
expected_opportunities:
risk_cap_and_third_party:
stop_condition:
supporter:
update_threshold:
leading_hypothesis:
competing_explanation:
```
'@
    Write-TestText -Path (Join-Path $productRoot '04-运行记录\00-回填模板.md') -Text $runTemplate

    $decisions = '保持 修订 有界学习 补资源 修测量 退出 寻求支持'
    Write-TestText -Path (Join-Path $productRoot '03-实践协议\02-每日记录表.md') -Text ("# 每日记录`r`n`r`n下一决定：$decisions`r`n")
    Write-TestText -Path (Join-Path $productRoot '03-实践协议\03-第七天复盘表.md') -Text ("# 第七天复盘`r`n`r`n下一决定：$decisions`r`n")
    Write-TestText -Path (Join-Path $productRoot '04-运行记录\README.md') -Text @'
# 运行记录

状态：planned、running、completed、stopped、invalid。
'@
    Write-TestText -Path (Join-Path $productRoot '90-内部治理\01-主张与来源台账.md') -Text @'
# 主张与来源台账

| claim_id | 主张 | 等级/状态 | 精确来源 | 边界 | 使用位置 |
|---|---|---|---|---|---|
| `DK-001` | 测试主张 | `E2 author-method` | [Source](https://example.com/source#method) | 只用于测试 | README |
'@
    Write-TestText -Path (Join-Path $root '03-资源\创作者素材\Dan-Koe\README.md') -Text @'
# Dan Koe 测试来源

仅用于本地自动化测试。
'@

    $configuration = Get-PBConfiguration -VaultRoot $root
    $manifest = New-PBInventoryManifest -VaultRoot $root -Configuration $configuration
    Write-PBJson -InputObject $manifest -Path (Join-Path $configurationTarget 'baseline-manifest.json')
    Write-PBJson -InputObject $manifest -Path (Join-Path $configurationTarget 'current-manifest.json')
    return [pscustomobject]@{
        Root = $root
        ProductRoot = $productRoot
        Configuration = $configuration
    }
}

function Assert-True {
    param(
        [Parameter(Mandatory)][bool]$Condition,
        [Parameter(Mandatory)][string]$Message
    )

    if (-not $Condition) { throw $Message }
}

function Assert-Equal {
    param(
        $Actual,
        $Expected,
        [Parameter(Mandatory)][string]$Message
    )

    if ($Actual -ne $Expected) {
        throw "$Message Expected=[$Expected] Actual=[$Actual]"
    }
}

function Invoke-AutomationTest {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][scriptblock]$Body
    )

    $started = Get-Date
    try {
        & $Body
        $elapsed = [Math]::Round(((Get-Date) - $started).TotalMilliseconds)
        $results.Add([pscustomobject]@{ Name = $Name; Status = 'PASS'; Milliseconds = $elapsed; Error = '' })
        Write-Host "PASS $Name ($elapsed ms)"
    } catch {
        $elapsed = [Math]::Round(((Get-Date) - $started).TotalMilliseconds)
        $results.Add([pscustomobject]@{ Name = $Name; Status = 'FAIL'; Milliseconds = $elapsed; Error = $_.Exception.Message })
        Write-Host "FAIL $Name - $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Remove-TestFixture {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) { return }
    $fullPath = [IO.Path]::GetFullPath($Path).TrimEnd([IO.Path]::DirectorySeparatorChar)
    $tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd([IO.Path]::DirectorySeparatorChar)
    $prefix = $tempRoot + [IO.Path]::DirectorySeparatorChar
    $leaf = Split-Path -Leaf $fullPath
    if (-not $fullPath.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase) -or -not $leaf.StartsWith($temporaryPrefix, [StringComparison]::Ordinal)) {
        throw "Refusing to remove unverified test path: $fullPath"
    }
    Remove-Item -LiteralPath $fullPath -Recurse -Force
}

try {
    Invoke-AutomationTest -Name 'inventory is deterministic' -Body {
        $fixture = New-TestFixture
        $first = New-PBInventoryManifest -VaultRoot $fixture.Root -Configuration $fixture.Configuration
        $second = New-PBInventoryManifest -VaultRoot $fixture.Root -Configuration $fixture.Configuration
        Assert-Equal -Actual $first.fingerprint -Expected $second.fingerprint -Message 'Inventory fingerprint changed without content changes.'
        Assert-True -Condition ($first.totals.files -ge 9) -Message 'Fixture inventory omitted required files.'
        $baseline = Compare-PBContentBaseline -VaultRoot $fixture.Root -Configuration $fixture.Configuration
        Assert-True -Condition $baseline.sameFingerprint -Message 'Fresh fixture does not match its baseline.'
    }

    Invoke-AutomationTest -Name 'inventory paths cannot escape write scope' -Body {
        $fixture = New-TestFixture
        $joinRejected = $false
        try { Join-PBPath -VaultRoot $fixture.Root -RelativePath '../escape.json' | Out-Null }
        catch { $joinRejected = $true }
        Assert-True -Condition $joinRejected -Message 'Vault-relative path escape was accepted.'

        $outsideMetadata = Join-Path $fixture.ProductRoot 'inventory.json'
        $outputRejected = $false
        try { & $inventoryScript -VaultRoot $fixture.Root -OutputPath $outsideMetadata | Out-Null }
        catch { $outputRejected = $true }
        Assert-True -Condition $outputRejected -Message 'Inventory output outside metadata root was accepted.'
        Assert-True -Condition (-not (Test-Path -LiteralPath $outsideMetadata)) -Message 'Rejected inventory output was written.'
    }

    Invoke-AutomationTest -Name 'protected path matrix denies safe fixes' -Body {
        $fixture = New-TestFixture
        $paths = @(
            '08-媒体与产品/产品/个人基线/SOURCE_OF_TRUTH.md',
            '08-媒体与产品/产品/个人基线/03-实践协议/00-接口选择表.md',
            '08-媒体与产品/产品/个人基线/04-运行记录/RUN-20260716-test.md',
            '08-媒体与产品/产品/个人基线/90-内部治理/01-主张与来源台账.md',
            '03-资源/创作者素材/Dan-Koe/source.md',
            '08-媒体与产品/媒体/flagship/book-v7/chapter.md',
            '01-项目/知行转化研究/research.md'
        )
        foreach ($path in $paths) {
            Assert-True -Condition (Test-PBProtectedPath -RelativePath $path -Configuration $fixture.Configuration) -Message "Protected path was not recognized: $path"
            Assert-True -Condition (-not (Test-PBSafeFixAllowed -RelativePath $path -Configuration $fixture.Configuration)) -Message "Protected path entered safe-fix scope: $path"
        }
    }

    Invoke-AutomationTest -Name 'baseline detects reference regressions' -Body {
        $fixture = New-TestFixture
        $readme = Join-Path $fixture.ProductRoot 'README.md'
        $readmeText = [IO.File]::ReadAllText($readme).Replace('DK-001', 'the registered claim').Replace('[[03-实践协议/00-接口选择表]]', '')
        Write-TestText -Path $readme -Text $readmeText
        $ledger = Join-Path $fixture.ProductRoot '90-内部治理\01-主张与来源台账.md'
        $ledgerText = [IO.File]::ReadAllText($ledger).Replace('https://example.com/source#method', 'local-source')
        Write-TestText -Path $ledger -Text $ledgerText

        $comparison = Compare-PBContentBaseline -VaultRoot $fixture.Root -Configuration $fixture.Configuration
        $rules = @($comparison.issues | ForEach-Object rule)
        foreach ($rule in @('baseline-wiki-link-regression','baseline-external-source-regression','baseline-claim-reference-regression')) {
            Assert-True -Condition ($rule -in $rules) -Message "Baseline regression rule was not detected: $rule"
        }
    }

    Invoke-AutomationTest -Name 'structure audit detects deterministic defects' -Body {
        $fixture = New-TestFixture
        $path = Join-Path $fixture.ProductRoot 'structure-defects.md'
        $text = "# Structure`r`n`r`n### Jump`r`n`r`n| A | B |`r`n|---|`r`nline`t`r`n" + '```text' + "`r`nunclosed"
        Write-TestText -Path $path -Text $text -Bom
        $issues = @(Test-PBMarkdownStructure -VaultRoot $fixture.Root -Configuration $fixture.Configuration)
        foreach ($rule in @('markdown-bom','markdown-heading-jump','markdown-table-columns','markdown-trailing-whitespace','markdown-unclosed-fence')) {
            Assert-True -Condition ($rule -in @($issues.rule)) -Message "Structure rule was not detected: $rule"
        }
    }

    Invoke-AutomationTest -Name 'local reference audit detects broken wiki link' -Body {
        $fixture = New-TestFixture
        $readme = Join-Path $fixture.ProductRoot 'README.md'
        [IO.File]::AppendAllText($readme, "`r`n[[missing-note]]`r`n", [Text.UTF8Encoding]::new($false))
        $issues = @(Test-PBLocalReferences -VaultRoot $fixture.Root -Configuration $fixture.Configuration)
        Assert-True -Condition ('reference-broken-wiki' -in @($issues.rule)) -Message 'Broken wiki link was not detected.'
    }

    Invoke-AutomationTest -Name 'claim ledger detects duplicates and missing IDs' -Body {
        $fixture = New-TestFixture
        $ledger = Join-Path $fixture.ProductRoot '90-内部治理\01-主张与来源台账.md'
        [IO.File]::AppendAllText($ledger, "`r`n| ``DK-001`` | duplicate | ``E2 author-method`` | source | boundary | usage |`r`n", [Text.UTF8Encoding]::new($false))
        $readme = Join-Path $fixture.ProductRoot 'README.md'
        [IO.File]::AppendAllText($readme, "`r`nPB-999`r`n", [Text.UTF8Encoding]::new($false))
        $issues = @(Test-PBClaimLedger -VaultRoot $fixture.Root -Configuration $fixture.Configuration)
        Assert-True -Condition ('claim-duplicate-id' -in @($issues.rule)) -Message 'Duplicate claim ID was not detected.'
        Assert-True -Condition ('claim-reference-missing' -in @($issues.rule)) -Message 'Missing claim ID was not detected.'
    }

    Invoke-AutomationTest -Name 'contract schema detects missing field' -Body {
        $fixture = New-TestFixture
        $initial = @(Test-PBContractSchema -VaultRoot $fixture.Root -Configuration $fixture.Configuration)
        Assert-Equal -Actual @($initial | Where-Object severity -eq 'error').Count -Expected 0 -Message 'Valid contract fixture failed.'
        $canonical = Join-Path $fixture.ProductRoot '03-实践协议\00-接口选择表.md'
        $text = [regex]::Replace([IO.File]::ReadAllText($canonical), '(?m)^competing_explanation:\r?\n', '')
        Write-TestText -Path $canonical -Text $text
        $issues = @(Test-PBContractSchema -VaultRoot $fixture.Root -Configuration $fixture.Configuration)
        Assert-True -Condition ('contract-canonical-field' -in @($issues | ForEach-Object rule)) -Message 'Missing contract field was not detected.'
    }

    Invoke-AutomationTest -Name 'content quality flags prose but skips code fences' -Body {
        $fixture = New-TestFixture
        $qualityPath = Join-Path $fixture.ProductRoot 'quality-defects.md'
        $codeBlock = '```text' + "`r`nTODO inside code`r`n" + '```'
        $qualityText = "# Quality defects`r`n`r`n$codeBlock`r`n`r`nTODO outside code`r`n我的客户都获得了结果。`r`n所有人都会成功。`r`n保证收入。`r`n"
        Write-TestText -Path $qualityPath -Text $qualityText
        $issues = @(Test-PBContentQuality -VaultRoot $fixture.Root -Configuration $fixture.Configuration)
        $rules = @($issues | ForEach-Object rule)
        foreach ($rule in @('quality-scaffold','quality-fabrication-signal','quality-overclaim','quality-high-risk-unqualified')) {
            Assert-True -Condition ($rule -in $rules) -Message "Content-quality rule was not detected: $rule"
        }
        Assert-Equal -Actual @($issues | Where-Object rule -eq 'quality-scaffold').Count -Expected 1 -Message 'Code-fence scaffold marker was incorrectly flagged.'
    }

    Invoke-AutomationTest -Name 'external timeout is classified without aborting' -Body {
        $fixture = New-TestFixture
        $listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 0)
        $listener.Start()
        try {
            $port = ([Net.IPEndPoint]$listener.LocalEndpoint).Port
            $ledger = Join-Path $fixture.ProductRoot '90-内部治理\01-主张与来源台账.md'
            $text = [IO.File]::ReadAllText($ledger).Replace('https://example.com/source#method', "http://127.0.0.1:$port/source")
            Write-TestText -Path $ledger -Text $text
            $fixture.Configuration.Policy.networkTimeoutSeconds = 1
            $issues = @(Test-PBExternalSources -VaultRoot $fixture.Root -Configuration $fixture.Configuration -MaxUrls 1)
            Assert-Equal -Actual $issues.Count -Expected 1 -Message 'Timeout test returned an unexpected issue count.'
            Assert-Equal -Actual $issues[0].rule -Expected 'external-timeout' -Message 'Timeout was not classified correctly.'
            Assert-Equal -Actual $issues[0].severity -Expected 'warning' -Message 'Timeout severity is incorrect.'
        } finally {
            $listener.Stop()
        }
    }

    Invoke-AutomationTest -Name 'safe fixes apply once and preserve protected files' -Body {
        $fixture = New-TestFixture
        $note = Join-Path $fixture.ProductRoot 'safe-fix.md'
        $filler = ('This paragraph keeps the ratio below the safety threshold. ' * 8)
        $codeBlock = '```text' + "`r`ncode`t`r`n" + '```'
        Write-TestText -Path $note -Text ("# Safe fix`r`n`r`n$filler`r`n`r`nline`t`r`n`r`n| A | B |`r`n|---|`r`n`r`n$codeBlock`r`n") -Bom
        $protected = Join-Path $fixture.ProductRoot 'SOURCE_OF_TRUTH.md'
        [IO.File]::AppendAllText($protected, "protected`t`r`n", [Text.UTF8Encoding]::new($false))
        $protectedHash = Get-PBHash -Path $protected

        $plan = @(Get-PBSafeFixPlan -VaultRoot $fixture.Root -Configuration $fixture.Configuration)
        Assert-Equal -Actual $plan.Count -Expected 1 -Message 'Safe-fix plan should contain only the unprotected note.'
        Assert-Equal -Actual $plan[0].path -Expected '08-媒体与产品/产品/个人基线/safe-fix.md' -Message 'Unexpected file entered safe-fix plan.'
        foreach ($action in @('remove-utf8-bom','remove-trailing-whitespace','repair-table-separator')) {
            Assert-True -Condition ($action -in @($plan[0].actions)) -Message "Safe-fix action missing: $action"
        }

        $result = Invoke-PBSafeFixes -VaultRoot $fixture.Root -Configuration $fixture.Configuration -Apply
        Assert-True -Condition $result.applied -Message 'Safe fixes were not applied.'
        Assert-True -Condition (-not $result.rolledBack) -Message 'Valid safe fixes were rolled back.'
        Assert-Equal -Actual (Get-PBHash -Path $protected) -Expected $protectedHash -Message 'Protected file was modified.'
        Assert-Equal -Actual @(Get-PBSafeFixPlan -VaultRoot $fixture.Root -Configuration $fixture.Configuration).Count -Expected 0 -Message 'Safe fixes are not idempotent.'
        $bytes = [IO.File]::ReadAllBytes($note)
        Assert-True -Condition (-not ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)) -Message 'UTF-8 BOM remains after safe fix.'
        $fixedText = [IO.File]::ReadAllText($note)
        Assert-True -Condition $fixedText.Contains('|---|---|') -Message 'Table separator was not repaired.'
        Assert-True -Condition $fixedText.Contains("code`t") -Message 'Safe fix changed trailing whitespace inside a code fence.'
    }

    Invoke-AutomationTest -Name 'post-audit failure rolls safe fixes back' -Body {
        $fixture = New-TestFixture
        $note = Join-Path $fixture.ProductRoot 'rollback.md'
        $filler = ('Rollback verification content remains unchanged after failure. ' * 8)
        Write-TestText -Path $note -Text ("# Rollback`r`n`r`n$filler`r`n`r`nline`t`r`n")
        $beforeHash = Get-PBHash -Path $note
        $canonical = Join-Path $fixture.ProductRoot '03-实践协议\00-接口选择表.md'
        $text = [regex]::Replace([IO.File]::ReadAllText($canonical), '(?m)^competing_explanation:\r?\n', '')
        Write-TestText -Path $canonical -Text $text

        $result = Invoke-PBSafeFixes -VaultRoot $fixture.Root -Configuration $fixture.Configuration -Apply
        Assert-True -Condition $result.rolledBack -Message 'Post-audit failure did not trigger rollback.'
        Assert-True -Condition (-not $result.applied) -Message 'Rolled-back result is incorrectly marked applied.'
        Assert-Equal -Actual (Get-PBHash -Path $note) -Expected $beforeHash -Message 'Rollback did not restore original bytes.'
        Assert-True -Condition ('contract-canonical-field' -in @($result.validationIssues.rule)) -Message 'Rollback reason was not retained.'
    }

    Invoke-AutomationTest -Name 'candidate output remains isolated and deterministic' -Body {
        $fixture = New-TestFixture
        $ledger = Join-Path $fixture.ProductRoot '90-内部治理\01-主张与来源台账.md'
        [IO.File]::AppendAllText($ledger, "`r`n| ``PB-001`` | candidate | ``E3 product-hypothesis`` | local | boundary | none |`r`n", [Text.UTF8Encoding]::new($false))
        $before = New-PBInventoryManifest -VaultRoot $fixture.Root -Configuration $fixture.Configuration
        $first = New-PBRefactorCandidates -VaultRoot $fixture.Root -Configuration $fixture.Configuration -Write
        $second = New-PBRefactorCandidates -VaultRoot $fixture.Root -Configuration $fixture.Configuration
        $after = New-PBInventoryManifest -VaultRoot $fixture.Root -Configuration $fixture.Configuration

        Assert-Equal -Actual $first.fingerprint -Expected $second.fingerprint -Message 'Candidate fingerprint is not deterministic.'
        Assert-Equal -Actual $before.fingerprint -Expected $after.fingerprint -Message 'Candidate generation changed formal content.'
        Assert-Equal -Actual $first.summary.semanticFixes -Expected 1 -Message 'Orphan claim candidate count is incorrect.'
        $reviewManifest = Join-Path $fixture.ProductRoot '00-缓冲区\自动化候选\review-manifest.json'
        Assert-True -Condition (Test-Path -LiteralPath $reviewManifest -PathType Leaf) -Message 'Candidate review manifest was not written to the buffer.'
    }

    Invoke-AutomationTest -Name 'forced baseline reset archives prior manifest' -Body {
        $fixture = New-TestFixture
        $baselinePath = Join-Path $fixture.Root '99-系统\元数据\personal-baseline\baseline-manifest.json'
        $oldBaseline = Read-PBJson -Path $baselinePath
        $readme = Join-Path $fixture.ProductRoot 'README.md'
        [IO.File]::AppendAllText($readme, "`r`nIntentional baseline change.`r`n", [Text.UTF8Encoding]::new($false))

        $raw = & $inventoryScript -VaultRoot $fixture.Root -InitializeBaseline -Force -AsJson | Out-String
        $newBaseline = $raw | ConvertFrom-Json -Depth 50
        $archiveName = "$($oldBaseline.productVersion)-$($oldBaseline.fingerprint).json"
        $archivePath = Join-Path $fixture.Root "99-系统\元数据\personal-baseline\baselines\$archiveName"
        Assert-True -Condition (Test-Path -LiteralPath $archivePath -PathType Leaf) -Message 'Prior baseline was not archived.'
        $archived = Read-PBJson -Path $archivePath
        Assert-Equal -Actual $archived.fingerprint -Expected $oldBaseline.fingerprint -Message 'Archived baseline fingerprint changed.'
        Assert-True -Condition ($newBaseline.fingerprint -ne $oldBaseline.fingerprint) -Message 'Forced baseline reset did not capture the intentional change.'
        $currentBaseline = Read-PBJson -Path $baselinePath
        Assert-Equal -Actual $currentBaseline.fingerprint -Expected $newBaseline.fingerprint -Message 'Baseline file was not updated after archival.'
    }

    Invoke-AutomationTest -Name 'full pipeline is repeatable and respects no-write' -Body {
        $noWriteFixture = New-TestFixture
        $noWriteReport = Invoke-PBPipeline -VaultRoot $noWriteFixture.Root -Configuration $noWriteFixture.Configuration -Mode full-local -NoWrite
        Assert-Equal -Actual $noWriteReport.status -Expected 'pass' -Message 'No-write pipeline failed.'
        $noWriteReportPath = Join-Path $noWriteFixture.Root '99-系统\元数据\personal-baseline\reports\latest-report.json'
        Assert-True -Condition (-not (Test-Path -LiteralPath $noWriteReportPath)) -Message 'No-write pipeline created a report.'

        $fixture = New-TestFixture
        $before = New-PBInventoryManifest -VaultRoot $fixture.Root -Configuration $fixture.Configuration
        $first = Invoke-PBPipeline -VaultRoot $fixture.Root -Configuration $fixture.Configuration -Mode full-local
        $second = Invoke-PBPipeline -VaultRoot $fixture.Root -Configuration $fixture.Configuration -Mode full-local
        $after = New-PBInventoryManifest -VaultRoot $fixture.Root -Configuration $fixture.Configuration

        Assert-Equal -Actual $first.status -Expected 'pass' -Message 'First full pipeline run failed.'
        Assert-Equal -Actual $second.status -Expected 'pass' -Message 'Second full pipeline run failed.'
        Assert-Equal -Actual $first.operations.candidateFingerprint -Expected $second.operations.candidateFingerprint -Message 'Pipeline candidate fingerprint changed.'
        Assert-Equal -Actual $before.fingerprint -Expected $after.fingerprint -Message 'Full pipeline changed formal content unexpectedly.'
        Assert-True -Condition (-not $second.boundaries.externalWrite -and -not $second.boundaries.delete -and -not $second.boundaries.publish) -Message 'Pipeline boundary report is unsafe.'
        foreach ($relative in @(
            '99-系统\元数据\personal-baseline\current-manifest.json',
            '99-系统\元数据\personal-baseline\reports\latest-report.json',
            '99-系统\元数据\personal-baseline\reports\latest-report.md',
            '08-媒体与产品\产品\个人基线\00-缓冲区\自动化候选\review-manifest.json'
        )) {
            Assert-True -Condition (Test-Path -LiteralPath (Join-Path $fixture.Root $relative) -PathType Leaf) -Message "Pipeline output is missing: $relative"
        }
    }
} finally {
    foreach ($fixturePath in $fixtures) {
        try { Remove-TestFixture -Path $fixturePath }
        catch { Write-Warning $_.Exception.Message }
    }
}

$passed = @($results | Where-Object Status -eq 'PASS').Count
$failed = @($results | Where-Object Status -eq 'FAIL').Count
Write-Host "`nTests: $($results.Count), Passed: $passed, Failed: $failed"
if ($failed -gt 0) {
    $results | Where-Object Status -eq 'FAIL' | Format-Table Name, Error -Wrap -AutoSize
    exit 1
}
