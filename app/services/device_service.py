from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

from app.core.config import default_data_dir


class DeviceService:
    def __init__(self, path: Path | None = None) -> None:
        self.path = path or (default_data_dir() / "devices.json")

    def list(self) -> list[dict[str, str]]:
        try:
            value = json.loads(self.path.read_text(encoding="utf-8"))
            return value if isinstance(value, list) else []
        except (OSError, ValueError):
            return []

    def remember(self, identifier: str, name: str) -> None:
        devices = [item for item in self.list() if item.get("id") != identifier]
        devices.insert(
            0,
            {
                "id": identifier,
                "name": name,
                "last_seen": datetime.now(timezone.utc).isoformat(),
            },
        )
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.write_text(json.dumps(devices[:50], indent=2), encoding="utf-8")

    def clear(self) -> None:
        if self.path.exists():
            self.path.unlink()

