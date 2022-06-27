{-# LANGUAGE LambdaCase #-}
module Config.StatusBar where

import Config.Vars
import Config.Colors

import XMonad

import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP (PP
                                  (ppVisible, ppHiddenNoWindows,
                                   ppCurrent, ppExtras, ppHidden,
                                   ppOrder, ppSep, ppUrgent, ppTitleSanitize
                                  ),
                                  shorten, wrap,
                                  xmobarColor, xmobarRaw, xmobarStrip
                                 )

import XMonad.Util.Loggers (logTitlesOnScreen)

barSpawner :: ScreenId -> StatusBarConfig
barSpawner = \case
  0 -> statusBarPropTo "_XMONAD_LOG_0" "xmobar -x 0 ~/.config/xmobar/xmobarrc0" (xmobarPP 0)
  1 -> statusBarPropTo "_XMONAD_LOG_1" "xmobar -x 1 ~/.config/xmobar/xmobarrc1" (xmobarPP 1)
  _ -> mempty

xmobarPP :: ScreenId -> X PP
xmobarPP sid = pure $ def
  { ppCurrent = xmobarColor base03 "" . wrap "[" "]" -- Current workspace in xmobar
  , ppVisible = xmobarColor base03 ""                -- Visible but not current workspace
  , ppHidden = xmobarColor base04 "" . wrap "+" ""   -- Hidden workspaces in xmobar
  , ppHiddenNoWindows = xmobarColor base08 ""        -- Hidden workspaces (no windows)
  , ppTitleSanitize = xmobarStrip
  , ppSep = wrapInColor "#586E75" "  |  "
  , ppUrgent = xmobarColor  base01 "" . wrap "!" "!"  -- Urgent workspace
  , ppExtras  = [logTitlesOnScreen sid formatFocused formatUnfocused]                           -- # of windows current workspace
  , ppOrder = \[ws, l, _, wins] -> [ws, l, wins]
  }
  where
    formatFocused, formatUnfocused :: String -> String
    formatFocused   = xmobarColor base03 "" . wrap "[" "]" . ppWindow
    formatUnfocused = xmobarColor base07 "" . wrap "[" "]" . ppWindow

    ppWindow :: String -> String
    ppWindow = xmobarRaw
           . (\w -> if null w then "untitled" else w)
           . shorten 30
           . xmobarStrip
