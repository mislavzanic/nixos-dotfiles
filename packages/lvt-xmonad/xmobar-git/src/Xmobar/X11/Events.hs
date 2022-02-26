------------------------------------------------------------------------------
-- |
-- Module: Xmobar.X11.Events
-- Copyright: (c) 2018 Jose Antonio Ortega Ruiz
-- License: BSD3-style (see LICENSE)
--
-- Maintainer: jao@gnu.org
-- Stability: unstable
-- Portability: portable
-- Created: Sun Nov 25, 2018 23:24
--
--
-- Utilities or event handling
--
------------------------------------------------------------------------------


module Xmobar.X11.Events(nextEvent') where

import Control.Concurrent
import System.Posix.Types (Fd(..))

import Graphics.X11.Xlib (
  Display(..), XEventPtr, nextEvent, pending, connectionNumber)

-- | A version of nextEvent that does not block in foreign calls.
nextEvent' :: Display -> XEventPtr -> IO ()
nextEvent' d p = do
    pend <- pending d
    if pend /= 0
        then nextEvent d p
        else do
            threadWaitRead (Fd fd)
            nextEvent' d p
 where
    fd = connectionNumber d
