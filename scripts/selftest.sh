#!/usr/bin/env bash
# Boot the newest ISO in dist/ under QEMU and run the Matrix OS self-test.
set -euo pipefail
cd "$(dirname "$0")/.."
ENGINE=${ENGINE:-$(command -v docker || command -v podman)}
MSYS_NO_PATHCONV=1 "$ENGINE" run --privileged --rm -v "$PWD:/workspace" archlinux:latest \
  bash /workspace/scripts/selftest-in-container.sh
