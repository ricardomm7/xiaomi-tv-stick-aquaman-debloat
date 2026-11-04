<#
.SYNOPSIS
    Installs and sets Hume Launcher as default on Xiaomi Mi TV Stick HD (Android TV 9).
.DESCRIPTION
    Downloads the official lightweight, ad-free Hume Launcher (tvOS style) from GitHub,
    installs it via ADB, sets it as the default home activity, and safely disables
    the stock Google TV launcher without uninstalling it.
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
Write-Host "  Install & Set Hume Launcher as Default                  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Connecting to ${DeviceIP}:5555 via ADB..."

& $adb connect "${DeviceIP}:5555"

# Check if Hume is already installed
$installed = (& $adb shell pm list packages | Select-String "com.petrobot.hume")

if (-not $installed) {
    $apkUrl = "https://github.com/petrobot-admin/hume-launcher/releases/download/v7.8/HumeLauncher-7.8.apk"
    $tempApk = Join-Path $env:TEMP "HumeLauncher-7.8.apk"
    Write-Host "Downloading Hume Launcher v7.8 from official GitHub release..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $apkUrl -OutFile $tempApk
    
    Write-Host "Installing Hume Launcher on TV Stick..." -ForegroundColor Yellow
    & $adb install -r $tempApk
    Remove-Item -Force $tempApk -ErrorAction SilentlyContinue
} else {
    Write-Host "Hume Launcher is already installed." -ForegroundColor Green
}

# 1. Set Hume Launcher as default home activity
Write-Host "`nSetting Hume Launcher as default Home activity..." -ForegroundColor Cyan
$setHome = (& $adb shell cmd package set-home-activity com.petrobot.hume/.MainActivity).Trim()
Write-Host "Result: $setHome" -ForegroundColor Green

# 2. Safely disable stock Google TV launcher (without uninstalling)
Write-Host "`nDisabling stock Google TV launcher (pm disable-user --user 0)..." -ForegroundColor Cyan
$disableStock = (& $adb shell pm disable-user --user 0 com.google.android.tvlauncher).Trim()
Write-Host "Result: $disableStock" -ForegroundColor Green

# 3. Refresh home screen
& $adb shell input keyevent KEYCODE_HOME

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "  Hume Launcher is now active as your primary Home screen!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "The stock launcher was safely frozen and can be restored anytime by running:"
Write-Host "  .\scripts\restore-stock-launcher.ps1 -DeviceIP $DeviceIP" -ForegroundColor Yellow
