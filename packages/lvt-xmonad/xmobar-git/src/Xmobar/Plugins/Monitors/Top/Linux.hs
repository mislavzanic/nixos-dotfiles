-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Top.Linux
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

{-# LANGUAGE ForeignFunctionInterface #-}

module Xmobar.Plugins.Monitors.Top.Linux (
  timeMemEntries
  , meminfos
  , scale) where

import Xmobar.Plugins.Monitors.Common (parseFloat, parseInt)
import Xmobar.Plugins.Monitors.Top.Common (MemInfo, TimeEntry)

import Control.Exception (SomeException, handle)
import Data.List (foldl')
import System.Directory (getDirectoryContents)
import System.FilePath ((</>))
import System.IO (IOMode(ReadMode), hGetLine, withFile)
import System.Posix.Unistd (SysVar(ClockTick), getSysVar)

import Foreign.C.Types

foreign import ccall "unistd.h getpagesize"
  c_getpagesize :: CInt

pageSize :: Float
pageSize = fromIntegral c_getpagesize / 1024

processes :: IO [FilePath]
processes = fmap (filter isPid) (getDirectoryContents "/proc")
  where isPid = (`elem` ['0'..'9']) . head

statWords :: [String] -> [String]
statWords line@(x:pn:ppn:xs) =
  if last pn == ')' then line else statWords (x:(pn ++ " " ++ ppn):xs)
statWords _ = replicate 52 "0"

getProcessData :: FilePath -> IO [String]
getProcessData pidf =
  handle ign $ withFile ("/proc" </> pidf </> "stat") ReadMode readWords
  where readWords = fmap (statWords . words) . hGetLine
        ign = const (return []) :: SomeException -> IO [String]

memPages :: [String] -> String
memPages fs = fs!!23

ppid :: [String] -> String
ppid fs = fs!!3

skip :: [String] -> Bool
skip fs = length fs < 24 || memPages fs == "0" || ppid fs == "0"

handleProcesses :: ([String] -> a) -> IO [a]
handleProcesses f =
  fmap (foldl' (\a p -> if skip p then a else f p : a) [])
       (processes >>= mapM getProcessData)

processName :: [String] -> String
processName = drop 1 . init . (!!1)

meminfo :: [String] -> MemInfo
meminfo fs = (processName fs, pageSize * parseFloat (fs!!23))

meminfos :: IO [MemInfo]
meminfos = handleProcesses meminfo

timeMemEntry :: [String] -> (TimeEntry, MemInfo)
timeMemEntry fs = ((p, (n, t)), (n, r))
  where p = parseInt (head fs)
        n = processName fs
        t = parseFloat (fs!!13) + parseFloat (fs!!14)
        (_, r) = meminfo fs

timeMemEntries :: IO [(TimeEntry, MemInfo)]
timeMemEntries = handleProcesses timeMemEntry


scale :: IO Float
scale = do
  cr <- getSysVar ClockTick
  return $ fromIntegral cr / 100
