-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Batt.FreeBSD
-- Copyright   :  (c) 2010, 2011, 2012, 2013, 2015, 2016, 2018, 2019 Jose A Ortega
--                (c) 2010 Andrea Rossato, Petr Rockai
-- License     :  BSD-style (see LICENSE)
--
-- Maintainer  :  Jose A. Ortega Ruiz <jao@gnu.org>
-- Stability   :  unstable
-- Portability :  unportable
--
-- A battery monitor for Xmobar
--
-----------------------------------------------------------------------------

module Xmobar.Plugins.Monitors.Batt.FreeBSD (readBatteries) where

import Xmobar.Plugins.Monitors.Batt.Common (BattOpts(..)
                                           , Result(..)
                                           , Status(..)
                                           , maybeAlert)

import Control.Monad (unless)
import System.BSD.Sysctl (sysctlReadInt)

battStatus :: Int -> Status
battStatus x
  | x == 1 = Discharging
  | x == 2 = Charging
  | otherwise = Unknown

readBatteries :: BattOpts -> [String] -> IO Result
readBatteries opts _ = do
  lf <- sysctlReadInt "hw.acpi.battery.life"
  rt <- sysctlReadInt "hw.acpi.battery.rate"
  tm <- sysctlReadInt "hw.acpi.battery.time"
  st <- sysctlReadInt "hw.acpi.battery.state"
  acline <- sysctlReadInt "hw.acpi.acline"
  let p = fromIntegral lf / 100
      w = fromIntegral rt
      t = fromIntegral tm * 60
      ac = acline == 1
      -- battery full when rate is 0 and on ac.
      sts = if w == 0 && ac then Full else battStatus $ fromIntegral st
  unless ac (maybeAlert opts p)
  return (Result p w t sts)
