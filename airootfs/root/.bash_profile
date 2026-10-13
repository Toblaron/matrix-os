# Live session: give root the Matrix desktop config, then boot into Wayfire.
if [ ! -e ~/.config/wayfire.ini ]; then
  cp -an /etc/skel/. ~/
fi
[ -f ~/.bashrc ] && . ~/.bashrc

if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = /dev/tty1 ]; then
  exec wayfire > /tmp/wayfire.log 2>&1
fi
