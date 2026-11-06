from __future__ import annotations

import json
import os
from dataclasses import asdict, dataclass, fields
from pathlib import Path
from typing import Any


APP_NAME = "iPhone Wireless Mirror"


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def default_data_dir() -> Path:
    base = Path(os.environ.get("LOCALAPPDATA", project_root()))
    return base / "iPhoneWirelessMirror"


@dataclass(slots=True)
class AppConfig:
    receiver_name: str = "iPhone Wireless Mirror"
    uxplay_path: str = ""
    video_rtp_port: int = 5000
    airplay_port_base: int = 7100
    max_fps: int = 60
    requested_resolution: str = "1920x1080"
    pin_enabled: bool = False
    fixed_pin: str = ""
    mute: bool = False
    volume: float = 1.0
    autostart_receiver: bool = False
    animations_enabled: bool = True
    hardware_acceleration: bool = True
    theme: str = "dark"
    language: str = "vi"
    recording_quality: str = "high"
    recording_fps: int = 30
    screenshots_dir: str = ""
    recordings_dir: str = ""

    def normalized(self) -> "AppConfig":
        root = default_data_dir()
        if not self.screenshots_dir:
            self.screenshots_dir = str(root / "screenshots")
        if not self.recordings_dir:
            self.recordings_dir = str(root / "recordings")
        self.video_rtp_port = min(65535, max(1024, int(self.video_rtp_port)))
        self.airplay_port_base = min(65533, max(1024, int(self.airplay_port_base)))
        self.max_fps = min(60, max(15, int(self.max_fps)))
        self.recording_fps = min(60, max(15, int(self.recording_fps)))
        self.volume = min(1.0, max(0.0, float(self.volume)))
        if self.fixed_pin and (len(self.fixed_pin) != 4 or not self.fixed_pin.isdigit()):
            self.fixed_pin = ""
        return self


class ConfigStore:
    def __init__(self, path: Path | None = None) -> None:
        self.path = path or (default_data_dir() / "config.json")

    def load(self) -> AppConfig:
        if not self.path.exists():
            return AppConfig().normalized()
        try:
            raw: dict[str, Any] = json.loads(self.path.read_text(encoding="utf-8"))
            allowed = {field.name for field in fields(AppConfig)}
            return AppConfig(**{k: v for k, v in raw.items() if k in allowed}).normalized()
        except (OSError, ValueError, TypeError, json.JSONDecodeError):
            return AppConfig().normalized()

    def save(self, config: AppConfig) -> None:
        config.normalized()
        self.path.parent.mkdir(parents=True, exist_ok=True)
        temporary = self.path.with_suffix(".tmp")
        temporary.write_text(
            json.dumps(asdict(config), ensure_ascii=False, indent=2), encoding="utf-8"
        )
        temporary.replace(self.path)

