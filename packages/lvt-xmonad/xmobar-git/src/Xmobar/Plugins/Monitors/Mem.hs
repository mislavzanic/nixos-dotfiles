{-#LANGUAGE CPP #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Mem
-- Copyright   :  (c) Andrea Rossato
-- License     :  BSD-style (see LICENSE)
--
-- Maintainer  :  Jose A. Ortega Ruiz <jao@gnu.org>
-- Stability   :  unstable
-- Portability :  unportable
--
-- A memory monitor for Xmobar
--
-----------------------------------------------------------------------------

module Xmobar.Plugins.Monitors.Mem (memConfig, runMem, totalMem, usedMem) where

import Xmobar.Plugins.Monitors.Common
import System.Console.GetOpt

#if defined(freebsd_HOST_OS)
import qualified Xmobar.Plugins.Monitors.Mem.FreeBSD as MM
#else
import qualified Xmobar.Plugins.Monitors.Mem.Linux as MM
#endif


data MemOpts = MemOpts
  { usedIconPattern :: Maybe IconPattern
  , freeIconPattern :: Maybe IconPattern
  , availableIconPattern :: Maybe IconPattern
  }

defaultOpts :: MemOpts
defaultOpts = MemOpts
  { usedIconPattern = Nothing
  , freeIconPattern = Nothing
  , availableIconPattern = Nothing
  }

options :: [OptDescr (MemOpts -> MemOpts)]
options =
  [ Option "" ["used-icon-pattern"] (ReqArg (\x o ->
     o { usedIconPattern = Just $ parseIconPattern x }) "") ""
  , Option "" ["free-icon-pattern"] (ReqArg (\x o ->
     o { freeIconPattern = Just $ parseIconPattern x }) "") ""
  , Option "" ["available-icon-pattern"] (ReqArg (\x o ->
     o { availableIconPattern = Just $ parseIconPattern x }) "") ""
  ]

memConfig :: IO MConfig
memConfig = mkMConfig
       "Mem: <usedratio>% (<cache>M)" -- template
       ["usedbar", "usedvbar", "usedipat", "freebar", "freevbar", "freeipat",
        "availablebar", "availablevbar", "availableipat",
        "usedratio", "freeratio", "availableratio",
        "total", "free", "buffer", "cache", "available", "used"] -- available replacements

totalMem :: IO Float
totalMem = fmap ((*1024) . (!!1)) MM.parseMEM

usedMem :: IO Float
usedMem = fmap ((*1024) . (!!6)) MM.parseMEM

formatMem :: MemOpts -> [Float] -> Monitor [String]
formatMem opts (r:fr:ar:xs) =
    do let f = showDigits 0
           mon i x = [showPercentBar (100 * x) x, showVerticalBar (100 * x) x, showIconPattern i x]
       sequence $ mon (usedIconPattern opts) r
           ++ mon (freeIconPattern opts) fr
           ++ mon (availableIconPattern opts) ar
           ++ map showPercentWithColors [r, fr, ar]
           ++ map (showWithColors f) xs
formatMem _ _ = replicate 10 `fmap` getConfigValue naString

runMem :: [String] -> Monitor String
runMem argv =
    do m <- io MM.parseMEM
       opts <- io $ parseOptsWith options defaultOpts argv
       l <- formatMem opts m
       parseTemplate l
