-----------------------------------------------------------------------------
-- |
-- Module      :  Xmobar.Main
-- Copyright   :  (c) Andrea Rossato
-- License     :  BSD-style (see LICENSE)
--
-- Maintainer  :  Jose A. Ortega Ruiz <jao@gnu.org>
-- Stability   :  unstable
-- Portability :  unportable
--
-- The main module of Xmobar, a text based status bar
--
-----------------------------------------------------------------------------

module Main (main) where

import Xmobar

main :: IO ()
main = xmobarMain
