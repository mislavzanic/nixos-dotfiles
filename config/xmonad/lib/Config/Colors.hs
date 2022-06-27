{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE BlockArguments #-}
module Config.Colors where

import Prelude (String ())

import Config.Xresources (xprop)

basebg :: String = xprop "*.background"
basefg :: String = xprop "*.foreground"
base00 :: String = xprop "*.color0"
base08 :: String = xprop "*.color8"
base01 :: String = xprop "*.color1"
base09 :: String = xprop "*.color9"
base02 :: String = xprop "*.color2"
base10 :: String = xprop "*.color10"
base03 :: String = xprop "*.color3"
base11 :: String = xprop "*.color11"
base04 :: String = xprop "*.color4"
base12 :: String = xprop "*.color12"
base05 :: String = xprop "*.color5"
base13 :: String = xprop "*.color13"
base06 :: String = xprop "*.color6"
base14 :: String = xprop "*.color14"
base07 :: String = xprop "*.color7"
base15 :: String = xprop "*.color15"

-- myFont, myBigFont, myBoldFont, myItalicFont :: String
-- myFont = xprop "xmonad.font"
-- myBigFont = xprop "xmonad.font.big"
-- myBoldFont = xprop "xmonad.font.bold"
-- myItalicFont = xprop "xmonad.font.italic"
