from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import Callable


class ReceiverState(str, Enum):
    STOPPED = "stopped"
    STARTING = "starting"
    WAITING = "waiting"
    CONNECTED = "connected"
    ERROR = "error"


@dataclass(slots=True)
class ReceiverOptions:
    name: str
    executable: Path
    rtp_port: int = 5000
    airplay_port_base: int = 7100
    max_fps: int = 60
    resolution: str = "1920x1080"
    pin_enabled: bool = False
    fixed_pin: str = ""
    muted: bool = False
    volume: float = 1.0
    hardware_acceleration: bool = True
    extra_args: list[str] = field(default_factory=list)


StatusCallback = Callable[[ReceiverState, str], None]
LogCallback = Callable[[str], None]


class ReceiverAdapter(ABC):
    def __init__(self, status_callback: StatusCallback, log_callback: LogCallback) -> None:
        self.status_callback = status_callback
        self.log_callback = log_callback

    @abstractmethod
    def start(self, options: ReceiverOptions) -> None: ...

    @abstractmethod
    def stop(self) -> None: ...

    @abstractmethod
    def is_running(self) -> bool: ...

    @abstractmethod
    def command(self, options: ReceiverOptions) -> list[str]: ...

