-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Batt.Linux
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

module Xmobar.Plugins.Monitors.Batt.Linux (readBatteries) where

import Xmobar.Plugins.Monitors.Batt.Common (BattOpts(..)
                                           , Result(..)
                                           , Status(..)
                                           , maybeAlert)

import Control.Monad (unless)
import Control.Exception (SomeException, handle)
import System.FilePath ((</>))
import System.IO (IOMode(ReadMode), hGetLine, withFile)
import System.Posix.Files (fileExist)
import Data.List (sort, sortBy, group)
import Data.Maybe (fromMaybe)
import Data.Ord (comparing)
import Text.Read (readMaybe)

data Files = Files
  { fFull :: String
  , fNow :: String
  , fVoltage :: String
  , fCurrent :: String
  , fStatus :: String
  , isCurrent :: Bool
  } | NoFiles deriving Eq

data Battery = Battery
  { full :: !Float
  , now :: !Float
  , power :: !Float
  , status :: !String
  }

sysDir :: FilePath
sysDir = "/sys/class/power_supply"

safeFileExist :: String -> String -> IO Bool
safeFileExist d f = handle noErrors $ fileExist (d </> f)
  where noErrors = const (return False) :: SomeException -> IO Bool

batteryFiles :: String -> IO Files
batteryFiles bat =
  do is_charge <- exists "charge_now"
     is_energy <- if is_charge then return False else exists "energy_now"
     is_power <- exists "power_now"
     plain <- exists (if is_charge then "charge_full" else "energy_full")
     let cf = if is_power then "power_now" else "current_now"
         sf = if plain then "" else "_design"
     return $ case (is_charge, is_energy) of
       (True, _) -> files "charge" cf sf is_power
       (_, True) -> files "energy" cf sf is_power
       _ -> NoFiles
  where prefix = sysDir </> bat
        exists = safeFileExist prefix
        files ch cf sf ip = Files { fFull = prefix </> ch ++ "_full" ++ sf
                                  , fNow = prefix </> ch ++ "_now"
                                  , fCurrent = prefix </> cf
                                  , fVoltage = prefix </> "voltage_now"
                                  , fStatus = prefix </> "status"
                                  , isCurrent = not ip}

haveAc :: FilePath -> IO Bool
haveAc f =
  handle onError $ withFile (sysDir </> f) ReadMode (fmap (== "1") . hGetLine)
  where onError = const (return False) :: SomeException -> IO Bool

readBattery :: Float -> Files -> IO Battery
readBattery _ NoFiles = return $ Battery 0 0 0 "Unknown"
readBattery sc files =
    do a <- grab $ fFull files
       b <- grab $ fNow files
       d <- grab $ fCurrent files
       s <- grabs $ fStatus files
       let sc' = if isCurrent files then sc / 10 else sc
           a' = max a b -- sometimes the reported max charge is lower than
       return $ Battery (3600 * a' / sc') -- wattseconds
                        (3600 * b / sc') -- wattseconds
                        (abs d / sc') -- watts
                        s -- string: Discharging/Charging/Full
    where grab f = handle onError $ withFile f ReadMode (fmap read . hGetLine)
          onError = const (return (-1)) :: SomeException -> IO Float
          grabs f = handle onError' $ withFile f ReadMode hGetLine
          onError' = const (return "Unknown") :: SomeException -> IO String

-- sortOn is only available starting at ghc 7.10
sortOn :: Ord b => (a -> b) -> [a] -> [a]
sortOn f =
  map snd . sortBy (comparing fst) . map (\x -> let y = f x in y `seq` (y, x))

mostCommonDef :: Eq a => a -> [a] -> a
mostCommonDef x xs = head $ last $ [x] : sortOn length (group xs)

readBatteries :: BattOpts -> [String] -> IO Result
readBatteries opts bfs =
    do bfs' <- mapM batteryFiles bfs
       let bfs'' = filter (/= NoFiles) bfs'
       bats <- mapM (readBattery (scale opts)) (take 3 bfs'')
       ac <- haveAc (onlineFile opts)
       let sign = if ac then 1 else -1
           ft = sum (map full bats)
           left = if ft > 0 then sum (map now bats) / ft else 0
           watts = sign * sum (map power bats)
           time = if watts == 0 then 0 else max 0 (sum $ map time' bats)
           mwatts = if watts == 0 then 1 else sign * watts
           time' b = (if ac then full b - now b else now b) / mwatts
           statuses :: [Status]
           statuses = map (fromMaybe Unknown . readMaybe)
                          (sort (map status bats))
           acst = mostCommonDef Unknown $ filter (Unknown/=) statuses
           racst | acst /= Unknown = acst
                 | time == 0 = Idle
                 | ac = Charging
                 | otherwise = Discharging
       unless ac (maybeAlert opts left)
       return $ if isNaN left then NA else Result left watts time racst
