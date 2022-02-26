-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Cpu.Common
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

module Xmobar.Plugins.Monitors.Cpu.Common (CpuData(..)) where

data CpuData = CpuData {
      cpuUser :: !Float,
      cpuNice :: !Float,
      cpuSystem :: !Float,
      cpuIdle :: !Float,
      cpuIowait :: !Float,
      cpuTotal :: !Float
    }
