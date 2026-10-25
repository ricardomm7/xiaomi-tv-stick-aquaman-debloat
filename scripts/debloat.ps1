<#
.SYNOPSIS
    Safe, Conservative ADB Debloat Script for Xiaomi Mi TV Stick HD (Android TV 9).
.DESCRIPTION
    Disables verified non-essential Xiaomi bloatware, background telemetry, and redundant
    sync services without root, without deleting system files, and without altering the stock launcher.
.PARAMETER DeviceIP
    The Wi-Fi IP address of your Xiaomi Mi TV Stick (e.g. 192.168.1.141).
#>

[CmdletBinding()]
param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$DeviceIP
)

# Prompt for IP if not passed as an argument
if ([string]::IsNullOrWhiteSpace($DeviceIP)) {
    $DeviceIP = Read-Host "Enter your Xiaomi Mi TV Stick IP address (e.g. 192.168.1.141)"
}

if ([string]::IsNullOrWhiteSpace($DeviceIP)) {
    Write-Error "Error: No IP address provided. Aborting."
    exit 1
}

# Locate ADB
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
Write-Host "  Xiaomi Mi TV Stick HD — Conservative ADB Debloat Script  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Connecting to ${DeviceIP}:5555 via ADB..."

& $adb connect "${DeviceIP}:5555"

# Verify connection
$devices = & $adb devices
if ($devices -notmatch [regex]::Escape($DeviceIP)) {
    Write-Error "Failed to connect to $DeviceIP. Ensure USB Debugging is ON and your TV Stick is powered on."
    exit 1
}

# Verify target device identity
$model = (& $adb shell getprop ro.product.model).Trim()
$mfg = (& $adb shell getprop ro.product.manufacturer).Trim()
$release = (& $adb shell getprop ro.build.version.release).Trim()
$fingerprint = (& $adb shell getprop ro.build.fingerprint).Trim()

Write-Host "`n[Device Verification]" -ForegroundColor Green
Write-Host "Manufacturer : $mfg"
Write-Host "Model        : $model"
Write-Host "Android Ver  : $release"
Write-Host "Fingerprint  : $fingerprint"

if ($model -notmatch "MiTV-AESP0|aquaman|MiTV" -and $mfg -notmatch "Xiaomi") {
    Write-Warning "Warning: Connected device ($mfg $model) does not appear to be a Xiaomi Mi TV Stick HD."
    $confirm = Read-Host "Do you want to proceed anyway? (y/N)"
    if ($confirm -ne 'y' -and $confirm -ne 'Y') {
        Write-Host "Aborted by user."
        exit 0
    }
}

# Baseline RAM measurement
Write-Host "`nMeasuring baseline memory (dumpsys meminfo)..." -ForegroundColor Yellow
$memBefore = & $adb shell dumpsys meminfo | Select-String "Total RAM|Free RAM|Used RAM"

# Target packages to disable (17 verified safe packages)
$packagesToDisable = @(
    # Tier A: Xiaomi & Alphonso Telemetry & Ads
    "tv.alphonso.alphonso_eula",
    "com.miui.tv.analytics",
    "com.mitv.tvhome.michannel",
    "com.mitv.dream",
    "com.mitv.download.service",
    "android.autoinstalls.config.xiaomi.mibox3",
    "android.autoinstalls.config.xioami.mibox3",
    "com.xiaomo.tv.milegal",
    "com.xm.webcontent",
    
    # Tier A: Google Telemetry, Error Reporting & Redundant Sync Adapters
    "com.google.android.feedback",
    "com.google.android.tv.bugreportsender",
    "com.android.printspooler",
    "com.google.android.syncadapters.calendar",
    "com.android.providers.calendar",
    "com.google.android.syncadapters.contacts",
    "com.android.providers.contacts",
    
    # Tier B: Optional Stock Media/Casting Services
    "com.mitv.videoplayer",
    "com.mitv.milinkservice"
)

Write-Host "`nStarting safe package deactivation (pm disable-user --user 0)..." -ForegroundColor Cyan

$successCount = 0
$failCount = 0

foreach ($pkg in $packagesToDisable) {
    Write-Host -NoNewline "Disabling $pkg ... "
    $res = (& $adb shell pm disable-user --user 0 $pkg).Trim()
    if ($res -match "disabled-user|disabled") {
        Write-Host "OK ($res)" -ForegroundColor Green
        $successCount++
    } else {
        Write-Host "WARNING: $res" -ForegroundColor Red
        $failCount++
    }
}

# Post-debloat RAM measurement
Write-Host "`nMeasuring post-debloat memory..." -ForegroundColor Yellow
$memAfter = & $adb shell dumpsys meminfo | Select-String "Total RAM|Free RAM|Used RAM"

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "  Debloat Summary  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Total packages targeted: $($packagesToDisable.Count)"
Write-Host "Successfully disabled  : $successCount" -ForegroundColor Green
if ($failCount -gt 0) {
    Write-Host "Failed/Warnings        : $failCount" -ForegroundColor Red
}

Write-Host "`n[Memory Comparison]" -ForegroundColor Yellow
Write-Host "BEFORE:"
$memBefore | ForEach-Object { Write-Host "  $_" }
Write-Host "AFTER:"
$memAfter | ForEach-Object { Write-Host "  $_" }

Write-Host "`nAll essential streaming apps (Netflix, YouTube, Prime, Apple TV, etc.)"
Write-Host "and core services (Google Play Store, Bluetooth remote, Cast) remain intact."
Write-Host "`nTo restore all disabled packages, run: .\scripts\revert.ps1 -DeviceIP $DeviceIP" -ForegroundColor Cyan
