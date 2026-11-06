from __future__ import annotations

from PySide6.QtGui import QColor, QImage

from app.services.screenshot_service import ScreenshotService


def test_capture_real_qimage(tmp_path):
    image = QImage(32, 48, QImage.Format_RGB32)
    image.fill(QColor("#336699"))
    service = ScreenshotService(tmp_path)
    result = service.capture(image)
    assert result.exists()
    assert result.suffix == ".png"
    assert service.list_files() == [result]

