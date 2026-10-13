# Live session: give root the Matrix desktop config, then boot into it.
if [ ! -e ~/.config/wayfire.ini ]; then
  cp -an /etc/skel/. ~/
fi
[ -f ~/.bashrc ] && . ~/.bashrc

if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$MATRIX_NO_SESSION" ] && [ "$(tty)" = /dev/tty1 ]; then
  exec matrix-session
fi
