[CmdletBinding()]
param([switch]$Dev)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$VenvPython = Join-Path $ProjectRoot '.venv\Scripts\python.exe'
$TempRoot = Join-Path $ProjectRoot '.tmp'
New-Item -ItemType Directory -Force -Path $TempRoot | Out-Null
$env:TEMP = $TempRoot
$env:TMP = $TempRoot
$env:PYTHONUTF8 = '1'
$env:PYTHONIOENCODING = 'utf-8'
$env:PIP_PROGRESS_BAR = 'off'

if (-not (Test-Path -LiteralPath $VenvPython)) {
    Write-Host 'Creating isolated Python environment (.venv)...' -ForegroundColor Cyan
    python -m venv (Join-Path $ProjectRoot '.venv')
    if ($LASTEXITCODE -ne 0) { throw "venv creation failed with exit code $LASTEXITCODE" }
}

$PipPackage = Join-Path $ProjectRoot '.venv\Lib\site-packages\pip'
if (-not (Test-Path -LiteralPath $PipPackage)) {
    & $VenvPython -m ensurepip --upgrade --default-pip
    if ($LASTEXITCODE -ne 0) { throw "ensurepip failed with exit code $LASTEXITCODE" }
}

Write-Host 'Updating pip inside .venv...' -ForegroundColor Cyan
& $VenvPython -m pip install --upgrade pip
if ($LASTEXITCODE -ne 0) { throw "pip upgrade failed with exit code $LASTEXITCODE" }
$Requirements = if ($Dev) { 'requirements-dev.txt' } else { 'requirements.txt' }
Write-Host "Installing $Requirements..." -ForegroundColor Cyan
& $VenvPython -m pip install -r (Join-Path $ProjectRoot $Requirements)
if ($LASTEXITCODE -ne 0) { throw "dependency installation failed with exit code $LASTEXITCODE" }

Write-Host 'Python environment is ready.' -ForegroundColor Green
& (Join-Path $PSScriptRoot 'check-native.ps1')

