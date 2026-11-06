from __future__ import annotations

import av
from PySide6.QtGui import QColor, QImage

from app.services.recording_service import RecordingService


def test_recording_writes_playable_mp4(tmp_path):
    image = QImage(64, 64, QImage.Format_RGB32)
    image.fill(QColor("#4466aa"))
    service = RecordingService(tmp_path, fps=30, quality="low")
    path = service.start()
    for _ in range(4):
        service.add_frame(image)
    assert service.stop() == path
    assert path.exists() and path.stat().st_size > 0
    with av.open(str(path)) as container:
        assert len(container.streams.video) == 1

