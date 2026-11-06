from __future__ import annotations

import os
import sys
from pathlib import Path

from PySide6.QtCore import QCoreApplication, QTimer, QUrl, Qt
from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine

from app.core.config import ConfigStore, project_root
from app.core.event_bus import EventBus
from app.core.logging_manager import configure_logging
from app.streaming.frame_renderer import FrameImageProvider
from app.ui.controller import AppController


def run() -> int:
    os.environ.setdefault("QT_QUICK_CONTROLS_STYLE", "Basic")
    QCoreApplication.setAttribute(Qt.AA_EnableHighDpiScaling)
    app = QGuiApplication(sys.argv)
    app.setApplicationName("iPhone Wireless Mirror")
    app.setOrganizationName("Local Mirror")
    app.setWindowIcon(QIcon(str(project_root() / "assets" / "icons" / "app.svg")))
    configure_logging()

    store = ConfigStore()
    config = store.load()
    events = EventBus()
    provider = FrameImageProvider()
    controller = AppController(config, store, events, provider)
    engine = QQmlApplicationEngine()
    engine.addImageProvider("mirror", provider)
    engine.rootContext().setContextProperty("App", controller)
    qml_path = Path(__file__).resolve().parent / "qml" / "Main.qml"
    engine.load(QUrl.fromLocalFile(str(qml_path)))
    if not engine.rootObjects():
        controller.shutdown()
        return 1
    app.aboutToQuit.connect(controller.shutdown)
    if config.autostart_receiver:
        QTimer.singleShot(400, controller.startReceiver)
    smoke_exit_ms = int(os.environ.get("IWM_TEST_EXIT_MS", "0") or 0)
    if smoke_exit_ms > 0:
        QTimer.singleShot(smoke_exit_ms, app.quit)
    return app.exec()

