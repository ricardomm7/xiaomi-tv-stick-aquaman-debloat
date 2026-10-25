#!/usr/bin/env bash
# ==============================================================================
# Safe, Conservative ADB Debloat Script for Xiaomi Mi TV Stick HD (Android TV 9)
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
echo "  Xiaomi Mi TV Stick HD — Conservative ADB Debloat Script  "
echo "=========================================================="
echo "Connecting to ${DEVICE_IP}:5555 via ADB..."
$ADB_CMD connect "${DEVICE_IP}:5555"

echo ""
echo "[Device Verification]"
MODEL=$($ADB_CMD shell getprop ro.product.model | tr -d '\r')
MFG=$($ADB_CMD shell getprop ro.product.manufacturer | tr -d '\r')
RELEASE=$($ADB_CMD shell getprop ro.build.version.release | tr -d '\r')
FINGERPRINT=$($ADB_CMD shell getprop ro.build.fingerprint | tr -d '\r')

echo "Manufacturer : $MFG"
echo "Model        : $MODEL"
echo "Android Ver  : $RELEASE"
echo "Fingerprint  : $FINGERPRINT"

echo ""
echo "Measuring baseline memory..."
$ADB_CMD shell dumpsys meminfo | grep -E "Total RAM|Free RAM|Used RAM" || true

PACKAGES=(
    # Tier A: Xiaomi & Alphonso Telemetry & Ads
    "tv.alphonso.alphonso_eula"
    "com.miui.tv.analytics"
    "com.mitv.tvhome.michannel"
    "com.mitv.dream"
    "com.mitv.download.service"
    "android.autoinstalls.config.xiaomi.mibox3"
    "android.autoinstalls.config.xioami.mibox3"
    "com.xiaomo.tv.milegal"
    "com.xm.webcontent"

    # Tier A: Google Telemetry, Error Reporting & Redundant Sync Adapters
    "com.google.android.feedback"
    "com.google.android.tv.bugreportsender"
    "com.android.printspooler"
    "com.google.android.syncadapters.calendar"
    "com.android.providers.calendar"
    "com.google.android.syncadapters.contacts"
    "com.android.providers.contacts"

    # Tier B: Optional Stock Media/Casting Services
    "com.mitv.videoplayer"
    "com.mitv.milinkservice"
)

echo ""
echo "Disabling packages safely via pm disable-user --user 0..."
for pkg in "${PACKAGES[@]}"; do
    printf "Disabling %-45s " "$pkg..."
    RES=$($ADB_CMD shell pm disable-user --user 0 "$pkg" | tr -d '\r')
    echo "$RES"
done

echo ""
echo "Measuring post-debloat memory..."
$ADB_CMD shell dumpsys meminfo | grep -E "Total RAM|Free RAM|Used RAM" || true

echo ""
echo "=========================================================="
echo "  Debloat Completed Successfully!                         "
echo "=========================================================="
echo "To restore all packages, run: ./scripts/revert.sh $DEVICE_IP"
