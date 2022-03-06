{-# LANGUAGE LambdaCase #-}

module Config.Keys where

    -- Config
import Config.Vars

    -- Base
import XMonad
import System.Exit
import qualified XMonad.StackSet as W


    -- Actions
import XMonad.Actions.Promote
import XMonad.Actions.Submap (submap)
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.CycleWS

import XMonad.Layout.SubLayouts ( GroupMsg( UnMerge
                                          , MergeAll
                                          , UnMergeAll
                                          )
                                , onGroup
                                , mergeDir
                                , pushGroup
                                )
import XMonad.Layout.MultiToggle (Toggle (Toggle))
import XMonad.Layout.MultiToggle.Instances (StdTransformers (NOBORDERS))


    -- Data
import qualified Data.Map        as M

    -- Hooks
import XMonad.Hooks.ManageDocks (ToggleStruts(..))

type Keybinding = (String, X ())

windowsKeys =
  [ ("M-j", windows W.focusDown)
  , ("M-k", windows W.focusUp)
  , ("M-m", windows W.focusMaster)

  , ("M-<Backspace>", promote)

  , ("M-S-j", windows W.swapDown)
  , ("M-S-k", windows W.swapUp)

  , ("M-h", sendMessage Shrink)
  , ("M-l", sendMessage Expand)

  , ("M-;"  , withFocused $ sendMessage . mergeDir id)
  -- , ("M-S-;"  , withFocused (sendMessage . UnMerge) *> windows W.focusUp)
  , ("M-S-b"  , sendMessage $ Toggle NOBORDERS)
  ]

workspaceKeys =
  [("M-" ++ m ++ k, windows $ f i)
  | (i, k) <- zip myWorkspaces (map show [1 :: Int ..])
  , (f, m) <- [(W.greedyView, ""), (W.shift, "S-")]] ++

  [ ("M-M1-<Tab>", moveTo Next NonEmptyWS)

  , ("M-M1-S-<Tab>", moveTo Prev NonEmptyWS)

  , ("M-S-<Backspace>", removeWorkspace)
  ]

promptKeys =
  [ ("M-p", spawn "rofi -show run") ]

layoutKeys =
  [ ("M-<Tab>", sendMessage NextLayout) ]

appKeys =
  [("M-<Return>", spawn myTerminal)

  , ("M-S-c", kill)

  , ("M1-]", spawn "pamixer -i 5 && notify-send -u low -t 1500 $(pamixer --get-volume)")
  , ("M1-[", spawn "pamixer -d 5 && notify-send -u low -t 1500 $(pamixer --get-volume)")

  , ("M1-b", spawn myBrowser)
  , ("M1-z", spawn myPDF)
  , ("M1-u", spawn myEditor)
  , ("M1-d", spawn "discord")
  , ("M1-w", spawn "virt-manager")
  , ("M1-l", spawn "dm-tool lock")

  , ("M-S-w", spawn "sxiv -r -q -t -o ~/.local/share/wall/*")

  ]

myKeys = concat
  [ appKeys
  , layoutKeys
  , promptKeys
  , windowsKeys
  , workspaceKeys
  ]

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
------------------------------------------------------------------------
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]
