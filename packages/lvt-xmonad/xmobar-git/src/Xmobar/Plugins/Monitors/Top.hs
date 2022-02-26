{-#LANGUAGE CPP #-}
{-# LANGUAGE BangPatterns #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Top
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

module Xmobar.Plugins.Monitors.Top (startTop, topMemConfig, runTopMem) where

import Xmobar.Plugins.Monitors.Common

import Data.IORef (newIORef, readIORef, writeIORef)
import Data.List (sortBy)
import Data.Ord (comparing)
import Data.Time.Clock (getCurrentTime, diffUTCTime)

import Xmobar.Plugins.Monitors.Top.Common (
  MemInfo
  , TimeInfo
  , Times
  , TimesRef)

#if defined(freebsd_HOST_OS)
import qualified Xmobar.Plugins.Monitors.Top.FreeBSD as MT
#else
import qualified Xmobar.Plugins.Monitors.Top.Linux as MT
#endif


maxEntries :: Int
maxEntries = 10

intStrs :: [String]
intStrs = map show [1..maxEntries]

topMemConfig :: IO MConfig
topMemConfig = mkMConfig "<both1>"
                 [ k ++ n | n <- intStrs , k <- ["name", "mem", "both"]]

topConfig :: IO MConfig
topConfig = mkMConfig "<both1>"
              ("no" : [ k ++ n | n <- intStrs
                               , k <- [ "name", "cpu", "both"
                                      , "mname", "mem", "mboth"]])

showInfo :: String -> String -> Float -> Monitor [String]
showInfo nm sms mms = do
  mnw <- getConfigValue maxWidth
  mxw <- getConfigValue minWidth
  let lsms = length sms
      nmw = mnw - lsms - 1
      nmx = mxw - lsms - 1
      rnm = if nmw > 0 then padString nmw nmx " " True "" nm else nm
  mstr <- showWithColors' sms mms
  both <- showWithColors' (rnm ++ " " ++ sms) mms
  return [nm, mstr, both]


sortTop :: [(String, Float)] -> [(String, Float)]
sortTop =  sortBy (flip (comparing snd))

showMemInfo :: Float -> MemInfo -> Monitor [String]
showMemInfo scale (nm, rss) =
  showInfo nm (showWithUnits 3 1 rss) (100 * rss / sc)
  where sc = if scale > 0 then scale else 100

showMemInfos :: [MemInfo] -> Monitor [[String]]
showMemInfos ms = mapM (showMemInfo tm) ms
  where tm = sum (map snd ms)

timeMemInfos :: IO (Times, [MemInfo], Int)
timeMemInfos = fmap res MT.timeMemEntries
  where res x = (sortBy (comparing fst) $ map fst x, map snd x, length x)

combine :: Times -> Times -> Times
combine _ [] = []
combine [] ts = ts
combine l@((p0, (n0, t0)):ls) r@((p1, (n1, t1)):rs)
  | p0 == p1 && n0 == n1 = (p0, (n0, t1 - t0)) : combine ls rs
  | p0 <= p1 = combine ls r
  | otherwise = (p1, (n1, t1)) : combine l rs

take' :: Int -> [a] -> [a]
take' m l = let !r = tk m l in length l `seq` r
  where tk 0 _ = []
        tk _ [] = []
        tk n (x:xs) = let !r = tk (n - 1) xs in x : r

topProcesses :: TimesRef -> Float -> IO (Int, [TimeInfo], [MemInfo])
topProcesses tref scale = do
  (t0, c0) <- readIORef tref
  (t1, mis, len) <- timeMemInfos
  c1 <- getCurrentTime
  let scx = realToFrac (diffUTCTime c1 c0) * scale
      !scx' = if scx > 0 then scx else scale
      nts = map (\(_, (nm, t)) -> (nm, t / scx')) (combine t0 t1)
      !t1' = take' (length t1) t1
      !nts' = take' maxEntries (sortTop nts)
      !mis' = take' maxEntries (sortTop mis)
  writeIORef tref (t1', c1)
  return (len, nts', mis')

showTimeInfo :: TimeInfo -> Monitor [String]
showTimeInfo (n, t) =
  getConfigValue decDigits >>= \d -> showInfo n (showDigits d t) t

showTimeInfos :: [TimeInfo] -> Monitor [[String]]
showTimeInfos = mapM showTimeInfo

runTopMem :: [String] -> Monitor String
runTopMem _ = do
  mis <- io MT.meminfos
  pstr <- showMemInfos (sortTop mis)
  parseTemplate $ concat pstr

runTop :: TimesRef -> Float -> [String] -> Monitor String
runTop tref scale _ = do
  (no, ps, ms) <- io $ topProcesses tref scale
  pstr <- showTimeInfos ps
  mstr <- showMemInfos ms
  parseTemplate $ show no : concat (zipWith (++) pstr mstr) ++ repeat "N/A"

startTop :: [String] -> Int -> (String -> IO ()) -> IO ()
startTop a r cb = do
  c <- getCurrentTime
  tref <- newIORef ([], c)
  scale <- MT.scale
  _ <- topProcesses tref scale
  runM a topConfig (runTop tref scale) r cb
