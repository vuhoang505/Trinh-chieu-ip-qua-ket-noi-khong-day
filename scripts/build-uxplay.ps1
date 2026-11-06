[CmdletBinding()]
param(
    [string]$Source = "$env:USERPROFILE\source\UxPlay",
    [switch]$Execute
)

$ErrorActionPreference = 'Stop'
$Bash = 'C:\msys64\usr\bin\bash.exe'
if (-not (Test-Path -LiteralPath $Bash)) {
    throw 'MSYS2 is not installed at C:\msys64. Install it from https://www.msys2.org/ and retry.'
}

$Packages = @(
    'mingw-w64-ucrt-x86_64-cmake',
    'mingw-w64-ucrt-x86_64-gcc',
    'mingw-w64-ucrt-x86_64-ninja',
    'mingw-w64-ucrt-x86_64-libplist',
    'mingw-w64-ucrt-x86_64-gstreamer',
    'mingw-w64-ucrt-x86_64-gst-plugins-base',
    'mingw-w64-ucrt-x86_64-gst-plugins-good',
    'mingw-w64-ucrt-x86_64-gst-plugins-bad',
    'mingw-w64-ucrt-x86_64-gst-libav',
    'git'
)

$MsysSource = $Source.Replace('\', '/').Replace('C:', '/c')
$Install = "pacman -S --needed --noconfirm $($Packages -join ' ')"
$Build = "cd '$MsysSource' && mkdir -p build && cd build && cmake -G Ninja -DUSE_MDNS=1 -DNO_MARCH_NATIVE=ON .. && ninja"

Write-Host 'This builds UxPlay 1.74 source with its internal mDNS implementation.' -ForegroundColor Cyan
Write-Host "Source expected at: $Source"
Write-Host "Install command: $Install"
Write-Host "Build command:   $Build"
if ($Execute) {
    $env:MSYSTEM = 'UCRT64'
    $env:CHERE_INVOKING = '1'
    $env:MSYS2_PATH_TYPE = 'inherit'
    & $Bash -lc $Install
    if ($LASTEXITCODE -ne 0) { throw "pacman failed with exit code $LASTEXITCODE" }
    if (-not (Test-Path -LiteralPath $Source)) {
        $Parent = Split-Path -Parent $Source
        New-Item -ItemType Directory -Force -Path $Parent | Out-Null
        git clone https://github.com/FDH2/UxPlay $Source
        if ($LASTEXITCODE -ne 0) { throw "git clone failed with exit code $LASTEXITCODE" }
    }
    & $Bash -lc $Build
    if ($LASTEXITCODE -ne 0) { throw "UxPlay build failed with exit code $LASTEXITCODE" }
    $Executable = Join-Path $Source 'build\uxplay.exe'
    if (-not (Test-Path -LiteralPath $Executable)) {
        throw "Build completed without expected executable: $Executable"
    }
    Write-Host "UxPlay is ready: $Executable" -ForegroundColor Green
}

