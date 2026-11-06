[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$Python = Join-Path $ProjectRoot '.venv\Scripts\python.exe'
if (-not (Test-Path -LiteralPath $Python)) {
    throw 'Missing .venv. Run .\scripts\setup.ps1 first.'
}
Set-Location -LiteralPath $ProjectRoot
& $Python main.py

