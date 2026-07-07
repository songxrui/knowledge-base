# 生命之书 v2.0 — 视觉资产生成脚本
# 用法: powershell -File .\generate-images.ps1
# 前置条件: bun 1.3+ 已安装，baoyu-image-gen 在 .agents/skills/.archived/ 中

param(
    [string]$Provider = "openai",
    [string]$ImageGenBase = "$env:USERPROFILE\.agents\skills\.archived\baoyu-image-gen"
)

$AssetsDir = Split-Path -Parent $PSCommandPath
$PromptsDir = Join-Path $AssetsDir "prompts"

# 需要生成的图片
$images = @(
    @{ Name = "root-cause-model.png"; Prompt = "root-cause-prompt.md"; AR = "3:2" },
    @{ Name = "6-levers-framework.png"; Prompt = "6-levers-prompt.md"; AR = "16:9" }
)

foreach ($img in $images) {
    $outputPath = Join-Path $AssetsDir $img.Name
    $promptPath = Join-Path $PromptsDir $img.Prompt
    
    Write-Host "🔄 生成: $($img.Name) ..."
    
    if (-not (Test-Path $promptPath)) {
        Write-Host "⚠️  跳过: 提示文件不存在 $promptPath"
        continue
    }
    
    bun (Join-Path $ImageGenBase "scripts/main.ts") `
        --provider $Provider `
        --image $outputPath `
        --promptfiles $promptPath `
        --ar $img.AR 2>&1
    
    if (Test-Path $outputPath) {
        $f = Get-Item $outputPath
        Write-Host "✅  成功: $($img.Name) ($($f.Length) bytes)"
    } else {
        Write-Host "❌  失败: $($img.Name)"
    }
    
    Write-Host ""
}

Write-Host "=== 生成完成 ==="
Write-Host "如需切换 provider，请运行:"
Write-Host "  powershell -File $PSCommandPath -Provider codex-cli"
