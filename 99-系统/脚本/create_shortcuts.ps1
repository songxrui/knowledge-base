$desktop = [Environment]::GetFolderPath('Desktop')
$apps = @{
    'PowerToys' = 'D:\aiapp\powertoys\PowerToys.exe'
    'Flow Launcher' = 'D:\aiapp\flow-launcher\Flow.Launcher.exe'
    'QuickLook' = 'D:\aiapp\quicklook\QuickLook.exe'
    'EarTrumpet' = 'D:\aiapp\eartrumpet\EarTrumpet.exe'
    'Snipaste' = 'D:\aiapp\snipaste\Snipaste.exe'
    'ModernFlyouts' = 'D:\aiapp\modernflyouts\ModernFlyouts.exe'
    'Lively Wallpaper' = 'D:\aiapp\lively\Lively.exe'
    'UniGetUI' = 'D:\aiapp\unigetui\Avalonia\UniGetUI.Avalonia.exe'
    'ScreenToGif' = 'D:\aiapp\screentogif\ScreenToGif.exe'
    'Twinkle Tray' = 'D:\aiapp\twinkle-tray\Twinkle Tray.exe'
    'Bulk Crap Uninstaller' = 'D:\aiapp\bulk-crap-uninstaller\BCUninstaller.exe'
    'TrafficMonitor' = 'D:\aiapp\trafficmonitor\TrafficMonitor.exe'
    'NanaZip' = 'D:\aiapp\nanazip\NanaZip.Modern.FileManager.exe'
    'Rufus' = 'D:\aiapp\rufus\rufus.exe'
    'ImageGlass' = 'D:\aiapp\imageglass\ImageGlass.exe'
    'Gopeed' = 'D:\aiapp\gopeed\gopeed.exe'
    'Auto Dark Mode' = 'D:\aiapp\auto-dark-mode\ui\AutoDarkModeApp.exe'
    'TranslucentTB' = 'D:\aiapp\translucenttb\TranslucentTB.exe'
    'Espanso' = 'D:\aiapp\espanso\espansod.exe'
}
$count = 0
foreach ($name in $apps.Keys) {
    $path = $apps[$name]
    if (Test-Path $path) {
        $shortcut = Join-Path $desktop "$name.lnk"
        $WshShell = New-Object -ComObject WScript.Shell
        $sc = $WshShell.CreateShortcut($shortcut)
        $sc.TargetPath = $path
        $sc.Save()
        $count++
        Write-Host "OK: $name"
    } else {
        Write-Host "MISSING: $name"
    }
}
Write-Host "Done: $count shortcuts on Desktop"
