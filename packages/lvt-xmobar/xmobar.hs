{-# LANGUAGE PostfixOperators    #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE LambdaCase          #-}

{-
   __   __                _
   \ \ / /               | |
    \ V / _ __ ___   ___ | |__   __ _ _ __
    /   \| '_ ` _ \ / _ \| '_ \ / _` | '__|
   / /^\ \ | | | | | (_) | |_) | (_| | |
   \/   \/_| |_| |_|\___/|_.__/ \__,_|_|

-}

import Xmobar

import System.Environment (getArgs)


main :: IO ()
main = getArgs >>= \case
  ["-x", n]    -> xmobar . myConfig $ read n
  ["-x", n, _] -> xmobar . myConfig $ read n
  _            -> xmobar . myConfig $      0

myConfig :: Int -> Config
myConfig n = defaultConfig
  { font            = "xft:Ubuntu Nerd Font:size=9:antialias=true:autohint=false:style=bold"
  , additionalFonts = [ "xft:mono:pixelsize=11:antialias=true:hinting=true"
                      , "xft:Font Awesome 5 Free Solid:pixelsize=12"
                      , "xft:Font Awesome 5 Brands:pixelsize=12"
                      , "xft:FontAwesome:pixelsize=12"
                      ]
  , bgColor         = myppBgColor
  , borderColor     = myppBgColor
  , fgColor         = myppTitle
  , position        = OnScreen n (TopH 24)
  , lowerOnStart    = True
  , hideOnStart     = False
  , allDesktops     = True
  , persistent      = True
  , iconRoot        = "/home/mislav/.config/xmonad/xpm"
  , commands        = myCommands n
  , sepChar         = "%"
  , alignSep        = "}{"
  , template        = myTemplate
  } where
    screenLog :: String = "StdinReader"
    trayer :: String = if n == 0 then wrapColor myppSepColor " |" <> "%trayerpad%" else ""
    myTemplate :: String =
      "<icon=cpu_20.xpm/>"
      <> wrapColor "#cccccc" "%cpu%"
      <> wrapColor myppSepColor " | "
      <> "<icon=memory-icon_20.xpm/>"
      <> wrapColor "#cccccc" "%memory%" ++ "} <icon=haskell.xpm/>  "
      <> wrapColor myppSepColor "|"
      <> " %StdinReader% "
      <> "{ <icon=harddisk-icon_20.xpm/>"
      <> wrapColor "#cccccc" "%disku%"
      <> wrapColor myppSepColor " | "
      <> "<icon=net_up_20.xpm/>"
      <> wrapColor "#cccccc" "%enp9s0%"
      <> wrapColor myppSepColor " | "
      <> "<icon=calendar-clock-icon_20.xpm/>"
      <> wrapColor "#cccccc" "%date%"
      <> trayer



wrapColor :: String -> String -> String
wrapColor color c = "<fc=" ++ color ++ "> " ++ c ++ " </fc>"

myppBgColor = "#14191e"
myppTitle = "#FDF6E3"
myppSepColor = "#586E75"

myCommands :: Int -> [Runnable]
myCommands n =
  [ Run $ Cpu ["-t", "cpu: (<total>%)","-H","50","--high","red"] 20

  , Run StdinReader

  , Run $ Com "/home/mislav/.local/bin/scripts/status_bar/updates" [] "updates" 60

  , Run $ Memory ["-t", "mem: <used>M (<usedratio>%)"] 20

  , Run $ DiskU [("/", "hdd: <free> free")] [] 60

  , Run $ Network "enp9s0" ["-L","0","-H","32","--normal","green","--high","red"] 10

  , Run $ Date "%b %d %Y - (%H:%M) " "date" 50

  , Run $ Com "/home/mislav/.config/xmonad/trayer-padding-icon.sh" [] "trayerpad" 20
  ]
