{-
   __   _____  ___                      _
   \ \ / /|  \/  |                     | |
    \ V / | .  . | ___  _ __   __ _  __| |
    /   \ | |\/| |/ _ \| '_ \ / _` |/ _` |
   / /^\ \| |  | | (_) | | | | (_| | (_| |
   \/   \/\_|  |_/\___/|_| |_|\__,_|\__,_|

-}

-- custom modules
import Config.KaolinAurora
import Config.Vars
import Config.Keys
import Config.Layouts
import Config.StartupHook
import Config.ManageHook
import Config.StatusBar

import qualified XMonad.StackSet as W

import System.IO (hPutStrLn)

import XMonad hiding ( (|||) ) -- jump to layout

import XMonad.Config.Desktop

-- actions
import XMonad.Actions.TopicSpace (workspaceHistoryHookExclude)
import XMonad.Actions.SwapPromote (masterHistoryHook)
import XMonad.Actions.UpdatePointer (updatePointer)

-- util
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad

import XMonad.Layout.NoBorders

-- hooks
import XMonad.Hooks.ManageDocks (manageDocks)
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen, setEwmhActivateHook)
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.StatusBar (dynamicEasySBs)


toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

main :: IO ()
main = xmonad
     . setEwmhActivateHook activateHook
     . ewmhFullscreen
     . ewmh
     . withUrgencyHook NoUrgencyHook
     . dynamicEasySBs (pure . barSpawner)
     $ myConfig where
        myConfig = desktopConfig
          { manageHook         = ( isFullscreen --> doFullFloat ) <+> manageDocks <+> myManageHook <+> manageHook desktopConfig
          , startupHook        = myStartupHook
          , layoutHook         = lessBorders OnlyScreenFloat $ myLayout
          , handleEventHook    = handleEventHook desktopConfig <+> myHandleEventHook
          , workspaces         = myWorkspaces
          , borderWidth        = myBorderWidth
          , terminal           = myTerminal
          , modMask            = myModMask
          , normalBorderColor  = color1
          , focusedBorderColor = border
          , logHook            = workspaceHistoryHookExclude [scratchpadWorkspaceTag]
                                 -- Remember where we've been.
                                 <> masterHistoryHook -- Remember where we've been² (for 'swapPromote').
                                 <> updatePointer (0.5, 0.5) (0, 0)
                                 -- When focusing a new window with the keyboard,
                                 -- move pointer to exact center of that window.
          }
          `additionalKeysP` myKeys
