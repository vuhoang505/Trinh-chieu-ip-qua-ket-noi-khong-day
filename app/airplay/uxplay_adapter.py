from __future__ import annotations

import logging
import os
import re
import shutil
import subprocess
import threading
from pathlib import Path

from app.airplay.receiver_adapter import (
    ReceiverAdapter,
    ReceiverOptions,
    ReceiverState,
)


LOGGER = logging.getLogger(__name__)


def find_uxplay(configured: str = "") -> Path | None:
    candidates: list[Path] = []
    if configured:
        candidates.append(Path(configured).expanduser())
    if os.environ.get("UXPLAY_PATH"):
        candidates.append(Path(os.environ["UXPLAY_PATH"]).expanduser())
    located = shutil.which("uxplay.exe") or shutil.which("uxplay")
    if located:
        candidates.append(Path(located))
    candidates.extend(
        [
            Path(__file__).resolve().parents[2] / "vendor" / "uxplay" / "uxplay.exe",
            Path.home() / "source" / "UxPlay" / "build" / "uxplay.exe",
            Path(r"C:\msys64\ucrt64\bin\uxplay.exe"),
            Path(r"C:\msys64\mingw64\bin\uxplay.exe"),
        ]
    )
    return next((path.resolve() for path in candidates if path.is_file()), None)


class UxPlayAdapter(ReceiverAdapter):
    """Owns the real UxPlay process and translates its output into app state."""

    _CONNECTED = re.compile(
        r"(raop connection|client.*connected|mirroring.*start|video session)", re.I
    )
    _DISCONNECTED = re.compile(
        r"(client.*disconnect|connection.*closed|mirroring.*stop|teardown|resetting)", re.I
    )
    _FATAL = re.compile(r"(fatal|segmentation fault|address already in use)", re.I)

    def __init__(self, status_callback, log_callback) -> None:
        super().__init__(status_callback, log_callback)
        self._process: subprocess.Popen[str] | None = None
        self._reader: threading.Thread | None = None
        self._lock = threading.RLock()
        self._stopping = False

    def command(self, options: ReceiverOptions) -> list[str]:
        pipeline = (
            f"config-interval=-1 pt=96 ! udpsink host=127.0.0.1 "
            f"port={options.rtp_port} sync=false async=false"
        )
        args = [
            str(options.executable),
            "-n",
            options.name,
            "-nh",
            "-s",
            f"{options.resolution}@{options.max_fps}",
            "-fps",
            str(options.max_fps),
            "-p",
            str(options.airplay_port_base),
            "-vrtp",
            pipeline,
            "-FPSdata",
            "-reset",
            "8",
            "-nofreeze",
            "-vol",
            f"{options.volume:.2f}",
        ]
        if options.pin_enabled:
            args.extend(["-pin"] + ([options.fixed_pin] if options.fixed_pin else []))
        if options.muted:
            args.extend(["-as", "0"])
        elif os.name == "nt":
            args.extend(["-as", "wasapisink"])
        if options.hardware_acceleration and os.name == "nt":
            args.extend(["-vd", "d3d11h264dec"])
        args.extend(options.extra_args)
        return args

    def start(self, options: ReceiverOptions) -> None:
        with self._lock:
            if self.is_running():
                return
            if not options.executable.is_file():
                raise FileNotFoundError(f"Không tìm thấy UxPlay: {options.executable}")
            self._stopping = False
            self.status_callback(ReceiverState.STARTING, "Đang khởi động UxPlay")
            creationflags = subprocess.CREATE_NO_WINDOW if os.name == "nt" else 0
            self._process = subprocess.Popen(
                self.command(options),
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                encoding="utf-8",
                errors="replace",
                bufsize=1,
                creationflags=creationflags,
                cwd=str(options.executable.parent),
                env=self._runtime_environment(options.executable),
            )
            self._reader = threading.Thread(
                target=self._read_output, name="uxplay-output", daemon=True
            )
            self._reader.start()
            self.status_callback(ReceiverState.WAITING, "Đang chờ iPhone")

    @staticmethod
    def _runtime_environment(executable: Path) -> dict[str, str]:
        """Expose the MSYS2 UCRT runtime without changing the user's system PATH."""
        environment = os.environ.copy()
        configured_runtime = environment.get("MSYS2_UCRT64_BIN", "").strip()
        candidates = ([Path(configured_runtime)] if configured_runtime else []) + [
            Path(r"C:\msys64\ucrt64\bin")
        ]
        runtime = next((path for path in candidates if path.is_dir()), None)
        if runtime is not None:
            current_path = environment.get("PATH", "")
            environment["PATH"] = f"{runtime}{os.pathsep}{current_path}"
            plugin_dir = runtime.parent / "lib" / "gstreamer-1.0"
            if plugin_dir.is_dir():
                environment.setdefault("GST_PLUGIN_PATH", str(plugin_dir))
        return environment

    def _read_output(self) -> None:
        process = self._process
        if process is None or process.stdout is None:
            return
        for raw_line in process.stdout:
            line = raw_line.strip()
            if not line:
                continue
            self.log_callback(line)
            LOGGER.info("UxPlay | %s", line)
            if self._CONNECTED.search(line):
                self.status_callback(ReceiverState.CONNECTED, "iPhone đã kết nối")
            elif self._DISCONNECTED.search(line) and not self._stopping:
                self.status_callback(ReceiverState.WAITING, "Đang chờ iPhone")
            elif self._FATAL.search(line):
                self.status_callback(ReceiverState.ERROR, line)
        return_code = process.wait()
        if not self._stopping and return_code != 0:
            self.status_callback(
                ReceiverState.ERROR, f"UxPlay đã dừng với mã lỗi {return_code}"
            )
        elif not self._stopping:
            self.status_callback(ReceiverState.STOPPED, "Receiver đã dừng")

    def stop(self) -> None:
        with self._lock:
            process = self._process
            if process is None:
                return
            self._stopping = True
            if process.poll() is None:
                process.terminate()
                try:
                    process.wait(timeout=4)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait(timeout=2)
            self._process = None
            self.status_callback(ReceiverState.STOPPED, "Receiver đã dừng")

    def is_running(self) -> bool:
        return self._process is not None and self._process.poll() is None

