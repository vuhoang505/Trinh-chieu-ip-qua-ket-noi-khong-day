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
        self._first_frame_received = False

    @property
    def running(self) -> bool:
        return self._thread is not None and self._thread.is_alive()

    def start(self) -> None:
        if self.running:
            return
        self._stop.clear()
        self._first_frame_received = False
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
        consecutive_failures = 0
        while not self._stop.is_set():
            retry_delay = 0.25
            try:
                decoded_any = self._decode_session()
                consecutive_failures = 0 if decoded_any else consecutive_failures + 1
            except (av.error.FFmpegError, OSError, RuntimeError, ValueError) as error:
                if self._stop.is_set():
                    break
                consecutive_failures += 1
                retry_delay = min(0.25 * (2 ** min(consecutive_failures - 1, 3)), 2.0)
                # Avoid flooding the log if FFmpeg opens in the middle of a
                # GOP and must wait for the next parameter set/keyframe.
                if consecutive_failures <= 3 or consecutive_failures % 10 == 0:
                    LOGGER.warning(
                        "Video RTP session interrupted; retry %s in %.2fs: %s",
                        consecutive_failures,
                        retry_delay,
                        error,
                    )
                if consecutive_failures == 3:
                    self.on_error("Đang tự khôi phục luồng hình ảnh RTP…")
            finally:
                container = self._container
                self._container = None
                if container is not None:
                    try:
                        container.close()
                    except Exception:
                        pass

            if not self._stop.is_set():
                # Exponential backoff avoids repeatedly reopening in the middle
                # of the same GOP, giving the payloader time to emit a fresh IDR.
                self._stop.wait(retry_delay)

    def _decode_session(self) -> bool:
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
        self._container = av.open(
            io.BytesIO(sdp.encode("ascii")),
            format="sdp",
            mode="r",
            options={
                "protocol_whitelist": "file,udp,rtp,crypto,data",
                # Let FFmpeg retain the first SPS/PPS/IDR while probing. The
                # previous nobuffer setup could consume and discard the only
                # initial iPhone keyframe, leaving audio alive but no picture.
                "analyzeduration": "1000000",
                "probesize": "1048576",
                "buffer_size": "2097152",
                # A finite read timeout lets stop() finish and lets this worker
                # rebind after AirPlay disconnects instead of dying forever.
                "rw_timeout": "2000000",
            },
        )
        stream = self._container.streams.video[0]
        # AUTO is more tolerant of the frame/slice layouts emitted by different
        # iOS versions. UI latency is controlled by latest-frame delivery.
        stream.thread_type = "AUTO"
        decoded_any = False
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
            decoded_any = True
            if not self._first_frame_received:
                self._first_frame_received = True
                LOGGER.info("First video frame decoded: %sx%s", width, height)
            self.on_frame(image, self.monitor.tick(), width, height)
        return decoded_any

