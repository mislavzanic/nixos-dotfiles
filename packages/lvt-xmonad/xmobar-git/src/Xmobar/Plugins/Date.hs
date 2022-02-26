{-# LANGUAGE CPP #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Date
-- Copyright   :  (c) Andrea Rossato
-- License     :  BSD-style (see LICENSE)
--
-- Maintainer  :  Jose A. Ortega Ruiz <jao@gnu.org>
-- Stability   :  unstable
-- Portability :  unportable
--
-- A date plugin for Xmobar
--
-- Usage example: in template put
--
-- > Run Date "%a %b %_d %Y <fc=#ee9a00> %H:%M:%S</fc>" "Mydate" 10
--
-----------------------------------------------------------------------------

module Xmobar.Plugins.Date (Date(..), date) where

import Xmobar.Run.Exec

#if ! MIN_VERSION_time(1,5,0)
import System.Locale
#endif
import Data.IORef
import Data.Time
import Control.Concurrent.Async (concurrently_)

data Date = Date String String Int
    deriving (Read, Show)

instance Exec Date where
    alias (Date _ a _) = a
    rate  (Date _ _ r) = r
    start (Date f _ r) cb =
        -- refresh time zone once a minute to avoid wasting CPU cycles
        withRefreshingZone 600 $ \zone ->
            doEveryTenthSeconds r $ date zone f >>= cb

date :: IORef TimeZone -> String -> IO String
date zoneRef format = do
    zone <- readIORef zoneRef
    fmap (formatTime defaultTimeLocale format . utcToZonedTime zone) getCurrentTime

withRefreshingZone :: Int -> (IORef TimeZone -> IO ()) -> IO ()
withRefreshingZone r action = do
    zone <- newIORef =<< getCurrentTimeZone
    let refresh = atomicWriteIORef zone =<< getCurrentTimeZone
    concurrently_ (doEveryTenthSeconds r refresh) (action zone)
