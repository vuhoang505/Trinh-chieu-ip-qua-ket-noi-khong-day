[CmdletBinding()]
param()

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$Candidates = @(
    $env:UXPLAY_PATH,
    (Join-Path $ProjectRoot 'vendor\uxplay\uxplay.exe'),
    (Join-Path $env:USERPROFILE 'source\UxPlay\build\uxplay.exe'),
    'C:\msys64\ucrt64\bin\uxplay.exe',
    'C:\msys64\mingw64\bin\uxplay.exe'
) | Where-Object { $_ }

$UxPlay = $null
foreach ($Candidate in $Candidates) {
    if (Test-Path -LiteralPath $Candidate -PathType Leaf) {
        $UxPlay = (Resolve-Path -LiteralPath $Candidate).Path
        break
    }
}
if (-not $UxPlay) {
    $Command = Get-Command uxplay.exe -ErrorAction SilentlyContinue
    if ($Command) { $UxPlay = $Command.Source }
}

Write-Host ''
Write-Host 'Native dependency report' -ForegroundColor Cyan
if ($UxPlay) {
    Write-Host "[OK] UxPlay: $UxPlay" -ForegroundColor Green
    $PreviousPath = $env:PATH
    $PreviousPluginPath = $env:GST_PLUGIN_PATH
    $Runtime = 'C:\msys64\ucrt64\bin'
    if (Test-Path -LiteralPath $Runtime) {
        $env:PATH = "$Runtime;$env:PATH"
        $env:GST_PLUGIN_PATH = 'C:\msys64\ucrt64\lib\gstreamer-1.0'
    }
    try { & $UxPlay -h 2>&1 | Select-Object -First 2 }
    catch { Write-Warning "UxPlay was found but could not run: $($_.Exception.Message)" }
    finally {
        $env:PATH = $PreviousPath
        $env:GST_PLUGIN_PATH = $PreviousPluginPath
    }
} else {
    Write-Host '[MISSING] uxplay.exe' -ForegroundColor Yellow
    Write-Host 'Build UxPlay >= 1.73 with MSYS2/GStreamer, then set UXPLAY_PATH or copy it to vendor\uxplay.'
}

$Msys = 'C:\msys64\usr\bin\bash.exe'
if (Test-Path -LiteralPath $Msys) {
    Write-Host "[OK] MSYS2: $Msys" -ForegroundColor Green
} else {
    Write-Host '[OPTIONAL] MSYS2 not found. It is required to build UxPlay, not to run a self-contained bundle.' -ForegroundColor DarkYellow
}

$VenvPython = Join-Path $ProjectRoot '.venv\Scripts\python.exe'
if (Test-Path -LiteralPath $VenvPython) {
    & $VenvPython -c "import PySide6, av; print('[OK] PySide6', PySide6.__version__, '| PyAV', av.__version__)"
} else {
    Write-Host '[MISSING] .venv — run scripts\setup.ps1' -ForegroundColor Yellow
}

if (-not $UxPlay) { exit 2 }

