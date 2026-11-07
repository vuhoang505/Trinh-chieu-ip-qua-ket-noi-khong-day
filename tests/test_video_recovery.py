from __future__ import annotations

import threading

from PySide6.QtGui import QImage

from app.core.config import AppConfig, ConfigStore
from app.core.event_bus import EventBus
from app.streaming.frame_renderer import FrameImageProvider
from app.streaming.video_pipeline import VideoPipeline
from app.ui.controller import AppController


def test_controller_delivers_frame_from_decoder_thread(qtbot, tmp_path):
    provider = FrameImageProvider()
    controller = AppController(
        AppConfig(),
        ConfigStore(tmp_path / "config.json"),
        EventBus(),
        provider,
    )
    frame = QImage(8, 6, QImage.Format_ARGB32)
    frame.fill(0xFF3366CC)

    worker = threading.Thread(
        target=lambda: controller._publish_frame(frame, 59.8, 8, 6), daemon=True
    )
    worker.start()
    worker.join(timeout=1)

    qtbot.waitUntil(lambda: controller.hasFrame, timeout=1000)
    assert controller.frameSerial == 1
    assert controller.resolution == "8 × 6"
    assert not provider.current().isNull()


def test_pipeline_retries_instead_of_dying_after_rtp_timeout():
    errors: list[str] = []
    pipeline = VideoPipeline(5198, lambda *_: None, errors.append)
    attempts = 0

    def fake_session() -> bool:
        nonlocal attempts
        attempts += 1
        if attempts <= 3:
            raise OSError("simulated RTP timeout")
        pipeline._stop.set()
        return False

    pipeline._decode_session = fake_session  # type: ignore[method-assign]
    pipeline._decode()

    assert attempts == 4
    assert errors == ["Đang tự khôi phục luồng hình ảnh RTP…"]
