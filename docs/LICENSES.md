# Dependency and redistribution notes

This document is an engineering checklist, not legal advice.

- **UxPlay** — GPL-3.0. If distributed, include its license, notices, the exact
  corresponding source (including build scripts/patches), and comply with GPL terms.
- **GStreamer** — core and many plugins are LGPL-2.1-or-later; individual plugins and
  codec dependencies may differ. Audit the exact DLL/plugin bundle.
- **PySide6 / Qt** — LGPL-3.0/GPL/commercial components. Preserve user relinking and
  other LGPL requirements or use an appropriate commercial license.
- **PyAV / FFmpeg libraries** — PyAV is BSD-3-Clause; FFmpeg configuration determines
  LGPL/GPL status. The wheel's codecs and build flags must be audited before shipping.
- **OpenSSL, libplist, MSYS2 runtime** — retain their license texts and notices.

The development package does not redistribute UxPlay or GStreamer binaries. The
`vendor/uxplay` directory is a documented runtime location only.

