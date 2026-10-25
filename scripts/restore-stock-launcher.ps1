<#
.SYNOPSIS
    Restores official Google TV Launcher as default on Xiaomi Mi TV Stick HD.
.DESCRIPTION
    Re-enables the official com.google.android.tvlauncher, sets it as the default
    home activity, and optionally removes Hume Launcher if requested.
.PARAMETER DeviceIP
    The Wi-Fi IP address of your Xiaomi Mi TV Stick (e.g. 192.168.1.141).
#>

[CmdletBinding()]
param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$DeviceIP
)

if ([string]::IsNullOrWhiteSpace($DeviceIP)) {
    $DeviceIP = Read-Host "Enter your Xiaomi Mi TV Stick IP address (e.g. 192.168.1.141)"
}

if ([string]::IsNullOrWhiteSpace($DeviceIP)) {
    Write-Error "Error: No IP address provided. Aborting."
    exit 1
}

$adb = "adb"
if (-not (Get-Command "adb" -ErrorAction SilentlyContinue)) {
    if (Test-Path ".\platform-tools\adb.exe") {
        $adb = ".\platform-tools\adb.exe"
    } elseif (Test-Path "..\platform-tools\adb.exe") {
        $adb = "..\platform-tools\adb.exe"
    } else {
        Write-Error "Error: 'adb' executable not found in PATH or 'platform-tools' directory."
        exit 1
    }
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Restore Official Stock Launcher                         " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Connecting to ${DeviceIP}:5555 via ADB..."

& $adb connect "${DeviceIP}:5555"

# 1. Re-enable stock Google TV launcher
Write-Host "`nRe-enabling stock Google TV launcher..." -ForegroundColor Cyan
$enableStock = (& $adb shell pm enable --user 0 com.google.android.tvlauncher).Trim()
Write-Host "Result: $enableStock" -ForegroundColor Green

# 2. Set stock launcher as default home activity
Write-Host "`nSetting stock launcher as default Home activity..." -ForegroundColor Cyan
$setHome = (& $adb shell cmd package set-home-activity com.google.android.tvlauncher/.MainActivity).Trim()
Write-Host "Result: $setHome" -ForegroundColor Green

# 3. Refresh home screen
& $adb shell input keyevent KEYCODE_HOME

# 4. Optional prompt to uninstall Hume Launcher
$uninstall = Read-Host "`nDo you also want to uninstall Hume Launcher? (y/N)"
if ($uninstall -eq 'y' -or $uninstall -eq 'Y') {
    Write-Host "Uninstalling Hume Launcher..." -ForegroundColor Yellow
    & $adb uninstall com.petrobot.hume
    Write-Host "Hume Launcher uninstalled." -ForegroundColor Green
} else {
    Write-Host "Hume Launcher kept installed as secondary app." -ForegroundColor Cyan
}

Write-Host "`nStock launcher successfully restored!" -ForegroundColor Green
