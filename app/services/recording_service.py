from __future__ import annotations

import logging
import threading
from datetime import datetime
from pathlib import Path

import av
from PySide6.QtGui import QImage


LOGGER = logging.getLogger(__name__)


class RecordingService:
    """Encode actual decoded frames to MP4 on the decoder thread."""

    BITRATES = {"low": 3_000_000, "medium": 6_000_000, "high": 10_000_000}

    def __init__(self, directory: str | Path, fps: int = 30, quality: str = "high") -> None:
        self.directory = Path(directory)
        self.fps = fps
        self.quality = quality
        self._container: av.container.OutputContainer | None = None
        self._stream = None
        self._path: Path | None = None
        self._lock = threading.RLock()
        self._paused = False
        self._size: tuple[int, int] | None = None

    @property
    def active(self) -> bool:
        return self._container is not None

    @property
    def paused(self) -> bool:
        return self._paused

    @property
    def path(self) -> Path | None:
        return self._path

    def start(self) -> Path:
        with self._lock:
            if self.active:
                return self._path  # type: ignore[return-value]
            self.directory.mkdir(parents=True, exist_ok=True)
            stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            self._path = self.directory / f"mirror_{stamp}.mp4"
            self._container = av.open(str(self._path), mode="w")
            self._paused = False
            self._size = None
            return self._path

    def add_frame(self, image: QImage) -> None:
        with self._lock:
            if not self.active or self._paused or image.isNull():
                return
            converted = image.convertToFormat(QImage.Format_RGB888)
            width, height = converted.width(), converted.height()
            width -= width % 2
            height -= height % 2
            if self._stream is None:
                self._stream = self._container.add_stream("libx264", rate=self.fps)
                self._stream.width = width
                self._stream.height = height
                self._stream.pix_fmt = "yuv420p"
                self._stream.bit_rate = self.BITRATES.get(self.quality, 10_000_000)
                self._stream.options = {"preset": "veryfast", "tune": "zerolatency"}
                self._size = (width, height)
            if self._size != (width, height):
                converted = converted.scaled(*self._size)
                width, height = self._size
            ptr = converted.bits()
            raw = bytes(ptr[: converted.sizeInBytes()])
            frame = av.VideoFrame(width, height, "rgb24")
            frame.planes[0].update(raw)
            for packet in self._stream.encode(frame):
                self._container.mux(packet)

    def pause(self, paused: bool = True) -> None:
        with self._lock:
            self._paused = paused

    def stop(self) -> Path | None:
        with self._lock:
            if self._container is None:
                return self._path
            try:
                if self._stream is not None:
                    for packet in self._stream.encode():
                        self._container.mux(packet)
            finally:
                self._container.close()
                self._container = None
                self._stream = None
                self._paused = False
                self._size = None
            return self._path

