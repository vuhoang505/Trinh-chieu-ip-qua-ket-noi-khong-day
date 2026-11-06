from __future__ import annotations

import os
import subprocess
import sys
import threading
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.streaming.video_pipeline import VideoPipeline


port = 5199
received = threading.Event()
frames = 0
errors: list[str] = []


def on_frame(image, fps: float, width: int, height: int) -> None:
    global frames
    frames += 1
    if frames == 1:
        print(f"FIRST_FRAME={width}x{height} FPS={fps:.1f}")
    received.set()


def on_error(message: str) -> None:
    errors.append(message)
    print(f"PIPELINE_ERROR={message}")


pipeline = VideoPipeline(port, on_frame, on_error)
pipeline.start()
runtime = Path(r"C:\msys64\ucrt64\bin")
environment = os.environ.copy()
environment["PATH"] = f"{runtime}{os.pathsep}{environment.get('PATH', '')}"
environment["GST_PLUGIN_PATH"] = str(runtime.parent / "lib" / "gstreamer-1.0")
sender = subprocess.Popen(
    [
        str(runtime / "gst-launch-1.0.exe"),
        "-q",
        "videotestsrc",
        "num-buffers=120",
        "is-live=true",
        "!",
        "video/x-raw,width=320,height=240,framerate=30/1",
        "!",
        "videoconvert",
        "!",
        "openh264enc",
        "bitrate=500000",
        "!",
        "h264parse",
        "!",
        "rtph264pay",
        "config-interval=1",
        "pt=96",
        "!",
        "udpsink",
        "host=127.0.0.1",
        f"port={port}",
        "sync=false",
    ],
    env=environment,
)
received.wait(timeout=8)
if received.is_set():
    time.sleep(1.0)
sender.terminate()
try:
    sender.wait(timeout=3)
except subprocess.TimeoutExpired:
    sender.kill()
pipeline.stop()
print(f"FRAMES={frames}")
raise SystemExit(0 if frames > 0 else 1)

