{-# LANGUAGE LambdaCase #-}

module Hooks.StatusBar where

import Custom.Vars
import Custom.Colors.KaolinAurora

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
  0 -> statusBarPropTo "_XMONAD_LOG_0" "xmobar -x 0" (xmobarPP 0)
  1 -> statusBarPropTo "_XMONAD_LOG_1" "xmobar -x 1" (xmobarPP 1)
  _ -> mempty

xmobarPP :: ScreenId -> X PP
xmobarPP sid = pure $ def
  { ppCurrent = xmobarColor myppCurrent "" . wrap "[" "]" -- Current workspace in xmobar
  , ppVisible = xmobarColor myppVisible ""                -- Visible but not current workspace
  , ppHidden = xmobarColor myppHidden "" . wrap "+" ""   -- Hidden workspaces in xmobar
  , ppHiddenNoWindows = xmobarColor  myppHiddenNoWindows ""        -- Hidden workspaces (no windows)
  , ppTitleSanitize = xmobarStrip
  , ppSep = wrapInColor myppSepColor "  |  "
  , ppUrgent = xmobarColor  myppUrgent "" . wrap "!" "!"  -- Urgent workspace
  , ppExtras  = [logTitlesOnScreen sid formatFocused formatUnfocused]                           -- # of windows current workspace
  , ppOrder = \[ws, l, _, wins] -> [ws, l, wins]
  }
  where
    formatFocused, formatUnfocused :: String -> String
    formatFocused   = xmobarColor myppCurrent "" . wrap "[" "]" . ppWindow
    formatUnfocused = xmobarColor myppHiddenNoWindows "" . wrap "[" "]" . ppWindow

    ppWindow :: String -> String
    ppWindow = xmobarRaw
           . (\w -> if null w then "untitled" else w)
           . shorten 30
           . xmobarStrip

