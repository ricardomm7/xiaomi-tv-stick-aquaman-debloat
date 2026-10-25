#!/usr/bin/env bash
# ==============================================================================
# Revert Script for Xiaomi Mi TV Stick HD (Android TV 9)
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
echo "  Xiaomi Mi TV Stick HD — Revert Debloat Script           "
echo "=========================================================="
echo "Connecting to ${DEVICE_IP}:5555 via ADB..."
$ADB_CMD connect "${DEVICE_IP}:5555"

PACKAGES=(
    "tv.alphonso.alphonso_eula"
    "com.miui.tv.analytics"
    "com.mitv.tvhome.michannel"
    "com.mitv.dream"
    "com.mitv.download.service"
    "android.autoinstalls.config.xiaomi.mibox3"
    "android.autoinstalls.config.xioami.mibox3"
    "com.xiaomo.tv.milegal"
    "com.xm.webcontent"
    "com.google.android.feedback"
    "com.google.android.tv.bugreportsender"
    "com.android.printspooler"
    "com.google.android.syncadapters.calendar"
    "com.android.providers.calendar"
    "com.google.android.syncadapters.contacts"
    "com.android.providers.contacts"
    "com.mitv.videoplayer"
    "com.mitv.milinkservice"
)

echo ""
echo "Re-enabling all 17 debloated packages..."
for pkg in "${PACKAGES[@]}"; do
    printf "Enabling %-45s " "$pkg..."
    RES=$($ADB_CMD shell pm enable --user 0 "$pkg" | tr -d '\r')
    echo "$RES"
done

echo ""
echo "All 17 packages have been restored."
