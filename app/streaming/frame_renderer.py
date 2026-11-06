from __future__ import annotations

import threading

from PySide6.QtCore import QSize, Qt
from PySide6.QtGui import QImage
from PySide6.QtQuick import QQuickImageProvider


class FrameImageProvider(QQuickImageProvider):
    def __init__(self) -> None:
        super().__init__(QQuickImageProvider.Image)
        self._image = QImage()
        self._lock = threading.Lock()

    def update(self, image: QImage) -> None:
        with self._lock:
            self._image = image.copy()

    def current(self) -> QImage:
        with self._lock:
            return self._image.copy()

    def requestImage(self, image_id: str, size: QSize, requested_size: QSize):  # noqa: N802
        del image_id
        image = self.current()
        if image.isNull():
            image = QImage(2, 2, QImage.Format_RGB32)
            image.fill(0x10131F)
        if requested_size.isValid():
            image = image.scaled(
                requested_size,
                aspectMode=Qt.KeepAspectRatio,
                mode=Qt.SmoothTransformation,
            )
        size.setWidth(image.width())
        size.setHeight(image.height())
        return image

