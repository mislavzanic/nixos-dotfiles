-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Disk
-- Copyright   :  (c) 2010, 2011, 2012, 2014, 2018, 2019 Jose A Ortega Ruiz
-- License     :  BSD-style (see LICENSE)
--
-- Maintainer  :  Jose A Ortega Ruiz <jao@gnu.org>
-- Stability   :  unstable
-- Portability :  unportable
--
--  Disk usage and throughput monitors for Xmobar
--
-----------------------------------------------------------------------------

module Xmobar.Plugins.Monitors.Disk (diskUConfig, runDiskU, startDiskIO) where

import Xmobar.Plugins.Monitors.Common
import Xmobar.System.StatFS

import Data.IORef (IORef, newIORef, readIORef, writeIORef)

import Control.Exception (SomeException, handle)
import Control.Monad (zipWithM)
import qualified Data.ByteString.Lazy.Char8 as B
import Data.List (isPrefixOf, find)
import Data.Maybe (catMaybes)
import System.Directory (canonicalizePath, doesFileExist)
import System.Console.GetOpt

data DiskIOOpts = DiskIOOpts
  { totalIconPattern :: Maybe IconPattern
  , writeIconPattern :: Maybe IconPattern
  , readIconPattern :: Maybe IconPattern
  , contiguous :: Bool
  }

dioDefaultOpts :: DiskIOOpts
dioDefaultOpts = DiskIOOpts
   { totalIconPattern = Nothing
   , writeIconPattern = Nothing
   , readIconPattern = Nothing
   , contiguous = False
   }

dioOptions :: [OptDescr (DiskIOOpts -> DiskIOOpts)]
dioOptions =
   [ Option "" ["total-icon-pattern"] (ReqArg (\x o ->
      o { totalIconPattern = Just $ parseIconPattern x}) "") ""
   , Option "" ["write-icon-pattern"] (ReqArg (\x o ->
      o { writeIconPattern = Just $ parseIconPattern x}) "") ""
   , Option "" ["read-icon-pattern"] (ReqArg (\x o ->
      o { readIconPattern = Just $ parseIconPattern x}) "") ""
   , Option "c" ["contiguous"] (NoArg (\o -> o {contiguous = True})) ""
   ]

diskIOConfig :: IO MConfig
diskIOConfig = mkMConfig "" ["total", "read", "write"
                            ,"totalb", "readb", "writeb"
                            ,"totalbar", "readbar", "writebar"
                            ,"totalbbar", "readbbar", "writebbar"
                            ,"totalvbar", "readvbar", "writevbar"
                            ,"totalbvbar", "readbvbar", "writebvbar"
                            ,"totalipat", "readipat", "writeipat"
                            ,"totalbipat", "readbipat", "writebipat"
                            ]

data DiskUOpts = DiskUOpts
  { freeIconPattern :: Maybe IconPattern
  , usedIconPattern :: Maybe IconPattern
  , contiguousU :: Bool
  }

duDefaultOpts :: DiskUOpts
duDefaultOpts = DiskUOpts
   { freeIconPattern = Nothing
   , usedIconPattern = Nothing
   , contiguousU = False
   }

duOptions :: [OptDescr (DiskUOpts -> DiskUOpts)]
duOptions =
   [ Option "" ["free-icon-pattern"] (ReqArg (\x o ->
      o { freeIconPattern = Just $ parseIconPattern x}) "") ""
   , Option "" ["used-icon-pattern"] (ReqArg (\x o ->
      o { usedIconPattern = Just $ parseIconPattern x}) "") ""
   , Option "c" ["contiguous"] (NoArg (\o -> o {contiguousU = True})) ""
   ]

diskUConfig :: IO MConfig
diskUConfig = mkMConfig ""
              [ "size", "free", "used", "freep", "usedp"
              , "freebar", "freevbar", "freeipat"
              , "usedbar", "usedvbar", "usedipat"
              ]

type DevName = String
type Path = String
type DevDataRef = IORef [(DevName, [Float])]

mountedDevices :: [String] -> IO [(DevName, Path)]
mountedDevices req = do
  s <- B.readFile "/etc/mtab"
  parse `fmap` mapM mbcanon (devs s)
  where
    mbcanon (d, p) = doesFileExist d >>= \e ->
                     if e
                        then Just `fmap` canon (d,p)
                        else return Nothing
    canon (d, p) = do {d' <- canonicalizePath d; return (d', p)}
    devs = filter isDev . map (firstTwo . B.words) . B.lines
    parse = map undev . filter isReq . catMaybes
    firstTwo (a:b:_) = (B.unpack a, B.unpack b)
    firstTwo _ = ("", "")
    isDev (d, _) = "/dev/" `isPrefixOf` d
    isReq (d, p) = p `elem` req || drop 5 d `elem` req
    undev (d, f) = (drop 5 d, f)

diskDevices :: [String] -> IO [(DevName, Path)]
diskDevices req = do
  s <- B.readFile "/proc/diskstats"
  parse `fmap` mapM canon (devs s)
  where
    canon (d, p) = do {d' <- canonicalizePath d; return (d', p)}
    devs = map (third . B.words) . B.lines
    parse = map undev . filter isReq
    third (_:_:c:_) = ("/dev/" ++ B.unpack c, B.unpack c)
    third _ = ("", "")
    isReq (d, p) = p `elem` req || drop 5 d `elem` req
    undev (d, f) = (drop 5 d, f)

mountedOrDiskDevices :: [String] -> IO [(DevName, Path)]
mountedOrDiskDevices req = do
  mnt <- mountedDevices req
  case mnt of
       []    -> diskDevices req
       other -> return other

diskData :: IO [(DevName, [Float])]
diskData = do
  s <- B.readFile "/proc/diskstats"
  let extract ws = (head ws, map read (tail ws))
  return $ map (extract . map B.unpack . drop 2 . B.words) (B.lines s)

mountedData :: DevDataRef -> [DevName] -> IO [(DevName, [Float])]
mountedData dref devs = do
  dt <- readIORef dref
  dt' <- diskData
  writeIORef dref dt'
  return $ map (parseDev (zipWith diff dt' dt)) devs
  where diff (dev, xs) (_, ys) = (dev, zipWith (-) xs ys)


parseDev :: [(DevName, [Float])] -> DevName -> (DevName, [Float])
parseDev dat dev =
  case find ((==dev) . fst) dat of
    Nothing -> (dev, [0, 0, 0])
    Just (_, xs) ->
      let r = 4096 * xs !! 2
          w = 4096 * xs !! 6
          t = r + w
          rSp = speed r (xs !! 3)
          wSp = speed w (xs !! 7)
          sp =  speed t (xs !! 3 + xs !! 7)
          speed x d = if d == 0 then 0 else x / d
          dat' = if length xs > 6
                 then [sp, rSp, wSp, t, r, w]
                 else [0, 0, 0, 0, 0, 0]
      in (dev, dat')

speedToStr :: Float -> String
speedToStr = showWithUnits 2 1 . (/ 1024)

sizeToStr :: Integer -> String
sizeToStr = showWithUnits 3 0 . fromIntegral

findTempl :: DevName -> Path -> [(String, String)] -> String
findTempl dev path disks =
  case find devOrPath disks of
    Just (_, t) -> t
    Nothing -> ""
  where devOrPath (d, _) = d == dev || d == path

devTemplates :: [(String, String)]
                -> [(DevName, Path)]
                -> [(DevName, [Float])]
                -> [(String, [Float])]
devTemplates disks mounted dat =
  map (\(d, p) -> (findTempl d p disks, findData d)) mounted
  where findData dev = case find ((==dev) . fst) dat of
                         Nothing -> [0, 0, 0]
                         Just (_, xs) -> xs

runDiskIO' :: DiskIOOpts -> (String, [Float]) -> Monitor String
runDiskIO' opts (tmp, xs) = do
  s <- mapM (showWithColors speedToStr) xs
  b <- mapM (showLogBar 0.8) xs
  vb <- mapM (showLogVBar 0.8) xs
  ipat <- mapM (\(f,v) -> showLogIconPattern (f opts) 0.8 v)
        $ zip [totalIconPattern, readIconPattern, writeIconPattern
              , totalIconPattern, readIconPattern, writeIconPattern]
              xs
  setConfigValue tmp template
  parseTemplate $ s ++ b ++ vb ++ ipat

runDiskIO :: DevDataRef -> [(String, String)] -> [String] -> Monitor String
runDiskIO dref disks argv = do
  opts <- io $ parseOptsWith dioOptions dioDefaultOpts argv
  dev <- io $ mountedOrDiskDevices (map fst disks)
  dat <- io $ mountedData dref (map fst dev)
  strs <- mapM (runDiskIO' opts) $ devTemplates disks dev dat
  return $ (if contiguous opts then concat else unwords) strs

startDiskIO :: [(String, String)] ->
               [String] -> Int -> (String -> IO ()) -> IO ()
startDiskIO disks args rate cb = do
  dev <- mountedOrDiskDevices (map fst disks)
  dref <- newIORef (map (\d -> (fst d, repeat 0)) dev)
  _ <- mountedData dref (map fst dev)
  runM args diskIOConfig (runDiskIO dref disks) rate cb

fsStats :: String -> IO [Integer]
fsStats path = do
  stats <- getFileSystemStats path
  case stats of
    Nothing -> return [0, 0, 0]
    Just f -> let tot = fsStatByteCount f
                  free = fsStatBytesAvailable f
                  used = fsStatBytesUsed f
              in return [tot, free, used]

runDiskU' :: DiskUOpts -> String -> String -> Monitor String
runDiskU' opts tmp path = do
  setConfigValue tmp template
  [total, free, diff] <-  io (handle ign $ fsStats path)
  let strs = map sizeToStr [free, diff]
      freep = if total > 0 then free * 100 `div` total else 0
      fr = fromIntegral freep / 100
  s <- zipWithM showWithColors' strs [freep, 100 - freep]
  sp <- showPercentsWithColors [fr, 1 - fr]
  fb <- showPercentBar (fromIntegral freep) fr
  fvb <- showVerticalBar (fromIntegral freep) fr
  fipat <- showIconPattern (freeIconPattern opts) fr
  ub <- showPercentBar (fromIntegral $ 100 - freep) (1 - fr)
  uvb <- showVerticalBar (fromIntegral $ 100 - freep) (1 - fr)
  uipat <- showIconPattern (usedIconPattern opts) (1 - fr)
  parseTemplate $ [sizeToStr total] ++ s ++ sp ++ [fb,fvb,fipat,ub,uvb,uipat]
  where ign = const (return [0, 0, 0]) :: SomeException -> IO [Integer]


runDiskU :: [(String, String)] -> [String] -> Monitor String
runDiskU disks argv = do
  devs <- io $ mountedDevices (map fst disks)
  opts <- io $ parseOptsWith duOptions duDefaultOpts argv
  strs <- mapM (\(d, p) -> runDiskU' opts (findTempl d p disks) p) devs
  return $ (if contiguousU opts then concat else unwords) strs
