[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$Python = Join-Path $ProjectRoot '.venv\Scripts\python.exe'
if (-not (Test-Path -LiteralPath $Python)) { throw 'Run scripts\setup.ps1 -Dev first.' }
Set-Location -LiteralPath $ProjectRoot
if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot 'assets\icons\app.ico'))) {
    & $Python (Join-Path $PSScriptRoot 'generate_icon.py')
    if ($LASTEXITCODE -ne 0) { throw 'Icon generation failed.' }
}
& $Python -m PyInstaller --noconfirm iphone_mirror.spec

