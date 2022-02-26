-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Top.Common
-- Copyright   :  (c) 2010, 2011, 2012, 2013, 2014, 2018 Jose A Ortega Ruiz
-- License     :  BSD-style (see LICENSE)
--
-- Maintainer  :  Jose A Ortega Ruiz <jao@gnu.org>
-- Stability   :  unstable
-- Portability :  unportable
--
--  Process activity and memory consumption monitors
--
-----------------------------------------------------------------------------

module Xmobar.Plugins.Monitors.Top.Common (
  MemInfo
  , Pid
  , TimeInfo
  , TimeEntry
  , Times
  , TimesRef
  ) where

import Data.IORef (IORef)
import Data.Time.Clock (UTCTime)

type MemInfo = (String, Float)
type Pid = Int
type TimeInfo = (String, Float)
type TimeEntry = (Pid, TimeInfo)
type Times = [TimeEntry]
type TimesRef = IORef (Times, UTCTime)
