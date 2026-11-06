from __future__ import annotations

import logging
import io
import threading
from collections.abc import Callable

import av
from PySide6.QtGui import QImage

from app.streaming.performance_monitor import PerformanceMonitor


LOGGER = logging.getLogger(__name__)
FrameCallback = Callable[[QImage, float, int, int], None]


class VideoPipeline:
    """Decode UxPlay's loopback RTP output away from the Qt UI thread."""

    def __init__(self, port: int, on_frame: FrameCallback, on_error: Callable[[str], None]) -> None:
        self.port = port
        self.on_frame = on_frame
        self.on_error = on_error
        self.monitor = PerformanceMonitor()
        self._thread: threading.Thread | None = None
        self._stop = threading.Event()
        self._container: av.container.InputContainer | None = None

    @property
    def running(self) -> bool:
        return self._thread is not None and self._thread.is_alive()

    def start(self) -> None:
        if self.running:
            return
        self._stop.clear()
        self._thread = threading.Thread(
            target=self._decode, name="rtp-video-decoder", daemon=True
        )
        self._thread.start()

    def stop(self) -> None:
        self._stop.set()
        if self._thread and self._thread.is_alive():
            self._thread.join(timeout=3.0)
        self._thread = None
        self._container = None
        self.monitor.reset()

    def _decode(self) -> None:
        sdp = (
            "v=0\r\n"
            "o=- 0 0 IN IP4 127.0.0.1\r\n"
            "s=UxPlay Mirror\r\n"
            "c=IN IP4 127.0.0.1\r\n"
            "t=0 0\r\n"
            f"m=video {self.port} RTP/AVP 96\r\n"
            "a=rtpmap:96 H264/90000\r\n"
            "a=recvonly\r\n"
        )
        try:
            self._container = av.open(
                io.BytesIO(sdp.encode("ascii")),
                format="sdp",
                mode="r",
                options={
                    "protocol_whitelist": "file,udp,rtp,crypto,data",
                    "fflags": "nobuffer",
                    "flags": "low_delay",
                    "analyzeduration": "250000",
                    "probesize": "262144",
                    "max_delay": "0",
                    "reorder_queue_size": "0",
                    "rw_timeout": "1000000",
                },
            )
            stream = self._container.streams.video[0]
            # Slice threading does not hold complete frames waiting for other
            # frames, which keeps interactive mirroring latency predictable.
            stream.thread_type = "SLICE"
            for frame in self._container.decode(stream):
                if self._stop.is_set():
                    break
                converted = frame.reformat(format="bgra")
                width, height = converted.width, converted.height
                plane = converted.planes[0]
                pixel_data = bytes(plane)
                image = QImage(
                    pixel_data,
                    width,
                    height,
                    plane.line_size,
                    QImage.Format_ARGB32,
                ).copy()
                self.on_frame(image, self.monitor.tick(), width, height)
        except (av.error.FFmpegError, OSError, RuntimeError, ValueError) as error:
            if not self._stop.is_set():
                LOGGER.exception("Video pipeline stopped")
                self.on_error(f"Luồng video RTP bị dừng: {error}")
        finally:
            if self._container is not None:
                try:
                    self._container.close()
                except Exception:
                    pass
            self._container = None

