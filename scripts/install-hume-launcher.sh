#!/usr/bin/env bash
# ==============================================================================
# Install & Set Hume Launcher as Default (Linux / macOS)
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
echo "  Install & Set Hume Launcher as Default                  "
echo "=========================================================="
echo "Connecting to ${DEVICE_IP}:5555 via ADB..."
$ADB_CMD connect "${DEVICE_IP}:5555"

# Check if installed
if ! $ADB_CMD shell pm list packages | grep -q "com.petrobot.hume"; then
    APK_URL="https://github.com/petrobot-admin/hume-launcher/releases/download/v7.8/HumeLauncher-7.8.apk"
    TEMP_APK="/tmp/HumeLauncher-7.8.apk"
    echo "Downloading Hume Launcher v7.8 from official GitHub release..."
    curl -L "$APK_URL" -o "$TEMP_APK"
    
    echo "Installing Hume Launcher..."
    $ADB_CMD install -r "$TEMP_APK"
    rm -f "$TEMP_APK"
else
    echo "Hume Launcher is already installed."
fi

echo ""
echo "Setting Hume Launcher as default Home activity..."
$ADB_CMD shell cmd package set-home-activity com.petrobot.hume/.MainActivity

echo ""
echo "Disabling stock Google TV launcher (pm disable-user --user 0)..."
$ADB_CMD shell pm disable-user --user 0 com.google.android.tvlauncher

echo ""
echo "Enabling Hume Launcher PowerService in Accessibility settings..."
$ADB_CMD shell settings put secure enabled_accessibility_services com.petrobot.hume/com.petrobot.hume.PowerService
$ADB_CMD shell settings put secure accessibility_enabled 1

echo ""
echo "Refreshing Home screen..."
$ADB_CMD shell input keyevent KEYCODE_HOME

echo "=========================================================="
echo "  Hume Launcher is now active as your primary Home screen!"
echo "=========================================================="
