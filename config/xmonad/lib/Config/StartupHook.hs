module Config.StartupHook where

import Config.Colors

import XMonad
import XMonad.Util.SpawnOnce (spawnOnce)

trayerColor :: String -> String
trayerColor c = "--tint 0x" ++ tail c


myStartupHook :: X()
myStartupHook = do
  spawn     "killall trayer"
  spawn     ("sleep 2 && trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor primary --transparent true --alpha 0 " ++ trayerColor basebg ++ " --height 22 &")

  spawnOnce "[ -f ~/.local/share/bg ] && feh --bg-fill ~/.local/share/bg"
  spawnOnce "dunst &"
  spawnOnce "nm-applet &"
  spawnOnce "pasystray &"
  spawnOnce "xsetroot -cursor_name left_ptr &"
  spawnOnce "xmodmap ~/.config/.dotfiles/config/x11/Xmodmap"
  spawnOnce "~/.config/xtheme.init"
  spawnOnce "cat ~/xtheme/* | /nix/store/z5p1gwhhq1cjikfh37b4bd8zz7misrhs-xrdb-1.2.1/bin/xrdb -load"
  spawnOnce "emacs-28.1 --daemon &"
