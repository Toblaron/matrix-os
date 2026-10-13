#!/usr/bin/env bash
# Fast desktop check without building an ISO: runs Wayfire headless with the
# Matrix OS skel config, the HUD and waybar, then screenshots it with grim.
# Runs inside archlinux:latest with the repo mounted read-only at /src.
#   PIXDECOR=1  install dist/pkgs/wayfire-plugins-extra and use pixdecor
#   WAIT=40     seconds to let the desktop settle before the screenshot
# Output: /out/harness.png, /out/harness-hud.log, /out/harness-wayfire.log
set -euo pipefail
WAIT=${WAIT:-40}
pacman -Sy --noconfirm --needed wayfire waybar kitty gtk3 gtk-layer-shell python-gobject \
  python-cairo python-psutil grim mesa ttf-firacode-nerd ttf-nerd-fonts-symbols-mono \
  wlr-randr libnotify >/dev/null
if [ "${PIXDECOR:-0}" = 1 ]; then
  if ! ls /src/dist/pkgs/wayfire-plugins-extra-*.pkg.tar.zst >/dev/null 2>&1; then
    # no saved package from an ISO build yet: build it here
    pacman -S --noconfirm --needed base-devel git meson ninja cmake boost nlohmann-json glm       vulkan-headers wayland-protocols glibmm libevdev librsvg >/dev/null
    id builder >/dev/null 2>&1 || useradd -m builder
    rm -rf /tmp/wpe && cp -r /src/pkgbuilds/wayfire-plugins-extra /tmp/wpe && chown -R builder /tmp/wpe
    (cd /tmp/wpe && runuser -u builder -- makepkg -f --noconfirm > /tmp/wpe.log 2>&1) ||
      { tail -20 /tmp/wpe.log; exit 1; }
    grep "^==> pixdecor" /tmp/wpe.log || true
    mkdir -p /out/pkgs && cp /tmp/wpe/*.pkg.tar.zst /out/pkgs/
    pacman -U --noconfirm /tmp/wpe/wayfire-plugins-extra-[0-9]*.pkg.tar.zst >/dev/null
  else
    pacman -U --noconfirm /src/dist/pkgs/wayfire-plugins-extra-[0-9]*.pkg.tar.zst >/dev/null
  fi
  ls /usr/lib/wayfire | grep -E 'pixdecor|shadows' || echo "WARNING: no pixdecor plugin installed"
fi

install -m755 /src/airootfs/usr/local/bin/matrix-* /usr/local/bin/
id neo >/dev/null 2>&1 || useradd -m neo
cp -r /src/airootfs/etc/skel/.config /home/neo/
ini=/home/neo/.config/wayfire.ini
# keep only what the HUD check needs; size the headless output like the VM
sed -i -e '/^layout = /d' -e '/^intro = /d' -e '/^idle = /d' -e '/^notifications = /d' \
  -e '/^clipboard = /d' -e '/^polkit = /d' "$ini"
printf '\n[output:HEADLESS-1]\nmode = 1280x800@60000\n' >> "$ini"
if [ "${PIXDECOR:-0}" = 1 ]; then
  sed -i '/^plugins = /s/\bdecoration\b/pixdecor/' "$ini"
fi
chown -R neo:neo /home/neo
mkdir -p /run/user/1000 && chown neo /run/user/1000 && chmod 700 /run/user/1000

runuser -u neo -- env XDG_RUNTIME_DIR=/run/user/1000 WLR_BACKENDS=headless \
  WLR_RENDERER_ALLOW_SOFTWARE=1 WLR_LIBINPUT_NO_DEVICES=1 MATRIX_RAIN_FPS=12 \
  MATRIX_PROFILE=vm HOME=/home/neo \
  wayfire -c "$ini" > /tmp/wayfire.log 2>&1 &
sleep "$WAIT"

sock=$(ls /run/user/1000/ | grep -E "^wayland-[0-9]+$" | head -1 || true)
mkdir -p /out
runuser -u neo -- env XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY="$sock" \
  grim /out/harness.png && echo "screenshot: /out/harness.png"
cp /home/neo/.local/state/matrix/hud.log /out/harness-hud.log 2>/dev/null || echo "no hud.log"
cp /tmp/wayfire.log /out/harness-wayfire.log
grep -aE 'Traceback|Error|matrix-hud' /tmp/wayfire.log | grep -v '^EE.*EGL' | tail -20 || true
echo "--- hud.log"; tail -n 30 /out/harness-hud.log 2>/dev/null || true
