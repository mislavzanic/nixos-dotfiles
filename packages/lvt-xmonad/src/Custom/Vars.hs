{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE BlockArguments #-}

module Custom.Vars where

import XMonad
import XMonad.Actions.Search (Browser)

import qualified XMonad.StackSet as W
import Data.Map.Strict (Map)
import GHC.Exts (fromList)


myModMask            :: KeyMask   = mod4Mask

myTerminal           :: String    = "alacritty"
myEditor             :: String    = "emacsclient -c -a'emacs'"
editCMD              :: String    = "emacsclient -c -n "
myPDF                :: String    = "zathura"
myBrowser            :: Browser   = "brave"
muhLock              :: String    = "slock"

myFont               :: String    = "xft:Ubuntu:bold:size=9:antialias=true:hinting=true"
--myFont               :: String    = "xft:JetBrainsMono Nerd Font Mono:bold:size=9:antialias=true:hinting=true"

myBorderWidth        :: Dimension = 2

myWorkspaces         :: [String]  = ["www","dev","pdf","vrt","vid", "ply"]

myConfigs :: [(String, String, String)]
myConfigs = [ ("doom emacs config.org", editCMD ++ "~/.doom.d/config.org", "doom emacs config")
            , ("doom emacs init.el", editCMD ++ "~/.doom.d/init.el", "doom emacs init")
            , ("xmonad.hs", editCMD ++ "~/.config/xmonad/src/xmonad.hs", "xmonad config")
            , ("xmobar.hs", editCMD ++ "~/.config/xmonad/src/xmobar.hs", "xmobar config")
            , ("zshrc", editCMD ++ "~/.config/zsh/.zshrc", "config for the z shell")
            , ("scripts", editCMD ++ "~/.local/bin/scripts", "scripts")
            ]

basicSubmapFromList :: Ord key => [(key, action)] -> Map (KeyMask, key) action
basicSubmapFromList = fromList . map \(k, a) -> ((0, k), a)

ms :: Int -> Maybe Int
ms = Just . (* 10^(4 :: Int))

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

wrapInColor :: String -> String -> String
wrapInColor color toWrap = "<fc=" ++ color ++ ">" ++ toWrap ++ "</fc>"

-- myppBgColor          :: String    = "#201C24"
-- myFocusedBorderColor = "#268BD2"
-- myppVisible = "#cb4b16"
-- myppHidden = "#268bd2"

