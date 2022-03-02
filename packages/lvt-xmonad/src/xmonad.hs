{-
   __   _____  ___                      _
   \ \ / /|  \/  |                     | |
    \ V / | .  . | ___  _ __   __ _  __| |
    /   \ | |\/| |/ _ \| '_ \ / _` |/ _` |
   / /^\ \| |  | | (_) | | | | (_| | (_| |
   \/   \/\_|  |_/\___/|_| |_|\__,_|\__,_|

Available at: https://github.com/mislavzanic/Dotfiles

GLHF
-}

-- custom modules
import Custom.Vars
import Custom.Keys
import Custom.Colors.KaolinAurora
import Custom.Layouts
import Hooks.StartupHook
import Hooks.ManageHook

import qualified XMonad.StackSet as W

import System.IO (hPutStrLn)


import XMonad hiding ( (|||) ) -- jump to layout

import XMonad.Config.Desktop

-- actions
import XMonad.Actions.SwapPromote (masterHistoryHook)
import XMonad.Actions.UpdatePointer (updatePointer)

-- util
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad

import XMonad.Layout.NoBorders

-- hooks
import XMonad.Hooks.ManageDocks (manageDocks)
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.DynamicLog
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)

toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

main :: IO ()
main = do
  xmproc0 <- spawnPipe ("/etc/xmobar/xmobar-x86_64-linux -x 0")
  xmproc1 <- spawnPipe ("/etc/xmobar/xmobar-x86_64-linux -x 1")
  xmonad $ withUrgencyHook NoUrgencyHook $ ewmh desktopConfig
      { manageHook         = ( isFullscreen --> doFullFloat ) <+> manageDocks <+> myManageHook <+> manageHook desktopConfig
      , startupHook        = myStartupHook
      , layoutHook         = lessBorders OnlyScreenFloat $ myLayout
      , handleEventHook    = handleEventHook desktopConfig
      , workspaces         = myWorkspaces
      , borderWidth        = myBorderWidth
      , terminal           = myTerminal
      , modMask            = myModMask
      , normalBorderColor  = color1
      , focusedBorderColor = border
      , logHook            =  dynamicLogWithPP xmobarPP
        { ppOutput = \x -> hPutStrLn xmproc0 x >> hPutStrLn xmproc1 x
        , ppCurrent = xmobarColor myppCurrent "" . wrap "[" "]" -- Current workspace in xmobar
        , ppVisible = xmobarColor myppVisible ""                -- Visible but not current workspace
        , ppHidden = xmobarColor myppHidden "" . wrap "+" ""   -- Hidden workspaces in xmobar
        , ppHiddenNoWindows = xmobarColor  myppHiddenNoWindows ""        -- Hidden workspaces (no windows)
        , ppTitle = xmobarColor myppCurrent "" . shorten 60
        , ppTitleSanitize = xmobarStrip
        , ppSep = wrapInColor myppSepColor "  |  "
        , ppUrgent = xmobarColor  myppUrgent "" . wrap "!" "!"  -- Urgent workspace
        , ppExtras  = [windowCount]                           -- # of windows current workspace
        , ppOrder = \[ws, l, _, wins] -> [ws, l, wins]
        }
      }
      `additionalKeysP` myKeys
