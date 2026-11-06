# -*- mode: python ; coding: utf-8 -*-
from pathlib import Path

root = Path(SPEC).resolve().parent
datas = [
    (str(root / "app" / "ui" / "qml"), "app/ui/qml"),
    (str(root / "assets"), "assets"),
]

a = Analysis(
    ["main.py"],
    pathex=[str(root)],
    binaries=[],
    datas=datas,
    hiddenimports=["av"],
    hookspath=[],
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
)
pyz = PYZ(a.pure)
exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name="iPhoneWirelessMirror",
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
    icon=str(root / "assets" / "icons" / "app.ico"),
)

