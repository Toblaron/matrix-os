[ -f ~/.bashrc ] && . ~/.bashrc

if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$MATRIX_NO_SESSION" ] && [ "$(tty)" = /dev/tty1 ]; then
  exec matrix-session
fi
