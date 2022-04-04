{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE BlockArguments #-}

module Config.Vars where

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
myBrowser            :: Browser   = "firefox"

myFont               :: String    = "xft:Ubuntu:bold:size=9:antialias=true:hinting=true"

myBorderWidth        :: Dimension = 2

myWorkspaces         :: [String]  = ["www","dev","pdf","vrt","vid", "ply"]

basicSubmapFromList :: Ord key => [(key, action)] -> Map (KeyMask, key) action
basicSubmapFromList = fromList . map \(k, a) -> ((0, k), a)

ms :: Int -> Maybe Int
ms = Just . (* 10^(4 :: Int))

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

wrapInColor :: String -> String -> String
wrapInColor color toWrap = "<fc=" ++ color ++ ">" ++ toWrap ++ "</fc>"
