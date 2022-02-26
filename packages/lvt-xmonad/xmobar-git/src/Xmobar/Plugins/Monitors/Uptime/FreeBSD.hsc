------------------------------------------------------------------------------
-- |
-- Module      : Plugins.Monitors.Uptime.FreeBSD
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


module Xmobar.Plugins.Monitors.Uptime.FreeBSD (readUptime) where

import Data.Time.Clock.POSIX (getPOSIXTime)
import System.BSD.Sysctl
import Data.Int
import Foreign.C
import Foreign.Storable

#include <sys/types.h>
#include <sys/user.h>
#include <sys/time.h>
#include <sys/sysctl.h>

data TimeVal = TimeVal {sec:: CTime}

instance Storable TimeVal where
  sizeOf _    = #{size struct timeval}
  alignment _ = alignment (undefined::CTime)
  peek ptr    = do cSec  <- #{peek struct timeval, tv_sec} ptr
                   return (TimeVal cSec)
  poke _ _    = pure ()

now :: IO Int64
now = do
    posix <- getPOSIXTime
    return $ round posix

readUptime :: IO Float
readUptime = do
  tv <- sysctlPeek "kern.boottime" :: IO TimeVal
  nowSec <- now
  return $ fromInteger $ toInteger $ (nowSec - (secInt $ sec tv))
  where
    secInt :: CTime -> Int64
    secInt (CTime cSec) = cSec
