#!/usr/bin/env bash
# Build the Matrix OS ISO in a throwaway Arch container (Docker or Podman).
# Builds the committed HEAD, so commit first. Output: ./dist/
#   ./build.sh            build the ISO
#   ./build.sh --test     build, then boot it in QEMU and run the self-test
set -euo pipefail
cd "$(dirname "$0")"
ENGINE=${ENGINE:-$(command -v docker || command -v podman)}
mkdir -p dist

# MSYS_NO_PATHCONV keeps Git Bash on Windows from rewriting /workspace
MSYS_NO_PATHCONV=1 "$ENGINE" run --privileged --rm -v "$PWD:/workspace" archlinux:latest bash -c '
  set -e
  pacman -Sy --noconfirm --needed git >/dev/null
  git config --global --add safe.directory "*"
  git clone -q /workspace /tmp/src
  bash /tmp/src/scripts/build-in-container.sh
' 2>&1 | tee dist/build.log

if [ "${1:-}" = "--test" ]; then
  exec ./scripts/selftest.sh
fi
