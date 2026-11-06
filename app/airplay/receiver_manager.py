from __future__ import annotations

import logging
import threading

from app.airplay.receiver_adapter import ReceiverOptions, ReceiverState
from app.airplay.uxplay_adapter import UxPlayAdapter, find_uxplay
from app.core.config import AppConfig
from app.core.event_bus import EventBus


LOGGER = logging.getLogger(__name__)


class ReceiverManager:
    def __init__(self, config: AppConfig, events: EventBus) -> None:
        self.config = config
        self.events = events
        self.state = ReceiverState.STOPPED
        self.detail = "Receiver chưa chạy"
        self._lock = threading.RLock()
        self.adapter = UxPlayAdapter(self._on_status, self._on_log)

    def _options(self) -> ReceiverOptions:
        executable = find_uxplay(self.config.uxplay_path)
        if executable is None:
            raise FileNotFoundError(
                "Chưa cài UxPlay. Chạy scripts/check-native.ps1 và xem README."
            )
        return ReceiverOptions(
            name=self.config.receiver_name,
            executable=executable,
            rtp_port=self.config.video_rtp_port,
            airplay_port_base=self.config.airplay_port_base,
            max_fps=self.config.max_fps,
            resolution=self.config.requested_resolution,
            pin_enabled=self.config.pin_enabled,
            fixed_pin=self.config.fixed_pin,
            muted=self.config.mute,
            volume=self.config.volume,
            hardware_acceleration=self.config.hardware_acceleration,
        )

    def start(self) -> None:
        with self._lock:
            try:
                self.adapter.start(self._options())
            except Exception as error:
                LOGGER.exception("Could not start receiver")
                self._on_status(ReceiverState.ERROR, str(error))

    def stop(self) -> None:
        with self._lock:
            self.adapter.stop()

    def restart(self) -> None:
        self.stop()
        self.start()

    def _on_status(self, state: ReceiverState, detail: str) -> None:
        self.state = state
        self.detail = detail
        self.events.receiver_status.emit(state.value, detail)

    def _on_log(self, line: str) -> None:
        if "deviceID" in line or "model" in line.lower():
            self.events.notification.emit("UxPlay", line)

