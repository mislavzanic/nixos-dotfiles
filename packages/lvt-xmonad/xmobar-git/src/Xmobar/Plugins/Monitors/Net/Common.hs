-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Net.Common
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

module Xmobar.Plugins.Monitors.Net.Common (
                        NetDev(..)
                      , NetDevInfo(..)
                      , NetDevRawTotal
                      , NetDevRate
                      , NetDevRef
                      ) where

import Data.IORef (IORef)
import Data.Time.Clock (UTCTime)
import Data.Word (Word64)

data NetDev num = N String (NetDevInfo num) | NA deriving (Eq,Show,Read)
data NetDevInfo num = NI | ND num num deriving (Eq,Show,Read)

type NetDevRawTotal = NetDev Word64
type NetDevRate = NetDev Float

type NetDevRef = IORef (NetDevRawTotal, UTCTime)

-- The more information available, the better.
-- Note that names don't matter. Therefore, if only the names differ,
-- a compare evaluates to EQ while (==) evaluates to False.
instance Ord num => Ord (NetDev num) where
    compare NA NA             = EQ
    compare NA _              = LT
    compare _  NA             = GT
    compare (N _ i1) (N _ i2) = i1 `compare` i2

instance Ord num => Ord (NetDevInfo num) where
    compare NI NI                 = EQ
    compare NI ND {}              = LT
    compare ND {} NI              = GT
    compare (ND x1 y1) (ND x2 y2) = x1 `compare` x2 <> y1 `compare` y2
