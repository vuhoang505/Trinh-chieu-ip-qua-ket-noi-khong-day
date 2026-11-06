from __future__ import annotations

import logging
import threading
import time
from pathlib import Path

from PySide6.QtCore import Property, QObject, QTimer, QUrl, Signal, Slot
from PySide6.QtGui import QDesktopServices, QImage

from app.airplay.receiver_manager import ReceiverManager
from app.core.config import AppConfig, ConfigStore
from app.core.event_bus import EventBus
from app.services.recording_service import RecordingService
from app.services.screenshot_service import ScreenshotService
from app.streaming.frame_renderer import FrameImageProvider
from app.streaming.video_pipeline import VideoPipeline


LOGGER = logging.getLogger(__name__)


class AppController(QObject):
    statusChanged = Signal()
    metricsChanged = Signal()
    frameChanged = Signal()
    recordingChanged = Signal()
    settingsChanged = Signal()
    displayChanged = Signal()
    toast = Signal(str, str)
    _frameReady = Signal()

    def __init__(
        self,
        config: AppConfig,
        store: ConfigStore,
        events: EventBus,
        provider: FrameImageProvider,
    ) -> None:
        super().__init__()
        self.config = config
        self.store = store
        self.events = events
        self.provider = provider
        self.receiver = ReceiverManager(config, events)
        self.pipeline = VideoPipeline(
            config.video_rtp_port, self._publish_frame, self._publish_video_error
        )
        self.screenshots = ScreenshotService(config.screenshots_dir)
        self.recorder = RecordingService(
            config.recordings_dir, config.recording_fps, config.recording_quality
        )
        self._status = "stopped"
        self._status_detail = "Receiver chưa chạy"
        self._fps = 0.0
        self._width = 0
        self._height = 0
        self._has_frame = False
        self._frame_serial = 0
        self._rotation = 0
        self._pending_frame: tuple[QImage, float, int, int] | None = None
        self._frame_delivery_scheduled = False
        self._frame_lock = threading.Lock()
        self._record_started = 0.0
        self._record_seconds = 0
        self._muted = config.mute
        self._frameReady.connect(self._accept_latest_frame)
        events.receiver_status.connect(self._on_receiver_status)
        events.notification.connect(self.toast)
        self._record_timer = QTimer(self)
        self._record_timer.setInterval(500)
        self._record_timer.timeout.connect(self._update_record_time)

    @Property(str, notify=statusChanged)
    def status(self) -> str:
        return self._status

    @Property(str, notify=statusChanged)
    def statusDetail(self) -> str:  # noqa: N802
        return self._status_detail

    @Property(bool, notify=statusChanged)
    def receiverRunning(self) -> bool:  # noqa: N802
        return self._status in {"starting", "waiting", "connected"}

    @Property(bool, notify=frameChanged)
    def hasFrame(self) -> bool:  # noqa: N802
        return self._has_frame

    @Property(int, notify=frameChanged)
    def frameSerial(self) -> int:  # noqa: N802
        return self._frame_serial

    @Property(int, notify=metricsChanged)
    def videoWidth(self) -> int:  # noqa: N802
        return self._width

    @Property(int, notify=metricsChanged)
    def videoHeight(self) -> int:  # noqa: N802
        return self._height

    @Property(float, notify=displayChanged)
    def displayAspectRatio(self) -> float:  # noqa: N802
        if not self._width or not self._height:
            return 9.0 / 16.0
        if self._rotation % 180:
            return self._height / self._width
        return self._width / self._height

    @Property(int, notify=displayChanged)
    def rotation(self) -> int:
        return self._rotation

    @Property(float, notify=metricsChanged)
    def fps(self) -> float:
        return round(self._fps, 1)

    @Property(str, notify=metricsChanged)
    def resolution(self) -> str:
        return f"{self._width} × {self._height}" if self._width else "—"

    @Property(bool, notify=recordingChanged)
    def recording(self) -> bool:
        return self.recorder.active

    @Property(bool, notify=recordingChanged)
    def recordingPaused(self) -> bool:  # noqa: N802
        return self.recorder.paused

    @Property(str, notify=recordingChanged)
    def recordingTime(self) -> str:  # noqa: N802
        minutes, seconds = divmod(self._record_seconds, 60)
        return f"{minutes:02d}:{seconds:02d}"

    @Property(bool, notify=settingsChanged)
    def muted(self) -> bool:
        return self._muted

    @Property(str, notify=settingsChanged)
    def receiverName(self) -> str:  # noqa: N802
        return self.config.receiver_name

    @Property(str, notify=settingsChanged)
    def screenshotsPath(self) -> str:  # noqa: N802
        return self.config.screenshots_dir

    @Property(str, notify=settingsChanged)
    def recordingsPath(self) -> str:  # noqa: N802
        return self.config.recordings_dir

    @Property(bool, notify=settingsChanged)
    def animationsEnabled(self) -> bool:  # noqa: N802
        return self.config.animations_enabled

    @Slot()
    def startReceiver(self) -> None:  # noqa: N802
        if not self.pipeline.running:
            self.pipeline.start()
        self.receiver.start()

    @Slot()
    def stopReceiver(self) -> None:  # noqa: N802
        self.receiver.stop()
        self.pipeline.stop()
        self._reset_stream()

    @Slot()
    def captureScreenshot(self) -> None:  # noqa: N802
        try:
            path = self.screenshots.capture(self.provider.current())
            self.toast.emit("Đã chụp màn hình", str(path))
        except Exception as error:
            self.toast.emit("Không thể chụp", str(error))

    @Slot()
    def toggleRecording(self) -> None:  # noqa: N802
        try:
            if self.recorder.active:
                path = self.recorder.stop()
                self._record_timer.stop()
                self.toast.emit("Đã lưu bản ghi", str(path))
            else:
                if not self._has_frame:
                    raise RuntimeError("Chưa có luồng hình ảnh để ghi")
                path = self.recorder.start()
                self._record_started = time.monotonic()
                self._record_seconds = 0
                self._record_timer.start()
                self.toast.emit("Đang ghi hình", str(path))
            self.recordingChanged.emit()
        except Exception as error:
            LOGGER.exception("Recording action failed")
            self.toast.emit("Không thể ghi hình", str(error))

    @Slot()
    def toggleRecordingPause(self) -> None:  # noqa: N802
        if self.recorder.active:
            self.recorder.pause(not self.recorder.paused)
            self.recordingChanged.emit()

    @Slot()
    def toggleMute(self) -> None:  # noqa: N802
        self._muted = not self._muted
        self.config.mute = self._muted
        self.store.save(self.config)
        self.settingsChanged.emit()
        if self.receiver.adapter.is_running():
            self.toast.emit("Âm thanh", "Đang khởi động lại receiver để áp dụng")
            self.receiver.restart()

    @Slot()
    def rotateClockwise(self) -> None:  # noqa: N802
        self._rotation = (self._rotation + 90) % 360
        self.displayChanged.emit()

    @Slot()
    def resetRotation(self) -> None:  # noqa: N802
        if self._rotation:
            self._rotation = 0
            self.displayChanged.emit()

    @Slot(str, str, str, bool)
    def saveSettings(
        self, receiver_name: str, screenshots_path: str, recordings_path: str, animations: bool
    ) -> None:  # noqa: N802
        receiver_name = receiver_name.strip()
        if not receiver_name:
            self.toast.emit("Cài đặt", "Tên receiver không được để trống")
            return
        needs_restart = receiver_name != self.config.receiver_name
        self.config.receiver_name = receiver_name
        self.config.screenshots_dir = screenshots_path.strip() or self.config.screenshots_dir
        self.config.recordings_dir = recordings_path.strip() or self.config.recordings_dir
        self.config.animations_enabled = animations
        self.screenshots.directory = Path(self.config.screenshots_dir)
        self.recorder.directory = Path(self.config.recordings_dir)
        self.store.save(self.config)
        self.settingsChanged.emit()
        self.toast.emit("Cài đặt", "Đã lưu trên máy")
        if needs_restart and self.receiver.adapter.is_running():
            self.receiver.restart()

    @Slot(str)
    def openPath(self, path: str) -> None:  # noqa: N802
        target = Path(path)
        target.mkdir(parents=True, exist_ok=True)
        QDesktopServices.openUrl(QUrl.fromLocalFile(str(target.resolve())))

    @Slot()
    def shutdown(self) -> None:
        try:
            self.recorder.stop()
        finally:
            self.receiver.stop()
            self.pipeline.stop()

    def _publish_frame(self, image: QImage, fps: float, width: int, height: int) -> None:
        # Decode can be faster than QML rendering. Keep only the newest frame
        # instead of building an ever-growing queued-signal backlog.
        should_schedule = False
        with self._frame_lock:
            self._pending_frame = (image, fps, width, height)
            if not self._frame_delivery_scheduled:
                self._frame_delivery_scheduled = True
                should_schedule = True
        if should_schedule:
            self._frameReady.emit()

    def _publish_video_error(self, message: str) -> None:
        LOGGER.error("Video pipeline: %s", message)
        self.toast.emit("Video", message)

    @Slot()
    def _accept_latest_frame(self) -> None:
        with self._frame_lock:
            pending = self._pending_frame
            self._pending_frame = None
            self._frame_delivery_scheduled = False
        if pending is None:
            return
        image, fps, width, height = pending
        self.provider.update(image)
        if self.recorder.active:
            self.recorder.add_frame(image)
        self._fps = fps
        self._width = width
        self._height = height
        self._has_frame = True
        self._frame_serial += 1
        if self._status == "waiting":
            self._status = "connected"
            self._status_detail = "Đang nhận màn hình iPhone"
            self.statusChanged.emit()
        self.metricsChanged.emit()
        self.displayChanged.emit()
        self.frameChanged.emit()

    @Slot(str, str)
    def _on_receiver_status(self, status: str, detail: str) -> None:
        self._status = status
        self._status_detail = detail
        if status in {"stopped", "error"}:
            self._reset_stream()
        self.statusChanged.emit()

    def _reset_stream(self) -> None:
        with self._frame_lock:
            self._pending_frame = None
        self._fps = 0.0
        self._width = 0
        self._height = 0
        self._has_frame = False
        self.metricsChanged.emit()
        self.frameChanged.emit()

    def _update_record_time(self) -> None:
        if self.recorder.active and not self.recorder.paused:
            self._record_seconds = int(time.monotonic() - self._record_started)
            self.recordingChanged.emit()

