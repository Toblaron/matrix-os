#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="matrix-os"
iso_label="MATRIX_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Matrix OS <https://github.com/Toblaron/matrix-os>"
iso_application="Matrix OS Live"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="matrix"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.systemd-boot')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '15' '-b' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/usr/local/bin/matrix-recon"]="0:0:755"
  ["/usr/local/bin/matrix-hud"]="0:0:755"
  ["/usr/local/bin/matrix-sparks"]="0:0:755"
  ["/usr/local/bin/matrix-power"]="0:0:755"
  ["/usr/local/bin/matrix-layout"]="0:0:755"
)
