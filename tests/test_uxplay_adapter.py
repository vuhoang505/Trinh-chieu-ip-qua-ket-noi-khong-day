from __future__ import annotations

from pathlib import Path

from app.airplay.receiver_adapter import ReceiverOptions
from app.airplay.uxplay_adapter import UxPlayAdapter


def test_command_builds_real_rtp_pipeline(tmp_path):
    executable = tmp_path / "uxplay.exe"
    executable.touch()
    adapter = UxPlayAdapter(lambda *_: None, lambda *_: None)
    command = adapter.command(
        ReceiverOptions(
            name="Studio",
            executable=executable,
            rtp_port=5123,
            pin_enabled=True,
            fixed_pin="1234",
            muted=True,
        )
    )
    assert command[0] == str(executable)
    assert "-vrtp" in command
    assert "port=5123" in command[command.index("-vrtp") + 1]
    assert "config-interval=-1" in command[command.index("-vrtp") + 1]
    assert command[command.index("-pin") + 1] == "1234"
    assert "-as" in command and "0" in command


def test_stop_is_idempotent():
    adapter = UxPlayAdapter(lambda *_: None, lambda *_: None)
    adapter.stop()
    adapter.stop()
    assert not adapter.is_running()


def test_runtime_environment_adds_msys2_when_present(monkeypatch, tmp_path):
    runtime = tmp_path / "ucrt64" / "bin"
    plugins = tmp_path / "ucrt64" / "lib" / "gstreamer-1.0"
    runtime.mkdir(parents=True)
    plugins.mkdir(parents=True)
    monkeypatch.setenv("MSYS2_UCRT64_BIN", str(runtime))
    monkeypatch.setenv("PATH", "existing")
    environment = UxPlayAdapter._runtime_environment(tmp_path / "uxplay.exe")
    assert environment["PATH"].startswith(str(runtime))
    assert environment["GST_PLUGIN_PATH"] == str(plugins)

