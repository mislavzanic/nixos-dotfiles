-----------------------------------------------------------------------------
-- |
-- Module      :  Xmobar.Exec
-- Copyright   :  (c) Andrea Rossato
-- License     :  BSD-style (see LICENSE)
--
-- Maintainer  :  Jose A. Ortega Ruiz <jao@gnu.org>
-- Stability   :  unstable
-- Portability :  unportable
--
-- The 'Exec' class and the 'Command' data type.
--
-- The 'Exec' class represents the executable types, whose constructors may
-- appear in the 'Config.commands' field of the 'Config.Config' data type.
--
-- The 'Command' data type is for OS commands to be run by xmobar
--
-----------------------------------------------------------------------------

module Xmobar.Run.Exec (Exec (..), tenthSeconds, doEveryTenthSeconds) where

import Prelude
import Data.Char

import Xmobar.App.Timer (doEveryTenthSeconds, tenthSeconds)
import Xmobar.System.Signal

class Show e => Exec e where
    alias   :: e -> String
    alias   e    = takeWhile (not . isSpace) $ show e
    rate    :: e -> Int
    rate    _    = 10
    run     :: e -> IO String
    run     _    = return ""
    start   :: e -> (String -> IO ()) -> IO ()
    start   e cb = go
        where go = doEveryTenthSeconds (rate e) $ run e >>= cb
    trigger :: e -> (Maybe SignalType -> IO ()) -> IO ()
    trigger _ sh  = sh Nothing
