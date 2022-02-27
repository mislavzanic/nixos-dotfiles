module Hooks.ManageHook where

import XMonad
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Util.NamedScratchpad

import Custom.Vars
import Custom.Scratchpads

myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Thunderbird"   --> doShift ( head myWorkspaces )
    , className =? "Brave-browser" --> doShift ( head myWorkspaces )
    , className =? "Emacs" --> doShift ( myWorkspaces !! 1)
    , className =? "Zathura" --> doShift ( myWorkspaces !! 2)
    , className =? "Virt-manager" --> doShift ( myWorkspaces !! 3 )
    , className =? "mpv"     --> doShift ( myWorkspaces !! 4 )
    , className =? "Steam"     --> doShift ( myWorkspaces !! 5 )

    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore

    , className =? "discord"      --> doFloat
--    , className =? "Steam"      --> doFloat
    , className =? "Virt-manager" --> doFloat
    , className =? "Thunderbird"  --> doFloat
    , className =? "Nvidia-settings"  --> doFloat
    , className =? "Thunar"       --> doFloat

    , isFullscreen --> doFullFloat
    ] <+> namedScratchpadManageHook myScratchPads
