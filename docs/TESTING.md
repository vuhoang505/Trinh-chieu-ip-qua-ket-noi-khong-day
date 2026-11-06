# Verification matrix

| Level | Scope | Current result |
|---|---|---|
| Unit | Config validation, command construction, screenshot, H.264 MP4 writing, cleanup | Automated by `pytest` |
| Native integration | Installed UxPlay executable starts and exposes `-vrtp` | Skipped unless `UXPLAY_PATH` is set |
| End-to-end | iPhone discovers receiver, pairs, displays moving video/audio, disconnects/reconnects | **CHƯA XÁC MINH** |

## Physical Windows/iPhone E2E checklist

Record Windows version, network adapter, UxPlay commit/version, GStreamer version,
iPhone model, and exact iOS version for every run.

1. Use a Private Windows network. Confirm both devices share the same LAN and AP
   client isolation is off.
2. Run `scripts/check-native.ps1`, then `scripts/run.ps1`.
3. Start Receiver and confirm `uxplay.exe` exists only once.
4. Confirm the advertised name appears in iPhone Screen Mirroring.
5. Connect with PIN if enabled. Reject a wrong PIN.
6. Display motion in portrait and landscape. Verify correct aspect ratio, measured FPS,
   and that the QML UI remains responsive for at least 30 minutes.
7. Verify audio/video sync and mute behavior.
8. Capture PNG and record at least 60 seconds. Play the final MP4 after a normal stop.
9. Disable iPhone Wi-Fi abruptly. The app must return to waiting without hanging.
10. Reconnect twice, stop the receiver, exit the app, and verify no `uxplay.exe`
    remains in Task Manager.
11. Repeat with hardware acceleration disabled and record CPU/GPU usage.

Only after this checklist passes may the E2E status be changed from **CHƯA XÁC MINH**.

