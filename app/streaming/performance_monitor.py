from __future__ import annotations

import threading
import time
from collections import deque


class PerformanceMonitor:
    def __init__(self, sample_seconds: float = 2.0) -> None:
        self.sample_seconds = sample_seconds
        self._timestamps: deque[float] = deque()
        self._lock = threading.Lock()

    def tick(self) -> float:
        now = time.monotonic()
        with self._lock:
            self._timestamps.append(now)
            cutoff = now - self.sample_seconds
            while self._timestamps and self._timestamps[0] < cutoff:
                self._timestamps.popleft()
            if len(self._timestamps) < 2:
                return 0.0
            elapsed = self._timestamps[-1] - self._timestamps[0]
            return (len(self._timestamps) - 1) / elapsed if elapsed else 0.0

    def reset(self) -> None:
        with self._lock:
            self._timestamps.clear()

