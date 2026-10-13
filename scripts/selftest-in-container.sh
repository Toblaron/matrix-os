#!/usr/bin/env bash
# Boots dist/matrix-os-*.iso in QEMU (headless) with matrix.selftest=1 and
# waits for the in-OS matrix-selftest service to report over the serial port.
# Saves the serial log and a screenshot of the running desktop to dist/.
# Runs inside archlinux:latest with the repo mounted at /workspace.
set -euo pipefail
DIST=/workspace/dist
ISO=$(ls -t "$DIST"/matrix-os-*.iso | head -1)
TIMEOUT=${TIMEOUT:-1200}

pacman -Sy --noconfirm --needed qemu-system-x86 libarchive python-pillow socat >/dev/null

# volume label sits at offset 0x8028 of the primary volume descriptor
LABEL=$(dd if="$ISO" bs=1 skip=32808 count=32 status=none | tr -d ' ')
mkdir -p /tmp/iso
bsdtar -xf "$ISO" -C /tmp/iso matrix/boot/x86_64/vmlinuz-linux matrix/boot/x86_64/initramfs-linux.img

accel=(-accel tcg,thread=multi)
[ -e /dev/kvm ] && accel=(-enable-kvm -cpu host)
echo "==> Booting $(basename "$ISO") (label $LABEL, ${accel[0]})"

rm -f /tmp/serial.log
qemu-system-x86_64 "${accel[@]}" -m 4096 -smp 4 \
  -cdrom "$ISO" \
  -kernel /tmp/iso/matrix/boot/x86_64/vmlinuz-linux \
  -initrd /tmp/iso/matrix/boot/x86_64/initramfs-linux.img \
  -append "archisobasedir=matrix archisolabel=$LABEL console=ttyS0,115200 matrix.selftest=1" \
  -device virtio-vga -display none \
  -nic user,model=virtio-net-pci \
  -serial file:/tmp/serial.log \
  -monitor unix:/tmp/qemu-mon.sock,server,nowait \
  -no-reboot &
QEMU=$!

result=TIMEOUT shot=0
for ((t = 0; t < TIMEOUT; t += 5)); do
  sleep 5
  kill -0 $QEMU 2>/dev/null || break
  if ((!shot)) && grep -q 'MATRIX_SELFTEST: READY' /tmp/serial.log; then
    echo "screendump /tmp/screen.ppm" | socat - UNIX-CONNECT:/tmp/qemu-mon.sock >/dev/null
    sleep 2
    python -c "from PIL import Image; Image.open('/tmp/screen.ppm').save('$DIST/selftest.png')" &&
      echo "==> Screenshot saved to dist/selftest.png"
    shot=1
  fi
  if grep -q 'MATRIX_SELFTEST: DONE' /tmp/serial.log; then
    grep -q 'MATRIX_SELFTEST: PASS' /tmp/serial.log && result=PASS || result=FAIL
    break
  fi
done
kill $QEMU 2>/dev/null || true
cp /tmp/serial.log "$DIST/selftest-serial.log"

grep 'MATRIX_SELFTEST' /tmp/serial.log || true
echo "==> SELFTEST $result (serial log: dist/selftest-serial.log)"
[ "$result" = PASS ]
