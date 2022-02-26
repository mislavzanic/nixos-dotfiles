-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Mem.Linux
-- Copyright   :  (c) Andrea Rossato
-- License     :  BSD-style (see LICENSE)
--
-- Maintainer  :  Jose A. Ortega Ruiz <jao@gnu.org>
-- Stability   :  unstable
-- Portability :  unportable
--
-- A memory monitor for Xmobar
--
-----------------------------------------------------------------------------

module Xmobar.Plugins.Monitors.Mem.Linux (parseMEM) where

import qualified Data.Map as M

fileMEM :: IO String
fileMEM = readFile "/proc/meminfo"

parseMEM :: IO [Float]
parseMEM =
    do file <- fileMEM
       let content = map words $ take 8 $ lines file
           info = M.fromList $ map (\line -> (head line, (read $ line !! 1 :: Float) / 1024)) content
           [total, free, buffer, cache] = map (info M.!) ["MemTotal:", "MemFree:", "Buffers:", "Cached:"]
           available = M.findWithDefault (free + buffer + cache) "MemAvailable:" info
           used = total - available
           usedratio = used / total
           freeratio = free / total
           availableratio = available / total
       return [usedratio, freeratio, availableratio, total, free, buffer, cache, available, used]
