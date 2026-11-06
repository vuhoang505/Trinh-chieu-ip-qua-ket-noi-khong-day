from __future__ import annotations

from pathlib import Path

from PySide6.QtCore import Qt
from PySide6.QtGui import QGuiApplication, QImage, QPainter
from PySide6.QtSvg import QSvgRenderer


root = Path(__file__).resolve().parents[1]
source = root / "assets" / "icons" / "app.svg"
target = source.with_suffix(".ico")

app = QGuiApplication.instance() or QGuiApplication([])
image = QImage(256, 256, QImage.Format_ARGB32)
image.fill(Qt.transparent)
painter = QPainter(image)
QSvgRenderer(str(source)).render(painter)
painter.end()
if not image.save(str(target), "ICO"):
    raise SystemExit(f"Could not generate {target}")
print("Generated assets/icons/app.ico")

