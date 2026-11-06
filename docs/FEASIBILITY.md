# AirPlay feasibility decision

## Decision

Use UxPlay as an external native protocol engine and keep Python responsible for UI,
process ownership, preview, capture, settings, and diagnostics.

UxPlay is the only evaluated option here with current upstream documentation for
AirPlay screen mirroring plus audio on Windows 10/11. It implements Apple's legacy
AirPlay 2 mirroring path, FairPlay-related protocol handling, pairing/authentication,
service advertisement, and GStreamer media pipelines. Reimplementing those pieces in
Python would be high-risk and would not meet the request for a working receiver.

## Windows viability

Upstream's supported Windows route is MSYS2 with MinGW/UCRT64, CMake/Ninja, libplist,
OpenSSL, GStreamer base/good/bad/libav plugins, and either Bonjour DNS-SD (stable
1.73.x) or the experimental internal mDNS implementation (1.74 source). UxPlay can be
started from a normal Windows process if its DLL/plugin runtime is discoverable.

This is not `pip install uxplay`, and the application reports a hard dependency error
when no real executable is found.

## UI integration

Embedding a window owned by another process is fragile on Windows and breaks DPI,
focus, fullscreen, and packaging. UxPlay 1.73 introduced `-vrtp`, which applies
`rtph264pay`/`rtph265pay` and sends the decrypted media to a custom GStreamer pipeline.
This app directs H.264 RTP to UDP loopback port 5000 and decodes it with PyAV in a
worker thread. QML sees only the most recent immutable `QImage`, so an old backlog is
not displayed during load spikes.

Current preview is H.264. H.265/4K negotiation is not enabled until SDP codec switching
and physical-device tests are implemented.

## Audio

UxPlay/GStreamer renders synchronized audio directly to `wasapisink`. Its `-artp`
option could later feed an audio pipeline, but the current Python recorder is video
only. The UI must not claim otherwise.

## Version and iOS compatibility

The adapter requires UxPlay 1.73+ for RTP forwarding. As of the research date,
upstream lists Windows 10/11 testing and active fixes for current iOS behavior, but its
README explicitly warns that future iOS versions may stop supporting the legacy
protocol. Therefore compatibility is recorded per tested device/OS, never as “all iOS.”

## Distribution

UxPlay is GPL-3.0. Bundling it with a desktop distribution creates source-offer and
license obligations. GStreamer is principally LGPL, while individual plugins/codecs
have their own terms. PySide6 is LGPL/commercial depending on usage. A release build
must preserve replaceability/relinking requirements where applicable, ship notices,
publish corresponding UxPlay source for the exact build, and receive legal review.

