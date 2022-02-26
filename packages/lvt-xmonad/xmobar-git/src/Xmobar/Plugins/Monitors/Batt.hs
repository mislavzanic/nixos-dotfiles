{-# LANGUAGE CPP #-}

-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Batt
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

module Xmobar.Plugins.Monitors.Batt ( battConfig, runBatt, runBatt' ) where

import Xmobar.Plugins.Monitors.Batt.Common (BattOpts(..)
                                           , Result(..)
                                           , Status(..))
import Xmobar.Plugins.Monitors.Common
import System.Console.GetOpt

#if defined(freebsd_HOST_OS)
import qualified Xmobar.Plugins.Monitors.Batt.FreeBSD as MB
#else
import qualified Xmobar.Plugins.Monitors.Batt.Linux as MB
#endif


defaultOpts :: BattOpts
defaultOpts = BattOpts
  { onString = "On"
  , offString = "Off"
  , idleString = "On"
  , posColor = Nothing
  , lowWColor = Nothing
  , mediumWColor = Nothing
  , highWColor = Nothing
  , onLowAction = Nothing
  , actionThreshold = 6
  , lowThreshold = 10
  , highThreshold = 12
  , onlineFile = "AC/online"
  , scale = 1e6
  , onIconPattern = Nothing
  , offIconPattern = Nothing
  , idleIconPattern = Nothing
  , lowString = ""
  , mediumString = ""
  , highString = ""
  , incPerc = False
  }

options :: [OptDescr (BattOpts -> BattOpts)]
options =
  [ Option "O" ["on"] (ReqArg (\x o -> o { onString = x }) "") ""
  , Option "o" ["off"] (ReqArg (\x o -> o { offString = x }) "") ""
  , Option "i" ["idle"] (ReqArg (\x o -> o { idleString = x }) "") ""
  , Option "p" ["positive"] (ReqArg (\x o -> o { posColor = Just x }) "") ""
  , Option "l" ["low"] (ReqArg (\x o -> o { lowWColor = Just x }) "") ""
  , Option "m" ["medium"] (ReqArg (\x o -> o { mediumWColor = Just x }) "") ""
  , Option "h" ["high"] (ReqArg (\x o -> o { highWColor = Just x }) "") ""
  , Option "L" ["lowt"] (ReqArg (\x o -> o { lowThreshold = read x }) "") ""
  , Option "H" ["hight"] (ReqArg (\x o -> o { highThreshold = read x }) "") ""
  , Option "f" ["online"] (ReqArg (\x o -> o { onlineFile = x }) "") ""
  , Option "s" ["scale"] (ReqArg (\x o -> o {scale = read x}) "") ""
  , Option "a" ["action"] (ReqArg (\x o -> o { onLowAction = Just x }) "") ""
  , Option "P" ["percent"] (NoArg (\o -> o {incPerc = True})) ""
  , Option "A" ["action-threshold"]
               (ReqArg (\x o -> o { actionThreshold = read x }) "") ""
  , Option "" ["on-icon-pattern"] (ReqArg (\x o ->
     o { onIconPattern = Just $ parseIconPattern x }) "") ""
  , Option "" ["off-icon-pattern"] (ReqArg (\x o ->
     o { offIconPattern = Just $ parseIconPattern x }) "") ""
  , Option "" ["idle-icon-pattern"] (ReqArg (\x o ->
     o { idleIconPattern = Just $ parseIconPattern x }) "") ""
  , Option "" ["lows"] (ReqArg (\x o -> o { lowString = x }) "") ""
  , Option "" ["mediums"] (ReqArg (\x o -> o { mediumString = x }) "") ""
  , Option "" ["highs"] (ReqArg (\x o -> o { highString = x }) "") ""
  ]

battConfig :: IO MConfig
battConfig = mkMConfig
       "Batt: <watts>, <left>% / <timeleft>" -- template
       ["leftbar", "leftvbar", "left", "acstatus", "timeleft", "watts", "leftipat"] -- replacements

data BatteryStatus
  = BattHigh
  | BattMedium
  | BattLow

-- | Convert the current battery charge into a 'BatteryStatus'
getBattStatus
  :: Float    -- ^ Current battery charge, assumed to be in [0,1]
  -> BattOpts -- ^ Battery options, including high/low thresholds
  -> BatteryStatus
getBattStatus charge opts
  | c >= highThreshold opts = BattHigh
  | c >= lowThreshold  opts = BattMedium
  | otherwise = BattLow
 where
   c = 100 * min 1 charge

runBatt :: [String] -> Monitor String
runBatt = runBatt' ["BAT", "BAT0", "BAT1", "BAT2"]

runBatt' :: [String] -> [String] -> Monitor String
runBatt' bfs args = do
  opts <- io $ parseOptsWith options defaultOpts args
  c <- io $ MB.readBatteries opts bfs
  formatResult c opts

formatResult :: Result -> BattOpts -> Monitor String
formatResult res bopt = do
  let sp = incPerc bopt
  suffix <- getConfigValue useSuffix
  d <- getConfigValue decDigits
  nas <- getConfigValue naString
  case res of
    Result x w t s ->
      do l <- fmtPercent x sp
         ws <- fmtWatts w bopt suffix d
         si <- getIconPattern bopt s x
         st <- showWithColors'
                 (fmtStatus bopt s nas (getBattStatus x bopt))
                 (100 * x)
         parseTemplate (l ++ [st, fmtTime $ floor t, ws, si])
    NA -> getConfigValue naString
  where fmtPercent :: Float -> Bool -> Monitor [String]
        fmtPercent x sp = do
          let x' = minimum [1, x]
          pc <- if sp then colorizeString (100 * x') "%" else return ""
          p <- showPercentWithColors x'
          b <- showPercentBar (100 * x') x'
          vb <- showVerticalBar (100 * x') x'
          return [b, vb, p ++ pc]
        fmtWatts x o s d = do
          ws <- showWithPadding $ showDigits d x ++ (if s then "W" else "")
          return $ color x o ws
        fmtTime :: Integer -> String
        fmtTime x = hours ++ ":" ++ if length minutes == 2
                                    then minutes else '0' : minutes
          where hours = show (x `div` 3600)
                minutes = show ((x `mod` 3600) `div` 60)
        fmtStatus
          :: BattOpts
          -> Status
          -> String -- ^ What to in case battery status is unknown
          -> BatteryStatus
          -> String
        fmtStatus opts Idle _ _ = idleString opts
        fmtStatus _ Unknown na _ = na
        fmtStatus opts Full _ _ = idleString opts
        fmtStatus opts Charging _ _ = onString opts
        fmtStatus opts Discharging _ battStatus =
          (case battStatus of
            BattHigh -> highString
            BattMedium -> mediumString
            BattLow -> lowString) opts ++ offString opts
        maybeColor Nothing str = str
        maybeColor (Just c) str = "<fc=" ++ c ++ ">" ++ str ++ "</fc>"
        color x o | x >= 0 = maybeColor (posColor o)
                  | -x >= highThreshold o = maybeColor (highWColor o)
                  | -x >= lowThreshold o = maybeColor (mediumWColor o)
                  | otherwise = maybeColor (lowWColor o)
        getIconPattern opts st x = do
          let x' = minimum [1, x]
          case st of
               Unknown -> showIconPattern (offIconPattern opts) x'
               Idle -> showIconPattern (idleIconPattern opts) x'
               Full -> showIconPattern (idleIconPattern opts) x'
               Charging -> showIconPattern (onIconPattern opts) x'
               Discharging -> showIconPattern (offIconPattern opts) x'
