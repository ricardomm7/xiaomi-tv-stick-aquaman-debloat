@echo off
setlocal
echo ==========================================================
echo   Xiaomi Mi TV Stick HD - Revert Debloat
echo ==========================================================

set /p DEVICE_IP="Enter your Xiaomi Mi TV Stick IP address (e.g. 192.168.1.141): "

if "%DEVICE_IP%"=="" (
    echo Error: No IP address entered.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\revert-debloat.ps1" -DeviceIP "%DEVICE_IP%"

pause
