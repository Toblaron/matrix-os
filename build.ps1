# Build the Matrix OS ISO from Windows with Docker Desktop.
# Builds the committed HEAD, so commit first. Output: .\dist\
#   .\build.ps1          build the ISO
#   .\build.ps1 -Test    build, then boot it in QEMU and run the self-test
param([switch]$Test)
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
New-Item -ItemType Directory -Force dist | Out-Null

docker info *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host 'Starting Docker Desktop...'
    Start-Process "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
    do { Start-Sleep 3; docker info *> $null } until ($LASTEXITCODE -eq 0)
}

$inner = 'set -e; pacman -Sy --noconfirm --needed git >/dev/null; ' +
         'git config --global --add safe.directory "*"; ' +
         'git clone -q /workspace /tmp/src; bash /tmp/src/scripts/build-in-container.sh'
docker run --privileged --rm -v "${PWD}:/workspace" archlinux:latest bash -c $inner 2>&1 |
    Tee-Object -FilePath dist\build.log
if ($LASTEXITCODE -ne 0) { throw 'ISO build failed, see dist\build.log' }

if ($Test) {
    docker run --privileged --rm -v "${PWD}:/workspace" archlinux:latest bash /workspace/scripts/selftest-in-container.sh
}
