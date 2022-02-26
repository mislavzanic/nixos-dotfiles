-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Net
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

{-# LANGUAGE CPP #-}

module Xmobar.Plugins.Monitors.Net (
                        startNet
                      , startDynNet
                      ) where

import Xmobar.Plugins.Monitors.Common
import Xmobar.Plugins.Monitors.Net.Common (NetDev(..), NetDevInfo(..), NetDevRate, NetDevRef)
import Data.IORef (newIORef, readIORef, writeIORef)
import Data.Time.Clock (getCurrentTime, diffUTCTime)
import System.Console.GetOpt

#if defined(freebsd_HOST_OS)
import qualified Xmobar.Plugins.Monitors.Net.FreeBSD as MN
#else
import qualified Xmobar.Plugins.Monitors.Net.Linux as MN
#endif

import Control.Monad (forM)

type DevList = [String]

parseDevList :: String -> DevList
parseDevList = splitOnComma
  where splitOnComma [] = [[]]
        splitOnComma (',':xs) = [] : splitOnComma xs
        splitOnComma (x:xs) =
           let rest = splitOnComma xs
           in (x : head rest) : tail rest

data NetOpts = NetOpts
  { rxIconPattern :: Maybe IconPattern
  , txIconPattern :: Maybe IconPattern
  , onlyDevList :: Maybe DevList
  , upIndicator :: String
  }

defaultOpts :: NetOpts
defaultOpts = NetOpts
  { rxIconPattern = Nothing
  , txIconPattern = Nothing
  , onlyDevList = Nothing
  , upIndicator = "+"
  }

options :: [OptDescr (NetOpts -> NetOpts)]
options =
  [ Option "" ["rx-icon-pattern"] (ReqArg (\x o ->
     o { rxIconPattern = Just $ parseIconPattern x }) "") ""
  , Option "" ["tx-icon-pattern"] (ReqArg (\x o ->
     o { txIconPattern = Just $ parseIconPattern x }) "") ""
  , Option "" ["up"] (ReqArg (\x o -> o { upIndicator = x }) "") ""
  , Option "" ["devices"] (ReqArg (\x o ->
     o { onlyDevList = Just $ parseDevList x }) "") ""
  ]

data UnitPerSec = Bs | KBs | MBs | GBs deriving (Eq,Enum,Ord)
data NetValue = NetValue Float UnitPerSec deriving (Eq,Show)

instance Show UnitPerSec where
    show Bs  = "B/s"
    show KBs = "KB/s"
    show MBs = "MB/s"
    show GBs = "GB/s"

netConfig :: IO MConfig
netConfig = mkMConfig
    "<dev>: <rx>KB|<tx>KB"      -- template
    ["dev", "rx", "tx", "rxbar", "rxvbar", "rxipat", "txbar", "txvbar", "txipat", "up"]     -- available replacements

formatNet :: Maybe IconPattern -> Float -> Monitor (String, String, String, String)
formatNet mipat d = do
    s <- getConfigValue useSuffix
    dd <- getConfigValue decDigits
    let str True v = showDigits dd d' ++ show u
            where (NetValue d' u) = byteNetVal v
        str False v = showDigits dd $ v / 1024
    b <- showLogBar 0.9 d
    vb <- showLogVBar 0.9 d
    ipat <- showLogIconPattern mipat 0.9 d
    x <- showWithColors (str s) d
    return (x, b, vb, ipat)

printNet :: NetOpts -> NetDevRate -> Monitor String
printNet opts nd =
  case nd of
    N d (ND r t) -> do
        (rx, rb, rvb, ripat) <- formatNet (rxIconPattern opts) r
        (tx, tb, tvb, tipat) <- formatNet (txIconPattern opts) t
        parseTemplate [d,rx,tx,rb,rvb,ripat,tb,tvb,tipat, upIndicator opts]
    N _ NI -> return ""
    NA -> getConfigValue naString

parseNet :: NetDevRef -> String -> IO NetDevRate
parseNet nref nd = do
  (n0, t0) <- readIORef nref
  n1 <- MN.findNetDev nd
  t1 <- getCurrentTime
  writeIORef nref (n1, t1)
  let scx = realToFrac (diffUTCTime t1 t0)
      scx' = if scx > 0 then scx else 1
      rate da db = takeDigits 2 $ fromIntegral (db - da) / scx'
      diffRate (N d (ND ra ta)) (N _ (ND rb tb)) = N d (ND (rate ra rb) (rate ta tb))
      diffRate (N d NI) _ = N d NI
      diffRate _ (N d NI) = N d NI
      diffRate _ _ = NA
  return $ diffRate n0 n1

runNet :: NetDevRef -> String -> [String] -> Monitor String
runNet nref i argv = do
  dev <- io $ parseNet nref i
  opts <- io $ parseOptsWith options defaultOpts argv
  printNet opts dev

parseNets :: [(NetDevRef, String)] -> IO [NetDevRate]
parseNets = mapM $ uncurry parseNet

runNets :: [(NetDevRef, String)] -> [String] -> Monitor String
runNets refs argv = do
  opts <- io $ parseOptsWith options defaultOpts argv
  dev <- io $ parseActive $ filterRefs opts refs
  printNet opts dev
    where parseActive refs' = fmap selectActive (parseNets refs')
          refInDevList opts' (_, refname') = case onlyDevList opts' of
            Just theList -> refname' `elem` theList
            Nothing -> True
          filterRefs opts' refs' = case filter (refInDevList opts') refs' of
            [] -> refs'
            xs -> xs
          selectActive = maximum

startNet :: String -> [String] -> Int -> (String -> IO ()) -> IO ()
startNet i a r cb = do
  t0 <- getCurrentTime
  nref <- newIORef (NA, t0)
  _ <- parseNet nref i
  runM a netConfig (runNet nref i) r cb

startDynNet :: [String] -> Int -> (String -> IO ()) -> IO ()
startDynNet a r cb = do
  devs <- MN.existingDevs
  refs <- forM devs $ \d -> do
            t <- getCurrentTime
            nref <- newIORef (NA, t)
            _ <- parseNet nref d
            return (nref, d)
  runM a netConfig (runNets refs) r cb

byteNetVal :: Float -> NetValue
byteNetVal v
    | v < 1024**1 = NetValue v Bs
    | v < 1024**2 = NetValue (v/1024**1) KBs
    | v < 1024**3 = NetValue (v/1024**2) MBs
    | otherwise   = NetValue (v/1024**3) GBs
