------------------------------------------------------------------------------
-- |
-- Module      : Plugins.Monitors.Uptime.Linux
-- Copyright   : (c) 2010 Jose Antonio Ortega Ruiz
-- License     : BSD3-style (see LICENSE)
--
-- Maintainer  : jao@gnu.org
-- Stability   : unstable
-- Portability : unportable
-- Created: Sun Dec 12, 2010 20:26
--
--
-- Uptime
--
------------------------------------------------------------------------------


module Xmobar.Plugins.Monitors.Uptime.Linux (readUptime) where

import qualified Data.ByteString.Lazy.Char8 as B

readUptime :: IO Float
readUptime =
  fmap (read . B.unpack . head . B.words) (B.readFile "/proc/uptime")
