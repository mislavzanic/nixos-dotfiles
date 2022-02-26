{-# LANGUAGE LambdaCase #-}

module Custom.Keys where

    -- Custom
import Custom.Vars
import Custom.Prompt
import Custom.Scratchpads
import Custom.TreePrompt

    -- Base
import XMonad
import System.Exit
import qualified XMonad.StackSet as W


import XMonad.Util.NamedScratchpad

    -- Actions
import XMonad.Actions.Promote
import XMonad.Actions.Prefix (PrefixArgument (Raw), withPrefixArgument)
import XMonad.Actions.Submap (submap)
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.CycleWS

import XMonad.Util.ActionCycle (cycleAction)
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

    -- Prompt
import XMonad.Prompt
import XMonad.Prompt.Shell (shellPrompt)
import XMonad.Prompt.Pass
import XMonad.Prompt.Window

type Keybinding = (String, X ())

switchToLayout :: String -> X ()
switchToLayout = sendMessage . JumpToLayout

windowsKeys =
  [ ("M-[", windowPrompt dtXPConfig Goto allWindows)
  , ("M-]", windowPrompt dtXPConfig Bring allWindows)

  , ("M-j", windows W.focusDown)
  , ("M-k", windows W.focusUp)
  , ("M-m", windows W.focusMaster)

  , ("M-<Backspace>", promote)

  , ("M-S-j", windows W.swapDown)
  , ("M-S-k", windows W.swapUp)

  , ("M-h", sendMessage Shrink)
  , ("M-l", sendMessage Expand)

  , ("M-C-m"  , cycleAction "tabAll" [ withFocused $ sendMessage . MergeAll
                                     , withFocused $ sendMessage . UnMergeAll
                                     ]
    )
  , ("M-;"  , withFocused $ sendMessage . mergeDir id)
  , ("M-S-;"  , withFocused (sendMessage . UnMerge) *> windows W.focusUp)
  , ("M-S-b"  , sendMessage $ Toggle NOBORDERS)
  ]

workspaceKeys =
  [("M-" ++ m ++ k, windows $ f i)
  | (i, k) <- zip myWorkspaces (map show [1 :: Int ..])
  , (f, m) <- [(W.greedyView, ""), (W.shift, "S-")]] ++

  [ ("M-M1-<Tab>", moveTo Next NonEmptyWS)

  , ("M-M1-S-<Tab>", moveTo Prev NonEmptyWS)

  , ("M-n r", renameWorkspace dtXPConfig)

  , ("M-n a", addWorkspacePrompt dtXPConfig)

  , ("M-S-<Backspace>", removeWorkspace)

  , ("M-n m", withWorkspace dtXPConfig (windows . W.shift))

  , ("M-n n", selectWorkspace dtXPConfig)
  ]

passPromptKeys =
  [("M-x p", passPrompt dtXPConfig)
  ,("M-x a", passGeneratePrompt dtXPConfig)
  ,("M-x r", passRemovePrompt dtXPConfig)
  ]

promptKeys =
  [ ("M-p", shellPrompt dtXPConfig)
  , ("M-o l", systemPrompt dtXPConfig)
  , ("M-s", withPrefixArgument $ submap . searchEngineMap . \case
        Raw _ -> Selected  -- Search for selected text.
        _     -> Normal)   -- Search for a certain term.
  ]

layoutKeys =
  [ ("M-<Tab>", sendMessage NextLayout)
  ]

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
  , ("M1-s", spawn "screen sel")
  , ("M1-l", spawn muhLock)
  , ("M1-m", spawn "thunderbird")
  , ("M1-t", spawn $ myTerminal <+> " -e tremc")
  , ("M1-f", spawn "Thunar")
  , ("M1-g", spawn "steam")
  , ("M1-S-n", spawn "nvidia-settings")
  , ("M1-S-p", spawn "toggle_comp.sh")

  , ("M-S-w", spawn "sxiv -r -q -t -o ~/.local/share/wall/*")

  -- Quit xmonad
  , ("M-S-q", io exitSuccess)
  , ("M-q", spawn "xmonad --recompile; xmonad --restart")
  ]

scratchPadKeys =
  [ ("M-C-<Return>", namedScratchpadAction myScratchPads "terminal")
  , ("M-C-s", namedScratchpadAction myScratchPads "spotify")
  , ("M-C-t", namedScratchpadAction myScratchPads "tremc")
  , ("M-C-d", namedScratchpadAction myScratchPads "discord")
  ]

myKeys = concat
  [ appKeys
  , scratchPadKeys
  , layoutKeys
  , promptKeys
  , windowsKeys
  , workspaceKeys
  , passPromptKeys
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
