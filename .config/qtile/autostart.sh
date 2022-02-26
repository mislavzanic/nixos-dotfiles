#!/usr/bin/env bash 

# picom &
/usr/bin/emacs --daemon &
#conky -c $HOME/.config/conky/doomone-qtile.conkyrc
#volumeicon &
nm-applet &
[ -f $HOME/.local/share/bg ] && feh --bg-fill $HOME/.local/share/bg
