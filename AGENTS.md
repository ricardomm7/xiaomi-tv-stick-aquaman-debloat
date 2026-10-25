# AGENTS.md — AI Agent Operating Guide & Architecture Specification

> **Target Platform:** Xiaomi Mi TV Stick HD 1080p (`MiTV-AESP0`, codename `aquaman`)  
> **Operating System:** Android TV 9 (Pie) — API Level 28  
> **SoC / Hardware:** Amlogic S805Y Quad-Core ARM Cortex-A53, Mali-450, 1 GB LPDDR4 RAM  
> **Build Fingerprint:** `Xiaomi/aquaman/aquaman:9/PI/2055:user/release-keys`

---

## 1. Project Overview & Philosophy

This repository contains an empirical, zero-risk, rootless ADB debloat and launcher optimization toolkit tailored specifically for the **Xiaomi Mi TV Stick HD** running Android TV 9.

Due to the device's constrained **1 GB of RAM**, background telemetry processes from Xiaomi and third-party ad providers push kernel memory pressure to `status critical`. 

The repository is modularly split into two independent operations:
1. **Conservative Debloat:** Freezes 17 verified telemetry/ad daemons without touching core services or launchers.
2. **Alternative Launcher Integration (Hume Launcher):** Replaces the bloated Google TV launcher with the ultra-lightweight, ad-free [Hume Launcher](https://github.com/petrobot-admin/hume-launcher) (tvOS style, ~1 MB, ~49 MB RAM) via `cmd package set-home-activity` while safely freezing `com.google.android.tvlauncher` (no uninstallation).

### Core Tenets:
1. **Rootless & Non-Destructive:** No root, no bootloader unlocking, and no modifying `/system` partition binaries.
2. **Never Use `pm uninstall`:** Packages must never be uninstalled (even with `pm uninstall --user 0`). Only `pm disable-user --user 0 <PACKAGE>` is permitted. This guarantees 100% immediate reversibility.
3. **Preserve Hardware DRM & Netflix ESN:** `mitv.service` must remain active under all circumstances.
4. **Preserve Remote & Connectivity:** Bluetooth, Wi-Fi, HDMI-CEC, and remote control pairing activities must never be disabled.
5. **Separation of Concerns:** Debloat scripts and Launcher scripts are maintained in strictly separate, independent modules.

---

## 2. Hardware Architecture & Constraints

```
┌─────────────────────────────────────────────────────────────┐
│                 Xiaomi Mi TV Stick HD (aquaman)             │
├──────────────────────────────┬──────────────────────────────┤
│ CPU: 4x ARM Cortex-A53 @1.2G │ RAM: 1,004,412 KB (~1.0 GB)  │
│ GPU: Mali-450 MP3            │ Flash Storage: 8 GB eMMC     │
│ Video: 1080p@60fps H.264/265 │ Wi-Fi: 802.11 a/b/g/n/ac 5G  │
│ DRM: Widevine L1 (Netflix HD)│ Bluetooth: 4.2 BLE Remote    │
└──────────────────────────────┴──────────────────────────────┘
```

---

## 3. Package Classification Matrix

### Tier A: Confirmed Safe for Deactivation (15 Packages)
- `tv.alphonso.alphonso_eula` (Alphonso ACR audio beacon listener)
- `com.miui.tv.analytics` (Xiaomi BI telemetry daemon)
- `com.mitv.tvhome.michannel` (PatchWall sponsored ad injector)
- `com.mitv.dream` (Redundant screensaver with memory profiler)
- `android.autoinstalls.config.xiaomi.mibox3` (Play Auto-Install config)
- `android.autoinstalls.config.xioami.mibox3` (Play Auto-Install base config)
- `com.google.android.feedback` (Google manual crash feedback)
- `com.google.android.tv.bugreportsender` (Bug report sender)
- `com.android.printspooler` (Android printing service)
- `com.google.android.syncadapters.calendar` (Calendar sync adapter)
- `com.android.providers.calendar` (Calendar provider database)
- `com.google.android.syncadapters.contacts` (Contacts sync adapter)
- `com.android.providers.contacts` (Contacts provider database)
- `com.xiaomo.tv.milegal` (Xiaomi legal terms viewer)
- `com.xm.webcontent` (Xiaomi promotional webview wrapper)

### Tier B: Optional Stock Media Services (2 Packages)
- `com.mitv.videoplayer` (Stock Xiaomi video player)
- `com.mitv.milinkservice` (Xiaomi proprietary phone mirroring)

### Tier C: CRITICAL — NEVER DEACTIVATE
> [!CAUTION]
> Deactivating any of the following packages will compromise hardware functionality, remote pairing, DRM playback, or device bootability:

1. **`mitv.service`:** Low-level TV hardware daemon (`xiaomi.tvservice`). Holds **Netflix ESN hardware keys** and AmLogic power state handlers.
2. **`com.xiaomi.android.tvsetup.partnercustomizer`:** Contains `BleRcActivity` (Bluetooth Remote Control), `IRPairingActivity`, and `GlobalKeyReceiver`. Disabling breaks remote control pairing and key handling!
3. **`com.google.android.tungsten.setupwraith`:** Remote re-pairing and Google account addition.
4. **`com.droidlogic` / `com.droidlogic.ble` / `com.droidlogic.overlay`:** Amlogic SoC vendor drivers.
5. **`com.google.android.vending` & `com.google.android.gms`:** Google Play Store and Services.
6. **`com.google.android.apps.mediashell`:** Google Cast / Chromecast receiver.
7. **`com.android.bluetooth` & `com.google.android.tv.remote.service`:** Remote connectivity stack.
8. **`com.xiaomi.mitv.updateservice`:** Xiaomi OTA update receiver.

### Tier D: Factory-Disabled Packages
- `com.mitv.tvhome.atv` (PatchWall)
- `com.google.android.tv` (Live Channels)
- `com.google.android.youtube.tvmusic` (YouTube Music)
- `com.google.android.videos` (Google Play Movies)
- `com.google.android.play.games` (Google Play Games)

---

## 4. Empirical Benchmark Data

All metrics below were measured on actual physical hardware via ADB `dumpsys meminfo`:

| Configuration | Free RAM | Used PSS RAM | Kernel State | Delta vs Factory |
| :--- | :---: | :---: | :---: | :---: |
| **Factory Baseline** | 195 MB | 551 MB | `status critical` | Reference |
| **Debloat (Stock Launcher)** | 328 MB | 460 MB | `status moderate` | **+133 MB free** |
| **Debloat + Hume Launcher** | **370 MB** | **471 MB** | `status moderate` | **+175 MB free (+90%)** |

---

## 5. Modular Script Directory Layout

```text
scripts/
├── debloat.ps1                 # Disables Tier A (15) + Tier B (2) packages
├── revert-debloat.ps1          # Re-enables all 17 debloated packages
├── debloat.sh                  # POSIX Bash equivalent for debloat
├── revert-debloat.sh           # POSIX Bash equivalent for revert
├── install-hume-launcher.ps1   # Installs Hume, sets home activity, freezes stock launcher
├── restore-stock-launcher.ps1  # Re-enables stock launcher, resets home activity
├── install-hume-launcher.sh    # POSIX Bash equivalent for Hume install
└── restore-stock-launcher.sh   # POSIX Bash equivalent for stock restore
```

### Execution Commands:
- Set Hume as Home:
  ```bash
  adb shell cmd package set-home-activity com.petrobot.hume/.MainActivity
  adb shell pm disable-user --user 0 com.google.android.tvlauncher
  ```
- Restore Stock Launcher:
  ```bash
  adb shell pm enable --user 0 com.google.android.tvlauncher
  adb shell cmd package set-home-activity com.google.android.tvlauncher/.MainActivity
  ```
