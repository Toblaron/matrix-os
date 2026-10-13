#!/usr/bin/env bash
# Builds the Matrix OS ISO. Runs as root inside an archlinux:latest container
# with the repo checked out at $SRC; writes the ISO to $OUT.
#
#  1. builds pkgbuilds/* and the AUR packages in aur.x86_64 into a local
#     pacman repo ([matrix-local] in pacman.conf)
#  2. appends whatever built successfully to packages.x86_64
#  3. runs mkarchiso
set -euo pipefail
SRC=${SRC:-/tmp/src}
OUT=${OUT:-/workspace/dist}
REPO=/tmp/matrix-localrepo
WORK=/tmp/matrix-pkgbuild

log() { printf '\n\033[1;32m==> %s\033[0m\n' "$*"; }

log "Installing build tools"
pacman -Syu --noconfirm --needed archiso git base-devel sudo >/dev/null

id builder >/dev/null 2>&1 || useradd -m builder
echo 'builder ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/builder
mkdir -p "$REPO" "$WORK"

built=()
build_pkg() { # <dir with PKGBUILD>
  local name dir
  name=$(basename "$1")
  dir="$WORK/$name"
  rm -rf "$dir" && cp -r "$1" "$dir" && chown -R builder "$dir"
  if (cd "$dir" && sudo -u builder makepkg --syncdeps --noconfirm --needed >"$dir.log" 2>&1); then
    cp "$dir"/*.pkg.tar.zst "$REPO"/
    # a split/renamed package still installs under its pkgname
    built+=("$(cd "$dir" && sudo -u builder makepkg --printsrcinfo | awk '/^pkgname/ {print $3; exit}')")
    echo "   built $name"
    grep -h "^==> pixdecor" "$dir.log" | sed "s/^/   /" || true
  else
    echo "   WARN: $name failed to build (log: $dir.log)"
    tail -n 15 "$dir.log" | sed 's/^/      /'
  fi
}

log "Building custom packages"
for d in "$SRC"/pkgbuilds/*/; do [ -f "$d/PKGBUILD" ] && build_pkg "${d%/}"; done

log "Building AUR packages"
grep -vE '^\s*(#|$)' "$SRC/aur.x86_64" | while read -r pkg; do echo "$pkg"; done > /tmp/aur.list
while read -r pkg; do
  rm -rf "/tmp/aur/$pkg"
  if git clone -q "https://aur.archlinux.org/$pkg.git" "/tmp/aur/$pkg"; then
    build_pkg "/tmp/aur/$pkg"
  else
    echo "   WARN: could not clone AUR $pkg"
  fi
done < /tmp/aur.list

log "Creating local repo"
shopt -s nullglob
pkgs=("$REPO"/*.pkg.tar.zst)
if ((${#pkgs[@]})); then
  repo-add -q "$REPO/matrix-local.db.tar.gz" "${pkgs[@]}"
else # pacman still needs a (empty) database to exist
  tar -czf "$REPO/matrix-local.db.tar.gz" -T /dev/null
  ln -sf matrix-local.db.tar.gz "$REPO/matrix-local.db"
fi

if ((${#built[@]})); then
  printf '\n# --- built locally by build-in-container.sh\n' >> "$SRC/packages.x86_64"
  printf '%s\n' "${built[@]}" >> "$SRC/packages.x86_64"
  log "Local packages added: ${built[*]}"
fi

log "Running mkarchiso"
mkdir -p "$OUT"
mkarchiso -v -w /tmp/archiso-work -o "$OUT" "$SRC"
(cd "$OUT" && sha256sum matrix-os-*.iso > matrix-os.sha256)
log "BUILD_OK"
