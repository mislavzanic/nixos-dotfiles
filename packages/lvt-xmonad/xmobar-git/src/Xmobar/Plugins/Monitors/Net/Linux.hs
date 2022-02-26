-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Net.Linux
-- Copyright   :  (c) 2011, 2012, 2013, 2014, 2017, 2020 Jose Antonio Ortega Ruiz
--                (c) 2007-2010 Andrea Rossato
-- License     :  BSD-style (see LICENSE)
--
-- Maintainer  :  Jose A. Ortega Ruiz <jao@gnu.org>
-- Stability   :  unstable
-- Portability :  unportable
--
-- A net device monitor for Xmobar
--

-----------------------------------------------------------------------------

{-# LANGUAGE OverloadedStrings #-}

module Xmobar.Plugins.Monitors.Net.Linux (
  existingDevs
  , findNetDev
  ) where

import Xmobar.Plugins.Monitors.Net.Common (NetDevRawTotal, NetDev(..), NetDevInfo(..))

import Control.Monad (filterM)
import System.Directory (getDirectoryContents, doesFileExist)
import System.FilePath ((</>))
import System.IO.Error (catchIOError)
import System.IO.Unsafe (unsafeInterleaveIO)

import qualified Data.ByteString.Char8 as B


operstateDir :: String -> FilePath
operstateDir d = "/sys/class/net" </> d </> "operstate"

existingDevs :: IO [String]
existingDevs = getDirectoryContents "/sys/class/net" >>= filterM isDev
  where isDev d | d `elem` excludes = return False
                | otherwise = doesFileExist (operstateDir d)
        excludes = [".", "..", "lo"]

isUp :: String -> IO Bool
isUp d = flip catchIOError (const $ return False) $ do
  operstate <- B.readFile (operstateDir d)
  return $! (head . B.lines) operstate `elem` ["up", "unknown"]

readNetDev :: [String] -> IO NetDevRawTotal
readNetDev ~[d, x, y] = do
  up <- unsafeInterleaveIO $ isUp d
  return $ N d (if up then ND (r x) (r y) else NI)
    where r s | s == "" = 0
              | otherwise = read s

netParser :: B.ByteString -> IO [NetDevRawTotal]
netParser = mapM (readNetDev . splitDevLine) . readDevLines
  where readDevLines = drop 2 . B.lines
        splitDevLine = map B.unpack . selectCols . filter (not . B.null) . B.splitWith (`elem` [' ',':'])
        selectCols cols = map (cols!!) [0,1,9]

findNetDev :: String -> IO NetDevRawTotal
findNetDev dev = do
  nds <- B.readFile "/proc/net/dev" >>= netParser
  case filter isDev nds of
    x:_ -> return x
    _ -> return NA
  where isDev (N d _) = d == dev
        isDev NA = False
