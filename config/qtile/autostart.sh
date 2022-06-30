#!/usr/bin/env bash

feh --bg-fill ~/.local/share/bg
# xsetroot -cursor_name left_ptr

emacs --daemon &
nm-applet &
pasystray &
blueman-applet &
xmodmap ~/.config/.dotfiles/config/emacs/exwm/Xmodmap &
