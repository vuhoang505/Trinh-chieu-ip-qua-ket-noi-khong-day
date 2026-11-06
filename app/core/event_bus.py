from __future__ import annotations

from PySide6.QtCore import QObject, Signal


class EventBus(QObject):
    receiver_status = Signal(str, str)
    device_connected = Signal(str)
    device_disconnected = Signal()
    frame_available = Signal(object)
    error = Signal(str)
    notification = Signal(str, str)

