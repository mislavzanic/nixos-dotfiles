module Config.StartupHook where

import Config.KaolinAurora

import XMonad
import XMonad.Util.SpawnOnce (spawnOnce)

trayerColor :: String
trayerColor = "--tint 0x" ++ tail myppBgColor


myStartupHook :: X()
myStartupHook = do
  spawn     "killall trayer"
  spawn     ("sleep 2 && trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 " ++ trayerColor ++ " --height 22 &")

  spawnOnce "[ -f ~/.local/share/bg ] && feh --bg-fill ~/.local/share/bg"
  spawnOnce "dunst &"
  spawnOnce "nm-applet &"
  spawnOnce "xsetroot -cursor_name left_ptr &"
