------------------------------------------------------------------------------
-- |
-- Module       :  Plugins.Monitors.ThermalZone
-- Copyright    :  (c) 2011, 2013 Jose Antonio Ortega Ruiz
-- License      :  BSD3-style (see LICENSE)
--
-- Maintainer   :  jao@gnu.org
-- Stability    :  unstable
-- Portability  :  portable
-- Created      :  Fri Feb 25, 2011 03:18
--
--
-- A thermal zone plugin based on the sysfs linux interface.
-- See http://kernel.org/doc/Documentation/thermal/sysfs-api.txt
--
------------------------------------------------------------------------------

module Xmobar.Plugins.Monitors.ThermalZone (thermalZoneConfig, runThermalZone) where

import Xmobar.Plugins.Monitors.Common

import System.Posix.Files (fileExist)
import Control.Exception (IOException, catch)
import qualified Data.ByteString.Char8 as B

-- | Default thermal configuration.
thermalZoneConfig :: IO MConfig
thermalZoneConfig = mkMConfig "<temp>C" ["temp"]

-- | Retrieves thermal information. Argument is name of thermal
-- directory in \/sys\/clas\/thermal. Returns the monitor string
-- parsed according to template (either default or user specified).
runThermalZone :: [String] -> Monitor String
runThermalZone args = do
    let zone = head args
        file = "/sys/class/thermal/thermal_zone" ++ zone ++ "/temp"
        handleIOError :: IOException -> IO (Maybe B.ByteString)
        handleIOError _ = return Nothing
        parse = return . (read :: String -> Int) . B.unpack
    exists <- io $ fileExist file
    if exists
      then do contents <- io $ catch (fmap Just $ B.readFile file) handleIOError
              case contents of
                Just d -> do
                  mdegrees <- parse d
                  temp <- showWithColors show (mdegrees `quot` 1000)
                  parseTemplate [ temp ]
                Nothing -> getConfigValue naString
      else getConfigValue naString
