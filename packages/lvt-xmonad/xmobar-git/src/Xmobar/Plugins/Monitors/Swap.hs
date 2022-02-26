{-#LANGUAGE CPP #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Swap
-- Copyright   :  (c) Andrea Rossato
-- License     :  BSD-style (see LICENSE)
--
-- Maintainer  :  Jose A. Ortega Ruiz <jao@gnu.org>
-- Stability   :  unstable
-- Portability :  unportable
--
-- A  swap usage monitor for Xmobar
--
-----------------------------------------------------------------------------

module Xmobar.Plugins.Monitors.Swap where

import Xmobar.Plugins.Monitors.Common

#if defined(freebsd_HOST_OS)
import qualified Xmobar.Plugins.Monitors.Swap.FreeBSD as MS
#else
import qualified Xmobar.Plugins.Monitors.Swap.Linux as MS
#endif

swapConfig :: IO MConfig
swapConfig = mkMConfig
        "Swap: <usedratio>%"                    -- template
        ["usedratio", "total", "used", "free"] -- available replacements

formatSwap :: [Float] -> Monitor [String]
formatSwap (r:xs) = do
  d <- getConfigValue decDigits
  other <- mapM (showWithColors (showDigits d)) xs
  ratio <- showPercentWithColors r
  return $ ratio:other
formatSwap _ = return $ replicate 4 "N/A"

runSwap :: [String] -> Monitor String
runSwap _ =
    do m <- io MS.parseMEM
       l <- formatSwap m
       parseTemplate l
