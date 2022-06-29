{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE BlockArguments #-}
module Config.Colors where

import Prelude (String ())

import Config.Xresources (xprop)

baseBorder :: String = xprop "st.border"
basebg :: String = xprop "st.background"
basefg :: String = xprop "st.foreground"
base00 :: String = xprop "st.color0"
base08 :: String = xprop "st.color8"
base01 :: String = xprop "st.color1"
base09 :: String = xprop "st.color9"
base02 :: String = xprop "st.color2"
base10 :: String = xprop "st.color10"
base03 :: String = xprop "st.color3"
base11 :: String = xprop "st.color11"
base04 :: String = xprop "st.color4"
base12 :: String = xprop "st.color12"
base05 :: String = xprop "st.color5"
base13 :: String = xprop "st.color13"
base06 :: String = xprop "st.color6"
base14 :: String = xprop "st.color14"
base07 :: String = xprop "st.color7"
base15 :: String = xprop "st.color15"

-- myFont, myBigFont, myBoldFont, myItalicFont :: String
-- myFont = xprop "xmonad.font"
-- myBigFont = xprop "xmonad.font.big"
-- myBoldFont = xprop "xmonad.font.bold"
-- myItalicFont = xprop "xmonad.font.italic"
