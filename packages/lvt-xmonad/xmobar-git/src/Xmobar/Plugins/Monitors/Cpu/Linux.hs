-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Cpu.Linux
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

module Xmobar.Plugins.Monitors.Cpu.Linux (parseCpu
                                         , CpuDataRef
                                         , cpuData) where

import Xmobar.Plugins.Monitors.Cpu.Common (CpuData(..))
import qualified Data.ByteString.Lazy.Char8 as B
import Data.IORef (IORef, readIORef, writeIORef)

type CpuDataRef = IORef [Int]

-- Details about the fields here: https://www.kernel.org/doc/Documentation/filesystems/proc.txt
cpuData :: IO [Int]
cpuData = cpuParser <$> B.readFile "/proc/stat"

readInt :: B.ByteString -> Int
readInt bs = case B.readInt bs of
               Nothing -> 0
               Just (i, _) -> i

cpuParser :: B.ByteString -> [Int]
cpuParser = map readInt . tail . B.words . head . B.lines

convertToCpuData :: [Float] -> CpuData
convertToCpuData (u:n:s:ie:iw:_) =
  CpuData
    { cpuUser = u
    , cpuNice = n
    , cpuSystem = s
    , cpuIdle = ie
    , cpuIowait = iw
    , cpuTotal = sum [u, n, s]
    }
convertToCpuData args = error $ "convertToCpuData: Unexpected list" <> show args

parseCpu :: CpuDataRef -> IO CpuData
parseCpu cref =
    do a <- readIORef cref
       b <- cpuData
       writeIORef cref b
       let dif = zipWith (-) b a
           tot = fromIntegral $ sum dif
           safeDiv n = case tot of
                         0 -> 0
                         v -> fromIntegral n / v
           percent = map safeDiv dif
       return $ convertToCpuData percent
