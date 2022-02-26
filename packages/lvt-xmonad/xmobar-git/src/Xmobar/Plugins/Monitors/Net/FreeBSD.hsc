{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE CPP #-}
{-# LANGUAGE CApiFFI #-}

-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Net.FreeBSD
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

module Xmobar.Plugins.Monitors.Net.FreeBSD (
  existingDevs
  , findNetDev
  ) where

import Xmobar.Plugins.Monitors.Net.Common (NetDevRawTotal, NetDev(..), NetDevInfo(..))
import Control.Exception (catch, SomeException(..))
import Foreign (Int32, plusPtr)
import Foreign.C.Types (CUIntMax, CUChar)
import Foreign.C.String (peekCString)
import Foreign.ForeignPtr ()
import Foreign.Storable (Storable, alignment, sizeOf, peek, poke)
import System.BSD.Sysctl (OID, sysctlPrepareOid, sysctlReadInt, sysctlPeek)

#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_mib.h>

data IfData = AvailableIfData {
  name :: String
  , txBytes :: CUIntMax
  , rxBytes :: CUIntMax
  , isUp :: Bool
  } | NotAvailableIfData
  deriving (Show, Read, Eq)

instance Storable IfData where
  alignment _ = #{alignment struct ifmibdata}
  sizeOf _    = #{size struct ifmibdata}
  peek ptr    = do
    cname <- peekCString (ptr `plusPtr` (#offset struct ifmibdata, ifmd_name))
    tx <- peek ((ifmd_data_ptr ptr) `plusPtr` (#offset struct if_data, ifi_obytes)) :: IO CUIntMax
    rx <- peek ((ifmd_data_ptr ptr) `plusPtr` (#offset struct if_data, ifi_ibytes)) :: IO CUIntMax
    state <- peek ((ifmd_data_ptr ptr) `plusPtr` (#offset struct if_data, ifi_link_state)) :: IO CUChar
    return $ AvailableIfData {name = cname, txBytes = tx, rxBytes = rx, isUp = up state}
      where
        up state = state == (#const LINK_STATE_UP)
        ifmd_data_ptr p = p `plusPtr` (#offset struct ifmibdata, ifmd_data)

  poke _ _    = pure ()

getNetIfCountOID :: IO OID
getNetIfCountOID = sysctlPrepareOid [
  #const CTL_NET
  , #const PF_LINK
  , #const NETLINK_GENERIC
  , #const IFMIB_SYSTEM
  , #const IFMIB_IFCOUNT]

getNetIfDataOID :: Int32 -> IO OID
getNetIfDataOID i = sysctlPrepareOid [
  #const CTL_NET
  , #const PF_LINK
  , #const NETLINK_GENERIC
  , #const IFMIB_IFDATA
  , i
  , #const IFDATA_GENERAL]

getNetIfCount :: IO Int32
getNetIfCount = do
  oid <- getNetIfCountOID
  sysctlReadInt oid

getNetIfData :: Int32 -> IO IfData
getNetIfData i = do
  oid <- getNetIfDataOID i
  res <- catch (sysctlPeek oid) (\(SomeException _) -> return NotAvailableIfData)
  return res

getAllNetworkData :: IO [IfData]
getAllNetworkData = do
  count <- getNetIfCount
  result <- mapM getNetIfData [1..count]
  return result

existingDevs :: IO [String]
existingDevs = getAllNetworkData >>= (\xs -> return $ filter (/= "lo0") $ fmap name xs)

convertIfDataToNetDev :: IfData -> IO NetDevRawTotal
convertIfDataToNetDev ifData = do
  let up = isUp ifData
      rx = fromInteger . toInteger $ rxBytes ifData
      tx = fromInteger . toInteger $ txBytes ifData
      d = name ifData
  return $ N d (if up then ND rx tx else NI)

netConvertIfDataToNetDev :: [IfData] -> IO [NetDevRawTotal]
netConvertIfDataToNetDev = mapM convertIfDataToNetDev

findNetDev :: String -> IO NetDevRawTotal
findNetDev dev = do
  nds <- getAllNetworkData >>= netConvertIfDataToNetDev
  case filter isDev nds of
    x:_ -> return x
    _ -> return NA
  where isDev (N d _) = d == dev
        isDev NA = False
