-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Batt.Common
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

module Xmobar.Plugins.Monitors.Batt.Common (BattOpts(..)
                                           , Result(..)
                                           , Status(..)
                                           , maybeAlert) where

import System.Process (system)
import Control.Monad (unless, void)
import Xmobar.Plugins.Monitors.Common

data Status = Charging | Discharging | Full | Idle | Unknown deriving (Read, Eq)
-- Result perc watts time-seconds Status
data Result = Result Float Float Float Status | NA

data BattOpts = BattOpts
  { onString :: String
  , offString :: String
  , idleString :: String
  , posColor :: Maybe String
  , lowWColor :: Maybe String
  , mediumWColor :: Maybe String
  , highWColor :: Maybe String
  , lowThreshold :: Float
  , highThreshold :: Float
  , onLowAction :: Maybe String
  , actionThreshold :: Float
  , onlineFile :: FilePath
  , scale :: Float
  , onIconPattern :: Maybe IconPattern
  , offIconPattern :: Maybe IconPattern
  , idleIconPattern :: Maybe IconPattern
  , lowString :: String
  , mediumString :: String
  , highString :: String
  , incPerc :: Bool
  }

maybeAlert :: BattOpts -> Float -> IO ()
maybeAlert opts left =
  case onLowAction opts of
    Nothing -> return ()
    Just x -> unless (isNaN left || actionThreshold opts < 100 * left)
                $ void $ system x
