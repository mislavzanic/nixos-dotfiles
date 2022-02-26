-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Cpu.FreeBSD
-- Copyright   :  (c) 2011, 2017 Jose Antonio Ortega Ruiz
--                (c) 2007-2010 Andrea Rossato
-- License     :  BSD-style (see LICENSE)
--
-- Maintainer  :  Jose A. Ortega Ruiz <jao@gnu.org>
-- Stability   :  unstable
-- Portability :  unportable
--
-- A cpu monitor for Xmobar
--
-----------------------------------------------------------------------------

module Xmobar.Plugins.Monitors.Cpu.FreeBSD (parseCpu
                                           , CpuDataRef
                                           , cpuData) where

import Xmobar.Plugins.Monitors.Cpu.Common (CpuData(..))
import Data.IORef (IORef, readIORef, writeIORef)
import System.BSD.Sysctl (sysctlPeekArray)

-- kern.cp_time data from the previous iteration for computing the difference
type CpuDataRef = IORef [Word]

cpuData :: IO [Word]
cpuData = sysctlPeekArray "kern.cp_time" :: IO [Word]

parseCpu :: CpuDataRef -> IO CpuData
parseCpu cref = do
    prev <- readIORef cref
    curr <- cpuData
    writeIORef cref curr
    let diff = map fromIntegral $ zipWith (-) curr prev
        user = head diff
        nice = diff !! 1
        system = diff !! 2
        intr = diff !! 3
        idle = diff !! 4
        total = user + nice + system + intr + idle
        cpuUserPerc = if total > 0 then user/total else 0
        cpuNicePerc = if total > 0 then nice/total else 0
        cpuSystemPerc = if total > 0 then (system+intr)/total else 0
        cpuIdlePerc = if total > 0 then idle/total else 0

    return CpuData
      { cpuUser = cpuUserPerc
      , cpuNice = cpuNicePerc
      , cpuSystem = cpuSystemPerc
      , cpuIdle = cpuIdlePerc
      , cpuIowait = 0
      , cpuTotal = cpuUserPerc+cpuSystemPerc
      }
