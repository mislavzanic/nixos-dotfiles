{-# LANGUAGE LambdaCase #-}

module Config.Keys where

    -- Config
import Config.Vars
import Config.Scratchpad
import Config.Prompt

    -- Base
import XMonad
import System.Exit
import qualified XMonad.StackSet as W


    -- Actions
import XMonad.Actions.Promote
import XMonad.Actions.Submap (submap)
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.CycleWS

import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Prompt.Input
import XMonad.Prompt.FuzzyMatch
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.Submap
import XMonad.Util.Run

-- import XMonad.Util.XUtils ( WindowRect (CustomRect)
--                           , WindowConfig ( WindowConfig
--                                          , winBg
--                                          , winFg
--                                          , winFont
--                                          , winRect
--                                          )
--                           )


import XMonad.Layout.SubLayouts ( GroupMsg( UnMerge
                                          , MergeAll
                                          , UnMergeAll
                                          )
                                , onGroup
                                , mergeDir
                                , pushGroup
                                )
import XMonad.Prompt.Window ( WindowPrompt ( Goto
                                           , Bring
                                           )
                            , allWindows
                            , windowPrompt
                            )

import XMonad.Layout.MultiToggle (Toggle (Toggle))
import XMonad.Layout.MultiToggle.Instances (StdTransformers (NOBORDERS))

import XMonad.Actions.GridSelect
import XMonad.Util.NamedScratchpad

import qualified Data.Map        as M

import XMonad.Hooks.ManageDocks (ToggleStruts(..))

type Keybinding = (String, X ())

windowsKeys =
  [ ("M-j", windows W.focusDown)
  , ("M-k", windows W.focusUp)
  , ("M-m", windows W.focusMaster)

  , ("M-b", goToSelected def)

  , ("M-<Backspace>", promote)

  , ("M-S-j", windows W.swapDown)
  , ("M-S-k", windows W.swapUp)

  -- , ("M-s", screenshotPrompt promptTheme)
  , ("M-s", runSelectedAction def [("Fullscreen", spawn "takeScreenshot.sh Fullscreen"), ("Region", spawn "takeScreenshot.sh Region"), ("Active window", spawn "takeScreenshot.sh Active Window")])

  , ("M-h", sendMessage Shrink)
  , ("M-l", sendMessage Expand)

  , ("M-;"  , withFocused $ sendMessage . mergeDir id)
  , ("M-S-b"  , sendMessage $ Toggle NOBORDERS)
  ]

scratchpadKeys =
  [ ("M-C-<Return>", namedScratchpadAction myScratchPads "terminal")
  , ("M-C-s", namedScratchpadAction myScratchPads "spotify")
  ]

workspaceKeys =
  [("M-" ++ m ++ k, windows $ f i)
  | (i, k) <- zip myWorkspaces (map show [1 :: Int ..])
  , (f, m) <- [(W.greedyView, ""), (W.shift, "S-")]] ++

  [ ("M-M1-<Tab>", moveTo Next NonEmptyWS)

  , ("M-M1-S-<Tab>", moveTo Prev NonEmptyWS)

  , ("M-S-<Backspace>", removeWorkspace)
  ]

spawnWithZathura :: String -> X ()
spawnWithZathura book = spawn $ "zathura " ++ book


promptKeys =
  [ ("M-p", shellPrompt promptTheme)
  -- , ("M-o", submap . promptList $ promptTheme)
  , ("M-o", torrentPrompt promptTheme)
  , ("M-C-p", bookPrompt promptTheme)
  , ("M-[", windowPrompt promptTheme Goto allWindows)
  , ("M-]", windowPrompt promptTheme Bring allWindows)
  ]

layoutKeys =
  [ ("M-<Tab>", sendMessage NextLayout) ]

appKeys =
  [ ("M-<Return>", spawn myTerminal)

  , ("M-q", kill)
  , ("M-S-r", spawn "xmonad --restart")


  , ("<XF86AudioRaiseVolume>", spawn "pamixer -i 5 && notify-send -u low -t 1500 $(pamixer --get-volume)")
  , ("<XF86AudioLowerVolume>", spawn "pamixer -d 5 && notify-send -u low -t 1500 $(pamixer --get-volume)")

  , ("<XF86MonBrightnessDown>", spawn "brightnessctl s $(($(brightnessctl g) - 50))")
  , ("<XF86MonBrightnessUp>",   spawn "brightnessctl s $(($(brightnessctl g) + 50))")

  , ("M1-w", spawn myBrowser)
  , ("M1-z", spawn myPDF)
  , ("M1-u", spawn myEditor)
  , ("M1-l", spawn "dm-tool lock")

  , ("M-S-w", spawn "sxiv -r -q -t -o ~/.local/share/wall/*")
  ]

myKeys = concat
  [ appKeys
  , layoutKeys
  , promptKeys
  , windowsKeys
  , workspaceKeys
  , scratchpadKeys
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

promptList :: XPConfig -> M.Map (KeyMask, KeySym) (X ())
promptList theme = M.fromList [ ((noModMask, xK_p), torrentPrompt theme)
                            , ((noModMask, xK_b), bookPrompt theme)
                            , ((noModMask, xK_a), addWorkspacePrompt theme)
                            -- , ((noModMask, xK_c), removeWorkspace theme)
                            ]
-- winConfig :: WindowConfig
-- winConfig = WindowConfig { winBg = background
--                          , winFg = foreground
--                          , winFont = myFont
--                          , winRect = CustomRect Rectangle { rect_y = -40
--                                                           , rect_x = 1600
--                                                           , rect_width = 350
--                                                           , rect_height = 430
--                                                           }
--                          }
