# Xiaomi Mi TV Stick HD (Android TV 9) — Safe ADB Debloat & Hume Launcher

[![Device](https://img.shields.io/badge/Device-Xiaomi%20Mi%20TV%20Stick%20HD%20(1080p)-orange.svg)](https://www.mi.com)
[![OS](https://img.shields.io/badge/OS-Android%20TV%209%20(Pie)-brightgreen.svg)](https://android.com)
[![Root](https://img.shields.io/badge/Root-NOT%20Required-blue.svg)](#)
[![Reversible](https://img.shields.io/badge/Reversibility-100%25%20Guaranteed-success.svg)](#reverting-changes)
[![Memory](https://img.shields.io/badge/RAM%20Freed-Up%20to%20%2B175%20MB-purple.svg)](#real-world-benchmarks)

A modular, zero-risk, rootless ADB optimization toolkit engineered specifically for the **Xiaomi Mi TV Stick HD (1080p)** running **Android TV 9 (Pie)**.

This repository provides **two independent, modular components**:
1. **Conservative Debloat:** Safely disables background telemetry (including Alphonso ACR audio tracking and Xiaomi BI analytics), ad injectors, and redundant sync daemons without modifying system partitions.
2. **Hume Launcher Integration (Optional):** Automatically installs and configures the ultra-lightweight, ad-free, Apple tvOS-styled [Hume Launcher](https://github.com/petrobot-admin/hume-launcher), freezing the heavy stock Google TV launcher while keeping it 100% restorable.

---

## The Hardware Constraint

The Xiaomi Mi TV Stick HD (Model: `MiTV-AESP0`, Codename: `aquaman`, Amlogic S805Y) has only **1 GB of RAM** (~980 MB usable). 

Out of the box, background telemetry daemons, automated content recognition (ACR) services, ad injectors, and mobile-phone synchronization adapters run continuously in the background. This consumes over 100 MB of active memory, keeping the Android kernel memory pressure at **`status critical`** and causing severe UI stuttering, app evictions, and input latency.

---

## Real-World Benchmarks

Empirical metrics measured directly via ADB `dumpsys meminfo` on physical hardware:

| Setup / Scenario | Free RAM | Active Launcher RAM | Kernel Status | Impact vs Factory Baseline |
| :--- | :---: | :---: | :---: | :---: |
| **Factory Baseline** (Stock + Telemetry + Ads) | **195 MB** | ~137 MB *(Google TV)* | `status critical` | *Baseline reference* |
| **After Debloat** (Stock Launcher Google) | **328 MB** | ~74 MB *(Google TV)* | `status moderate` | **+133 MB free RAM** |
| **Debloat + Hume Launcher** (Default) | **370 MB** | **~49 MB** *(Hume)* | `status moderate` | **+175 MB free RAM (+90% gain!)** |

---

## Repository Structure & Modular Scripts

```text
debloat-xiaomi-tv-stick/
├── debloat.bat                    # Windows shortcut: Run safe debloat
├── revert-debloat.bat             # Windows shortcut: Revert debloat
├── install-hume-launcher.bat      # Windows shortcut: Install & set Hume Launcher
├── restore-stock-launcher.bat     # Windows shortcut: Restore stock Google TV launcher
├── scripts/
│   ├── debloat.ps1                # PowerShell debloat script
│   ├── revert-debloat.ps1         # PowerShell revert debloat script
│   ├── debloat.sh                 # Linux / macOS Bash debloat script
│   ├── revert-debloat.sh          # Linux / macOS Bash revert debloat script
│   ├── install-hume-launcher.ps1  # PowerShell Hume Launcher setup
│   ├── restore-stock-launcher.ps1 # PowerShell Stock Launcher restore
│   ├── install-hume-launcher.sh   # Bash Hume Launcher setup
│   └── restore-stock-launcher.sh  # Bash Stock Launcher restore
├── data/
│   ├── baseline_packages.json     # Complete inventory of factory system packages
│   └── initial_state.json         # State snapshot before modification
├── AGENTS.md                      # AI Agent Architecture & Protocol Specification
├── README.md                      # Documentation
└── LICENSE                        # MIT License
```

---

## Prerequisites

1. **Computer:** Windows, Linux, or macOS connected to the same Wi-Fi network as the TV stick.
2. **ADB Installed:** Available via system PATH or placed in `platform-tools/`.
3. **Enable USB Debugging on your Mi TV Stick:**
   - On your TV: **Settings** > **Device Preferences** > **About**.
   - Scroll down to **Build number** and press the center remote button **7 times** until you see *"You are now a developer!"*.
   - Return to the previous menu, open **Developer options**, and turn **USB debugging** to **ON**.
   - Note your IP in **Settings** > **Network & Internet** > select connected Wi-Fi (e.g. `192.168.1.141`).

---

## Part 1: Conservative Debloat (Independent)

Disables 17 confirmed safe packages (Alphonso ACR telemetry, Xiaomi BI analytics, PatchWall ad injectors, and redundant calendar/contacts synchronization) using `pm disable-user --user 0`.

### To Run Debloat:
- **Windows:** Double-click `debloat.bat` or run:
  ```powershell
  .\scripts\debloat.ps1 -DeviceIP 192.168.1.XXX
  ```
- **Linux / macOS:**
  ```bash
  chmod +x scripts/*.sh
  ./scripts/debloat.sh 192.168.1.XXX
  ```

### To Revert Debloat:
- **Windows:** Double-click `revert-debloat.bat` or run:
  ```powershell
  .\scripts\revert-debloat.ps1 -DeviceIP 192.168.1.XXX
  ```
- **Linux / macOS:**
  ```bash
  ./scripts/revert-debloat.sh 192.168.1.XXX
  ```

---

## Part 2: Hume Launcher Setup (Independent)

[Hume Launcher](https://github.com/petrobot-admin/hume-launcher) is an open-source, ultra-lightweight (~1 MB) Apple tvOS-styled launcher for Android TV:
- Zero ads, zero tracking, and no sponsored recommendation rows.
- Consumes only **~49 MB of RAM** (compared to ~137 MB for the stock Google TV launcher).
- Highly responsive focus animations and glass dock.

### To Install & Set Hume as Default:
The script automatically downloads the official release, sets it as the default home activity via `cmd package set-home-activity`, and safely freezes the stock launcher:

- **Windows:** Double-click `install-hume-launcher.bat` or run:
  ```powershell
  .\scripts\install-hume-launcher.ps1 -DeviceIP 192.168.1.XXX
  ```
- **Linux / macOS:**
  ```bash
  ./scripts/install-hume-launcher.sh 192.168.1.XXX
  ```

### To Restore Stock Google TV Launcher:
The restore script immediately re-enables `com.google.android.tvlauncher`, sets it back as the primary home activity, and prompts if you'd like to uninstall Hume Launcher:

- **Windows:** Double-click `restore-stock-launcher.bat` or run:
  ```powershell
  .\scripts\restore-stock-launcher.ps1 -DeviceIP 192.168.1.XXX
  ```
- **Linux / macOS:**
  ```bash
  ./scripts/restore-stock-launcher.sh 192.168.1.XXX
  ```

---

## Safety Guarantees

- 🛡️ **DRM / Widevine L1:** `mitv.service` is strictly preserved. Netflix and Prime Video stream in 1080p HD without issues.
- 🛡️ **Remote Control Pairing:** `com.xiaomi.android.tvsetup.partnercustomizer` and Bluetooth stack remain untouched.
- 🛡️ **Non-Destructive:** No packages are uninstalled (`pm uninstall` is never used). Everything can be restored via ADB.
- 🛡️ **Zero Partitions Modified:** System partitions remain in original read-only state.

---

## License

This project is licensed under the [MIT License](LICENSE).
