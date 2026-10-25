#!/usr/bin/env bash
# ==============================================================================
# Restore Stock Google TV Launcher (Linux / macOS)
# ==============================================================================
set -e

DEVICE_IP="${1:-}"

if [ -z "$DEVICE_IP" ]; then
    read -rp "Enter your Xiaomi Mi TV Stick IP address (e.g. 192.168.1.141): " DEVICE_IP
fi

if [ -z "$DEVICE_IP" ]; then
    echo "Error: No IP address provided. Aborting."
    exit 1
fi

ADB_CMD="adb"
if ! command -v adb &> /dev/null; then
    if [ -f "./platform-tools/adb" ]; then
        ADB_CMD="./platform-tools/adb"
    elif [ -f "../platform-tools/adb" ]; then
        ADB_CMD="../platform-tools/adb"
    else
        echo "Error: 'adb' not found in PATH or platform-tools directory."
        exit 1
    fi
fi

echo "=========================================================="
echo "  Restore Stock Google TV Launcher                        "
echo "=========================================================="
echo "Connecting to ${DEVICE_IP}:5555 via ADB..."
$ADB_CMD connect "${DEVICE_IP}:5555"

echo ""
echo "Re-enabling stock Google TV launcher..."
$ADB_CMD shell pm enable --user 0 com.google.android.tvlauncher

echo ""
echo "Setting stock launcher as default Home activity..."
$ADB_CMD shell cmd package set-home-activity com.google.android.tvlauncher/.MainActivity

echo ""
echo "Refreshing Home screen..."
$ADB_CMD shell input keyevent KEYCODE_HOME

read -rp "Do you also want to uninstall Hume Launcher? (y/N): " UNINSTALL
if [[ "$UNINSTALL" =~ ^[Yy]$ ]]; then
    $ADB_CMD uninstall com.petrobot.hume
    echo "Hume Launcher uninstalled."
fi

echo "Stock launcher successfully restored!"
