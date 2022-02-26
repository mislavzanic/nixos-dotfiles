-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.CoreTemp
-- Copyright   :  (c) Juraj Hercek
-- License     :  BSD-style (see LICENSE)
--
-- Maintainer  :  Juraj Hercek <juhe_haskell@hck.sk>
-- Stability   :  unstable
-- Portability :  unportable
--
-- A temperature monitor that works with AMD CPUs for Xmobar
--
-----------------------------------------------------------------------------

module Xmobar.Plugins.Monitors.K10Temp where

import Xmobar.Plugins.Monitors.Common

-- |
-- K10 temperature default configuration. Default template contains only the
-- die temperature, user should specify custom template in order to get more
-- ccd or IO die temperatures.
k10TempConfig :: IO MConfig
k10TempConfig = mkMConfig
       "Temp: <Tdie>C" -- template
       ["Tctl", "Tdie", "Tccd1", "Tccd2", "Tccd3"
       ,"Tccd4", "Tccd5", "Tccd6", "Tccd7", "Tccd8"
       ] -- available replacements

-- |
-- Base directory for k10temp system bus
--
k10Dir :: String
k10Dir = "/sys/bus/pci/drivers/k10temp/"

-- |
-- Function retrieves monitor string holding the temperature
-- (or temperatures)
runK10Temp :: [String] -> Monitor String
runK10Temp args = do
   dn <- getConfigValue decDigits
   failureMessage <- getConfigValue naString
   let slot = head args
       path = [k10Dir ++ slot ++ "/hwmon/hwmon", "/temp", "_input"]
       divisor = 1e3 :: Double
       show' = showDigits (max 0 dn)
   checkedDataRetrieval failureMessage [path] Nothing (/divisor) show'
