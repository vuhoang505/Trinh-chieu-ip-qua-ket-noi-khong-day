from __future__ import annotations

import logging
from logging.handlers import RotatingFileHandler
from pathlib import Path

from app.core.config import default_data_dir


def configure_logging(log_dir: Path | None = None) -> Path:
    directory = log_dir or (default_data_dir() / "logs")
    directory.mkdir(parents=True, exist_ok=True)
    path = directory / "mirror.log"
    root = logging.getLogger()
    root.setLevel(logging.INFO)
    if not any(isinstance(handler, RotatingFileHandler) for handler in root.handlers):
        handler = RotatingFileHandler(
            path, maxBytes=2_000_000, backupCount=3, encoding="utf-8"
        )
        handler.setFormatter(
            logging.Formatter("%(asctime)s | %(levelname)s | %(name)s | %(message)s")
        )
        root.addHandler(handler)
    return path

