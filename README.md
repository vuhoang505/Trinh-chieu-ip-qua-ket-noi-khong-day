# iPhone Wireless Mirror

A Windows 10/11 desktop receiver with a PySide6/Qt Quick dashboard and a real
[UxPlay](https://github.com/FDH2/UxPlay) AirPlay backend. It is local-first: the
receiver, RTP bridge, preview, screenshots, and recordings remain on the LAN/PC.

> Current verification state: unit tests can be run on this PC. Native AirPlay
> integration needs an installed UxPlay runtime. Physical-iPhone E2E is explicitly
> **CHƯA XÁC MINH** until it is tested on the target LAN with an actual iPhone.

## Architecture

```text
iPhone (AirPlay legacy mirror protocol)
       │ LAN: mDNS + negotiated TCP/UDP
       ▼
UxPlay native process + GStreamer
       │ H.264 RTP, UDP 127.0.0.1:5000 only
       ▼
PyAV decoder worker ──► latest QImage ──► QML preview
       ├──────────────► PNG/JPEG screenshots
       └──────────────► H.264 MP4 recorder
```

Python does not pretend to implement AirPlay. `UxPlayAdapter` owns the native
process, parses lifecycle output, forwards its H.264 stream over loopback, and always
terminates it during application shutdown. Video decoding never runs on the UI thread.

## 1. Python environment

Python 3.11 or 3.12 (64-bit) is recommended.

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\setup.ps1 -Dev
```

This creates `.venv`, upgrades only that environment's pip, installs PySide6/PyAV,
and prints a native dependency report. Nothing is installed into global Python.

Manual equivalent:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements-dev.txt
```

## 2. Install/build UxPlay on Windows

UxPlay is not a pip package. Upstream tests Windows 10/11 using the UCRT64 or MINGW64
environment from [MSYS2](https://www.msys2.org/), with GStreamer and its plugins.

Supported integration targets:

- UxPlay 1.73.7: current stable/security release; `-vrtp` is available, but its
  traditional Windows build uses Bonjour/DNS-SD.
- UxPlay 1.74 experimental source: provides an internal minimal mDNS implementation,
  removing the Bonjour SDK requirement when built with `-DUSE_MDNS=1`.

The repository provides a transparent helper, but does not silently install or modify
system PATH:

```powershell
# First install MSYS2 yourself from its official site, then clone UxPlay.
git clone https://github.com/FDH2/UxPlay "$env:USERPROFILE\source\UxPlay"

# Review commands only:
.\scripts\build-uxplay.ps1

# Install MSYS2 packages and build after review:
.\scripts\build-uxplay.ps1 -Execute
```

Then either:

```powershell
$env:UXPLAY_PATH = 'C:\Users\YOU\source\UxPlay\build\uxplay.exe'
```

The standard clone path `%USERPROFILE%\source\UxPlay\build\uxplay.exe` and the
MSYS2 UCRT64 runtime are detected automatically. `UXPLAY_PATH` is only needed when
UxPlay is stored somewhere else.

or place a properly redistributable runtime under `vendor\uxplay`. A single EXE is
usually not enough: the MinGW and GStreamer runtime DLLs plus plugin directories must
remain discoverable. Run:

```powershell
.\scripts\check-native.ps1
```

The application requires UxPlay 1.73+ because it uses `-vrtp`. It does not download a
random third-party executable.

## 3. Run

```powershell
.\scripts\run.ps1
```

Click **Start Receiver**, then on the iPhone open Control Center → Screen Mirroring →
select the configured receiver name. Both devices must be on the same Wi-Fi/LAN and
client isolation must be disabled on the access point.

During mirroring, press **F11** (or double-click the video) for the distraction-free
fullscreen view, **Esc** to leave fullscreen, and **R** to rotate the preview by 90°.
The stage automatically changes between portrait and landscape when the incoming
frame dimensions change.

If Windows prompts for network access, allow the executable only on **Private**
networks. Do not disable Windows Firewall globally.

## Network and security

With default settings UxPlay needs:

- UDP 5353 for mDNS/DNS-SD advertisement.
- Three TCP and three UDP AirPlay ports beginning at 7100 (7100–7102 here).
- UDP 5000 is loopback-only (`127.0.0.1`) between UxPlay and this UI.

No UPnP/router port forwarding is used. No telemetry or cloud upload is implemented.
Screen content is written only when the user explicitly clicks Screenshot or Record.
Enable PIN mode in the local config if the LAN is not fully trusted; fixed PINs should
not be committed or shared.

The config lives at `%LOCALAPPDATA%\iPhoneWirelessMirror\config.json`; screenshots and
recordings default to sibling folders there. Useful advanced keys include
`uxplay_path`, `pin_enabled`, `fixed_pin`, `airplay_port_base`,
`hardware_acceleration`, and `max_fps`.

## Features and honest limitations

- Real UxPlay receiver process; no mock receiver in production.
- Low-latency QML preview via RTP/PyAV with measured FPS, latest-frame delivery, and
  no queued-frame buildup when the UI is briefly busy.
- Responsive light 3D dashboard with polished hover/press/focus effects,
  distraction-free fullscreen, automatic portrait/landscape sizing, manual 90°
  rotation, and keyboard shortcuts.
- PNG/JPEG screenshots and local H.264 MP4 recording with pause/stop.
- Audio is rendered by UxPlay/GStreamer through WASAPI. Mute/volume changes restart the
  receiver. Dynamic output-device selection and audio capture into the Python MP4 are
  not yet supported.
- Native portrait/landscape frame dimensions and manual rotation are supported while
  preserving aspect ratio. Automatic handling of every iOS rotation-metadata variant
  still requires verification against physical iPhone models.
- The NVIDIA option requests `d3d11h264dec`; availability depends on installed
  GStreamer plugins/driver. Software decoding remains the compatibility fallback, but
  if that element is absent, disable `hardware_acceleration` in config and restart.
- Apple may change its undocumented legacy mirroring protocol. Upstream currently
  documents legacy-protocol support but does not guarantee future iOS compatibility.

## Test

```powershell
.\.venv\Scripts\python.exe -m pytest
```

Native integration (only when `UXPLAY_PATH` is set):

```powershell
.\.venv\Scripts\python.exe -m pytest -m integration
```

The E2E marker is always skipped in automation because success requires a physical
iPhone and visual confirmation. See [docs/TESTING.md](docs/TESTING.md).

## Package

```powershell
.\scripts\package.ps1
```

The PyInstaller build packages the Python/QML UI. UxPlay/GStreamer are deliberately
not bundled by default: redistribution must first satisfy GPL/LGPL obligations and
be tested on a clean Windows VM. See [docs/LICENSES.md](docs/LICENSES.md).

## Research basis

- [UxPlay upstream README and Windows build instructions](https://github.com/FDH2/UxPlay)
- [UxPlay releases](https://github.com/FDH2/UxPlay/releases)
- [UxPlay command manual](https://github.com/FDH2/UxPlay/blob/master/uxplay.1)
- [GStreamer Windows installation](https://gstreamer.freedesktop.org/documentation/installing/on-windows.html)

