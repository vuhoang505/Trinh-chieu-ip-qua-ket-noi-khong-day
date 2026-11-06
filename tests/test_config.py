from __future__ import annotations

import json

from app.core.config import AppConfig, ConfigStore


def test_config_round_trip(tmp_path):
    store = ConfigStore(tmp_path / "config.json")
    config = AppConfig(receiver_name="Phòng họp", max_fps=120, volume=3)
    store.save(config)
    loaded = store.load()
    assert loaded.receiver_name == "Phòng họp"
    assert loaded.max_fps == 60
    assert loaded.volume == 1.0


def test_unknown_and_invalid_values_are_safe(tmp_path):
    path = tmp_path / "config.json"
    path.write_text(json.dumps({"receiver_name": "Test", "unknown": 4}), encoding="utf-8")
    assert ConfigStore(path).load().receiver_name == "Test"
    path.write_text("not-json", encoding="utf-8")
    assert ConfigStore(path).load().receiver_name == "iPhone Wireless Mirror"

