# Relatório Final — Debloat Xiaomi Mi TV Stick HD (Android TV 9)

- **Data da Intervenção:** 2026-10-25 22:35 UTC
- **Dispositivo:** Xiaomi Mi TV Stick HD (aquaman)
- **Modelo:** `MiTV-AESP0`
- **Versão do Android:** 9 (API 28)
- **Compilação:** `PI.2055 release-keys`
- **Fingerprint:** `Xiaomi/aquaman/aquaman:9/PI/2055:user/release-keys`
- **Endereço ADB:** 192.168.1.141:5555

---

## 1. Resumo da Intervenção

- **Total de pacotes no sistema:** 96 pacotes.
- **Pacotes previamente desativados (Grupo D mantido):** 5 pacotes.
- **Pacotes efetivamente alterados nesta intervenção:** 17 pacotes.
- **Método utilizado:** `pm disable-user --user 0 <PACKAGE>` (sem root, 100% reversível, sem eliminação de ficheiros).
- **Aplicações instaladas na TV:** 0 (nenhuma aplicação, launcher ou ferramenta foi instalada).
- **Launcher alterado:** Não (permanece o `com.google.android.tvlauncher` original).
- **Partições modificadas:** Não (partição de sistema `/system` mantida 100% intacta e em modo apenas de leitura).

---

## 2. Lista dos 17 Pacotes Efetivamente Desativados

| # | Nome legível | Nome exato do pacote | Estado inicial | Estado final |
| :- | :--- | :--- | :---: | :---: |
| 1 | Alphonso ACR Telemetry | `tv.alphonso.alphonso_eula` | enabled | **disabled-user** |
| 2 | Xiaomi MiTV Analytics | `com.miui.tv.analytics` | enabled | **disabled-user** |
| 3 | Xiaomi MiChannel (MetaX Ads) | `com.mitv.tvhome.michannel` | enabled | **disabled-user** |
| 4 | Xiaomi MiTV Dream Screensaver | `com.mitv.dream` | enabled | **disabled-user** |
| 5 | Xiaomi Play Auto-Install Config | `android.autoinstalls.config.xiaomi.mibox3` | enabled | **disabled-user** |
| 6 | Xiaomi Play Auto-Install Base | `android.autoinstalls.config.xioami.mibox3` | enabled | **disabled-user** |
| 7 | Google Feedback | `com.google.android.feedback` | enabled | **disabled-user** |
| 8 | Google TV Bug Report Sender | `com.google.android.tv.bugreportsender` | enabled | **disabled-user** |
| 9 | Android Print Spooler | `com.android.printspooler` | enabled | **disabled-user** |
| 10 | Google Calendar Sync Adapter | `com.google.android.syncadapters.calendar` | enabled | **disabled-user** |
| 11 | Android Calendar Provider | `com.android.providers.calendar` | enabled | **disabled-user** |
| 12 | Google Contacts Sync Adapter | `com.google.android.syncadapters.contacts` | enabled | **disabled-user** |
| 13 | Android Contacts Provider | `com.android.providers.contacts` | enabled | **disabled-user** |
| 14 | Xiaomi Legal & Privacy Terms | `com.xiaomo.tv.milegal` | enabled | **disabled-user** |
| 15 | Xiaomi Web Content Viewer | `com.xm.webcontent` | enabled | **disabled-user** |
| 16 | Xiaomi Mi Video Player | `com.mitv.videoplayer` | enabled | **disabled-user** |
| 17 | Xiaomi MiLink Service | `com.mitv.milinkservice` | enabled | **disabled-user** |

---

## 3. Pacotes do Grupo D (Previamente Desativados e Preservados)

1. `com.mitv.tvhome.atv` (PatchWall da Xiaomi)
2. `com.google.android.tv` (Live Channels da Google)
3. `com.google.android.youtube.tvmusic` (YouTube Music)
4. `com.google.android.videos` (Google Play Filmes / Google TV)
5. `com.google.android.play.games` (Google Play Jogos)

---

## 4. Confirmação de Integridade das Aplicações Essenciais

Todos os seguintes componentes foram verificados após a intervenção e permanecem **ATIVADOS E TOTALMENTE FUNCIONAIS**:

- **Aplicações de Streaming Pessoais:**
  - YouTube (`com.google.android.youtube.tv`)
  - Netflix (`com.netflix.ninja`)
  - Prime Video (`com.amazon.amazonvideo.livingroom`)
  - Apple TV (`com.apple.atve.androidtv.appletv`)
  - Vodafone TV (`com.vodafone.vtv.atv.pt`)
  - RTP Play (`pt.rtp.play`)
  - TVI Player (`pt.iol.tviplayer.androidtv`)
  - Stremio (`com.stremio.one`)
  - Acestream (`org.acestream.node`)
- **Loja e Serviços Centrais Google:**
  - Google Play Store (`com.android.vending`)
  - Google Play Services (`com.google.android.gms`)
  - Google Services Framework (`com.google.android.gsf`)
  - Android TV Webview (`com.google.android.webview`)
- **Hardware, Controlo Remoto, Bluetooth, HDMI-CEC e DRM:**
  - `mitv.service` (Hardware/Netflix ESN/power server Xiaomi intacto)
  - `com.android.bluetooth` (Bluetooth para o comando)
  - `com.google.android.tv.remote.service` (Serviço de controlo remoto)
  - `com.google.android.apps.mediashell` (Google Cast / Chromecast intacto)
  - `com.droidlogic` (Drivers Amlogic intactos)
- **Atualizações de Sistema:**
  - `com.xiaomi.mitv.updateservice` (OTA da Xiaomi intacto)

---

## 5. Medições de Desempenho e Memória RAM

Medições reais obtidas diretamente através de `dumpsys meminfo` antes e depois da operação:

- **Memória RAM Livre:** Aumentou de **195 MB** (`195,948 KB`) para **328 MB** (`328,334 KB`) — ganho real de **+132 MB de RAM livre**.
- **Memória RAM Utilizada pelo Userspace (PSS):** Reduziu de **551 MB** para **460 MB** — diminuição de **91 MB**.
- **Estado de Memória do Sistema:** O estado de pressão de memória do kernel transitou de **`status critical`** para **`status moderate`**.
- **Processos de Fundo Terminados:** Os serviços `tv.alphonso.alphonsoBackgroundService`, `com.miui.tv.analytics` e `com.mitv.milinkservice` foram imediatamente descarregados da memória RAM.
- **Armazenamento:** Sem alteração na partição de sistema `/system` (os binários permanecem no firmware de fábrica para reversibilidade total). A partição `/data` mantém 2.2 GB livres.

---

## 6. Procedimento de Reversão

Para restaurar instantaneamente qualquer um ou todos os pacotes desativados, foram criados localmente os ficheiros executáveis:
- `reverter_debloat.bat` (Linha de comandos Windows)
- `reverter_debloat.ps1` (PowerShell)

Comandos individuais de reversão:
```bash
adb shell pm enable --user 0 tv.alphonso.alphonso_eula
adb shell pm enable --user 0 com.miui.tv.analytics
adb shell pm enable --user 0 com.mitv.tvhome.michannel
adb shell pm enable --user 0 com.mitv.dream
adb shell pm enable --user 0 android.autoinstalls.config.xiaomi.mibox3
adb shell pm enable --user 0 android.autoinstalls.config.xioami.mibox3
adb shell pm enable --user 0 com.google.android.feedback
adb shell pm enable --user 0 com.google.android.tv.bugreportsender
adb shell pm enable --user 0 com.android.printspooler
adb shell pm enable --user 0 com.google.android.syncadapters.calendar
adb shell pm enable --user 0 com.android.providers.calendar
adb shell pm enable --user 0 com.google.android.syncadapters.contacts
adb shell pm enable --user 0 com.android.providers.contacts
adb shell pm enable --user 0 com.xiaomo.tv.milegal
adb shell pm enable --user 0 com.xm.webcontent
adb shell pm enable --user 0 com.mitv.videoplayer
adb shell pm enable --user 0 com.mitv.milinkservice
```
