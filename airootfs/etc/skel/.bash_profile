[ -f ~/.bashrc ] && . ~/.bashrc

if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = /dev/tty1 ]; then
  exec wayfire > /tmp/wayfire-$USER.log 2>&1
fi
