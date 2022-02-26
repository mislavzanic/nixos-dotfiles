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
import XMonad.Prompt.Man

import qualified Data.Map as M
import qualified XMonad.StackSet as W

import XMonad.Actions.Search


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
systemPrompt c = inputPromptWithCompl c "Execute" (systemCompletion c) ?+ \case
     { "poweroff" -> spawnList ["systemctl", "poweroff"]
     ; "lock" -> spawn "xlock"
     ; "logout" -> liftIO exitSuccess
     ; "reboot" -> spawnList ["systemctl", "reboot"]
     ; "recompile" -> restart "xmonad" True
     ; _ -> debugNotif "'Invalid action'"
     }

systemCompletion :: XPConfig -> String -> IO [String]
systemCompletion c = mkComplFunFromList c ["poweroff", "lock", "logout", "reboot", "recompile"]


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

data SearchType = Normal | Selected

promptNoHist :: XPConfig
promptNoHist = dtXPConfig { historySize = 0 }

searchEngineMap :: SearchType -> M.Map (KeyMask, KeySym) (X ())
searchEngineMap st = basicSubmapFromList
  [ (xK_t, sw  reddit    )
  , (xK_u, sw  url       )
  , (xK_d, sw  duckduckgo)
  , (xK_a, sw  arch      )
  , (xK_y, sw  youtube   )
  , (xK_h, sw  hoogle    )
  , (xK_p, sw  piratebay )
  , (xK_m, manPrompt promptNoHist)
  ]
 where
  -- | Same window, new window.
  sw :: SearchEngine -> X ()
  sw  = dw myBrowser

  -- | [D]ecide whether to open a new [w]indow.
  dw :: Browser -> SearchEngine -> X ()
  dw br se = case st of
    Normal   -> promptSearchBrowser' (decidePrompt se) br se
    Selected -> selectSearchBrowser                    br se

  -- | Some search engines get a modified prompt.
  decidePrompt :: SearchEngine -> XPConfig
  decidePrompt se
    | se `elem` [hoogle, wikipedia, arch, duckduckgo, piratebay] =
        promptNoHist
    | se `elem` [youtube, reddit] =
        dtXPConfig { autoComplete = (5 `ms`) }
    | otherwise = dtXPConfig

  -- | Search engines not in X.A.Search.
  reddit     = searchEngine  "reddit"       "https://old.reddit.com/r/"
  arch       = searchEngine  "arch"         "https://wiki.archlinux.org/index.php?search="
  duckduckgo = searchEngine  "duck"         "https://duckduckgo.com/?q="
  piratebay  = searchEngine  "piratebay"    "https://thepiratebay10.org/search/"
  url        = searchEngineF "url"          ("https://" <>)

instance Eq {- ORPHAN -} SearchEngine where
  (==) :: SearchEngine -> SearchEngine -> Bool
  (SearchEngine n _) == (SearchEngine n' _) = n == n'
