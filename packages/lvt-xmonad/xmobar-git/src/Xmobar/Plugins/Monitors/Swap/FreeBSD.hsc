-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Swap.FreeBSD
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

module Xmobar.Plugins.Monitors.Swap.FreeBSD (parseMEM) where

import System.BSD.Sysctl (sysctlReadUInt)
import Foreign
import Foreign.C.Types
import Foreign.C.String



#include <unistd.h>
#include <fcntl.h>
#include <kvm.h>
#include <limits.h>
#include <paths.h>
#include <stdlib.h>


foreign import ccall unsafe "kvm.h kvm_open" c_kvm_open :: CString -> CString -> CString -> CInt -> CString ->  IO (Ptr KVM_T)
foreign import ccall "&kvm_close" c_kvm_close :: FinalizerPtr KVM_T
foreign import ccall unsafe "kvm.h kvm_getswapinfo" c_kvm_getswapinfo :: Ptr KVM_T -> Ptr KVM_SWAP -> CInt -> CInt -> IO CInt

data KVM_T
data KvmT = KvmT !(ForeignPtr KVM_T)
  deriving (Eq, Ord, Show)

data KVM_SWAP
data KvmSwap = KvmSwap !(ForeignPtr KVM_SWAP)
  deriving (Eq, Ord, Show)

getKvmT:: IO KvmT
getKvmT = do
  withCString "/dev/null" $ \dir -> do
    kvm_t_ptr <- c_kvm_open nullPtr dir nullPtr #{const O_RDONLY} nullPtr
    ptr <- newForeignPtr c_kvm_close kvm_t_ptr
    return $ KvmT ptr

getSwapData :: KvmT -> IO SwapData
getSwapData (KvmT kvm_t_fp) = do
  withForeignPtr kvm_t_fp $ \kvm_t_ptr -> do
    allocaBytes #{size struct kvm_swap} $ \swap_ptr -> do
      c_kvm_getswapinfo kvm_t_ptr swap_ptr 1 0
      peek $ castPtr swap_ptr :: IO SwapData

data SwapData = AvailableSwapData {
  used :: Integer
  , total :: Integer
  } | NotAvailableSwapData
  deriving (Show, Read, Eq)

instance Storable SwapData where
  alignment _ = #{alignment struct kvm_swap}
  sizeOf _    = #{size struct kvm_swap}
  peek ptr    = do
    cused <- #{peek struct kvm_swap, ksw_used} ptr :: IO CUInt
    ctotal <- #{peek struct kvm_swap, ksw_total} ptr :: IO CUInt
    return $ AvailableSwapData {used = toInteger cused, total = toInteger ctotal}

  poke _ _    = pure ()


isEnabled :: IO Bool
isEnabled = do
  enabled <- sysctlReadUInt "vm.swap_enabled"
  return $ enabled == 1

parseMEM' :: Bool -> IO [Float]
parseMEM' False = return []
parseMEM' True = do
  kvm_t <- getKvmT
  swap <- getSwapData kvm_t
  pagesize <- toInteger <$> sysctlReadUInt "vm.stats.vm.v_page_size"

  let
    swapTotal = total swap
    swapUsed = used swap
    tot = swapTotal * pagesize
    fr = tot - swapUsed * pagesize

  return $ res (fromInteger tot) (fromInteger fr)
  where
    res :: Float -> Float -> [Float]
    res _ 0 = []
    res t f = [(t-f)/t, t, t - f, f]

parseMEM :: IO [Float]
parseMEM = do
  enabled <- isEnabled
  parseMEM' enabled
