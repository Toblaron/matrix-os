#!/usr/bin/env bash
set -e
sudo pacman -S --needed --noconfirm archiso
sudo rm -rf /tmp/matrix-archiso-work
sudo mkarchiso -v -w /tmp/matrix-archiso-work -o ./dist .
