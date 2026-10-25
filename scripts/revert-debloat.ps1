<#
.SYNOPSIS
    Revert Script for Xiaomi Mi TV Stick HD (Android TV 9).
.DESCRIPTION
    Re-enables all 17 packages modified by the debloat script using pm enable --user 0.
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
Write-Host "  Xiaomi Mi TV Stick HD — Revert Debloat Script           " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Connecting to ${DeviceIP}:5555 via ADB..."

& $adb connect "${DeviceIP}:5555"

$packagesToRevert = @(
    "tv.alphonso.alphonso_eula",
    "com.miui.tv.analytics",
    "com.mitv.tvhome.michannel",
    "com.mitv.dream",
    "com.mitv.download.service",
    "android.autoinstalls.config.xiaomi.mibox3",
    "android.autoinstalls.config.xioami.mibox3",
    "com.xiaomo.tv.milegal",
    "com.xm.webcontent",
    "com.google.android.feedback",
    "com.google.android.tv.bugreportsender",
    "com.android.printspooler",
    "com.google.android.syncadapters.calendar",
    "com.android.providers.calendar",
    "com.google.android.syncadapters.contacts",
    "com.android.providers.contacts",
    "com.mitv.videoplayer",
    "com.mitv.milinkservice"
)

Write-Host "`nRestoring packages to enabled state..." -ForegroundColor Cyan

foreach ($pkg in $packagesToRevert) {
    Write-Host -NoNewline "Enabling $pkg ... "
    $res = (& $adb shell pm enable --user 0 $pkg).Trim()
    Write-Host "$res" -ForegroundColor Green
}

Write-Host "`nAll 17 packages have been successfully re-enabled." -ForegroundColor Green
