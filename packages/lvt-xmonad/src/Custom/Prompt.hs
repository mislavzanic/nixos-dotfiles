{-# OPTIONS_GHC -Wno-missing-signatures #-}
{-# OPTIONS_GHC -Wno-orphans            #-}

{-# LANGUAGE BlockArguments      #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE InstanceSigs        #-}
{-# LANGUAGE LambdaCase          #-}
{-# LANGUAGE PostfixOperators    #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE StrictData          #-}

module Custom.Prompt where


import Custom.Vars
import Custom.Colors.KaolinAurora
import Custom.Utils

 -- imports
import XMonad
import Control.Arrow (first)

import XMonad.Prompt
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.Input

import qualified Data.Map as M
import qualified XMonad.StackSet as W

import System.Exit (exitSuccess)

------------------------------------------------------------------------
-- XPROMPT SETTINGS
------------------------------------------------------------------------
dtXPConfig :: XPConfig
dtXPConfig = def
      { font                = myFont
      , bgColor             = myppBgColor
      , fgColor             = myppTitle
      , bgHLight            = myppCurrent
      , fgHLight            = "#000000"
      , borderColor         = "#535974"
      , promptBorderWidth   = 0
      , position            = Top
      , height              = 20
      , historySize         = 256
      , historyFilter       = id
      , defaultText         = []
      --, autoComplete        = (1 `ms`)
      , showCompletionOnTab = False
      , searchPredicate     = fuzzyMatch
      , alwaysHighlight     = True
      , maxComplRows        = Nothing      -- set to Just 5 for 5 rows
      }

systemPrompt :: XPConfig -> X ()
systemPrompt c = inputPromptWithCompl c "Execute" (mkComplFunFromList ["poweroff", "lock", "logout", "reboot", "recompile"]) ?+ \case
     { "poweroff" -> spawn "poweroff"
     ; "lock" -> spawn "slock"
     ; "logout" -> liftIO exitSuccess
     ; "reboot" -> spawn "reboot"
     ; "recompile" -> restart "xmonad" True
     ; _ -> debugNotif "'Invalid action'"
     }

------------------------------------------------------------------------
-- XPROMPT KEYMAP (emacs-like key bindings for xprompts)
------------------------------------------------------------------------
myXPKeymap :: M.Map (KeyMask,KeySym) (XP ())
myXPKeymap = M.fromList $
     map (first $ (,) controlMask)   -- control + <key>
     [ (xK_z, killBefore)            -- kill line backwards
     , (xK_k, killAfter)             -- kill line forwards
     , (xK_a, startOfLine)           -- move to the beginning of the line
     , (xK_e, endOfLine)             -- move to the end of the line
     , (xK_m, deleteString Next)     -- delete a character foward
     , (xK_b, moveCursor Prev)       -- move cursor forward
     , (xK_f, moveCursor Next)       -- move cursor backward
     , (xK_BackSpace, killWord Prev) -- kill the previous word
     , (xK_y, pasteString)           -- paste a string
     , (xK_g, quit)                  -- quit out of prompt
     , (xK_bracketleft, quit)
     ]
     ++
     map (first $ (,) mod1Mask)       -- meta key + <key>
     [ (xK_BackSpace, killWord Prev) -- kill the prev word
     , (xK_f, moveWord Next)         -- move a word forward
     , (xK_b, moveWord Prev)         -- move a word backward
     , (xK_d, killWord Next)         -- kill the next word
     , (xK_n, moveHistory W.focusUp')   -- move up thru history
     , (xK_p, moveHistory W.focusDown') -- move down thru history
     ]
     ++
     map (first $ (,) 0) -- <key>
     [ (xK_Return, setSuccess True >> setDone True)
     , (xK_KP_Enter, setSuccess True >> setDone True)
     , (xK_BackSpace, deleteString Prev)
     , (xK_Delete, deleteString Next)
     , (xK_Left, moveCursor Prev)
     , (xK_Right, moveCursor Next)
     , (xK_Home, startOfLine)
     , (xK_End, endOfLine)
     , (xK_Down, moveHistory W.focusUp')
     , (xK_Up, moveHistory W.focusDown')
     , (xK_Escape, quit)
     ]
