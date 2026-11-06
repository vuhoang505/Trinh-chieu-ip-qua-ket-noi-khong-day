from __future__ import annotations

from datetime import datetime
from pathlib import Path

from PySide6.QtGui import QImage


class ScreenshotService:
    def __init__(self, directory: str | Path) -> None:
        self.directory = Path(directory)

    def capture(self, image: QImage, extension: str = "png") -> Path:
        if image.isNull():
            raise RuntimeError("Chưa có khung hình để chụp")
        extension = extension.lower().lstrip(".")
        if extension not in {"png", "jpg", "jpeg"}:
            raise ValueError("Định dạng ảnh phải là PNG hoặc JPEG")
        self.directory.mkdir(parents=True, exist_ok=True)
        stamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")[:-3]
        target = self.directory / f"mirror_{stamp}.{extension}"
        if not image.save(str(target)):
            raise OSError(f"Không thể lưu ảnh: {target}")
        return target

    def list_files(self) -> list[Path]:
        if not self.directory.exists():
            return []
        return sorted(
            (p for p in self.directory.iterdir() if p.suffix.lower() in {".png", ".jpg", ".jpeg"}),
            key=lambda path: path.stat().st_mtime,
            reverse=True,
        )

