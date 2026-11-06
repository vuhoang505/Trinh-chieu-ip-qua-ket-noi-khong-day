from __future__ import annotations

import pytest

from app.core.config import AppConfig, ConfigStore
from app.core.event_bus import EventBus
from app.streaming.frame_renderer import FrameImageProvider
from app.ui.controller import AppController


def test_display_aspect_ratio_tracks_manual_rotation(tmp_path):
    controller = AppController(
        AppConfig(),
        ConfigStore(tmp_path / "config.json"),
        EventBus(),
        FrameImageProvider(),
    )
    controller._width = 1920
    controller._height = 1080

    assert controller.displayAspectRatio == pytest.approx(16 / 9)
    controller.rotateClockwise()
    assert controller.rotation == 90
    assert controller.displayAspectRatio == pytest.approx(9 / 16)

    controller.resetRotation()
    assert controller.rotation == 0
    assert controller.displayAspectRatio == pytest.approx(16 / 9)
