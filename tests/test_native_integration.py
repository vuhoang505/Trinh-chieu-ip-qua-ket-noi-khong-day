from __future__ import annotations

import os
import subprocess

import pytest

from app.airplay.uxplay_adapter import UxPlayAdapter, find_uxplay


@pytest.mark.integration
def test_installed_uxplay_reports_help():
    path = find_uxplay(os.environ.get("UXPLAY_PATH", ""))
    if path is None:
        pytest.skip("No native UxPlay executable is installed")
    result = subprocess.run(
        [str(path), "-h"],
        capture_output=True,
        text=True,
        timeout=10,
        env=UxPlayAdapter._runtime_environment(path),
    )
    combined = result.stdout + result.stderr
    assert "UxPlay" in combined
    assert "-vrtp" in combined


@pytest.mark.e2e
def test_physical_iphone_mirroring():
    pytest.skip("CHƯA XÁC MINH: requires a physical iPhone and manual visual confirmation")

