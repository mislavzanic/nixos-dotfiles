{-# LANGUAGE CPP                      #-}
{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE EmptyDataDecls #-}
{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE CApiFFI #-}

-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Top.FreeBSD
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

module Xmobar.Plugins.Monitors.Top.FreeBSD (
  timeMemEntries
  , meminfos
  , scale) where

import Foreign
import Foreign.C.Types
import Foreign.C.String

import Xmobar.Plugins.Monitors.Top.Common (MemInfo, TimeEntry)

#include <unistd.h>
#include <sys/sysctl.h>
#include <sys/user.h>
#include <libprocstat.h>

foreign import ccall "unistd.h getpagesize" c_getpagesize :: CInt
foreign import ccall unsafe "libprocstat.h procstat_open_sysctl" c_procstat_open_sysctl :: IO (Ptr PROCSTAT)
foreign import ccall "&procstat_close" c_procstat_close :: FinalizerPtr PROCSTAT
foreign import ccall "&procstat_freeprocs" c_procstat_freeprocs :: FinalizerEnvPtr PROCSTAT KINFO_PROC
foreign import ccall unsafe "libprocstat.h procstat_getprocs" c_procstat_getprocs :: Ptr PROCSTAT -> CInt -> CInt -> Ptr CUInt -> IO (Ptr KINFO_PROC)

data PROCSTAT
data ProcStat = ProcStat !(ForeignPtr PROCSTAT)
  deriving (Eq, Ord, Show)

data KINFO_PROC
data KinfoProc = KinfoProc [ProcData] Int
  deriving (Eq, Show)

data ProcData = ProcData {
  pname :: String
  , cpu :: Float
  , tdflags :: CULong
  , flag :: CULong
  , stat :: CUChar
  , rss :: Float
  , pid :: Int
  , runtime :: Float
  }
  deriving (Show, Read, Eq)

instance Storable ProcData where
  alignment _ = #{alignment struct kinfo_proc}
  sizeOf _    = #{size struct kinfo_proc}
  peek ptr    = do
       c <- #{peek struct kinfo_proc, ki_pctcpu} ptr
       ctdflags <- #{peek struct kinfo_proc, ki_tdflags} ptr
       cflag <- #{peek struct kinfo_proc, ki_flag} ptr
       cstat <- #{peek struct kinfo_proc, ki_stat} ptr
       cruntime <- #{peek struct kinfo_proc, ki_runtime} ptr :: IO CULong
       crss <- #{peek struct kinfo_proc, ki_rssize} ptr :: IO CULong
       cname <- peekCString (ptr `plusPtr` (#offset struct kinfo_proc, ki_comm))
       cpid <- #{peek struct kinfo_proc, ki_pid} ptr
       let crssf = (fromIntegral . toInteger) crss
       let cruntimef = ((fromIntegral . toInteger) cruntime  + 500000) / 10000
       return $ ProcData {
         pname = cname
         , cpu = (pctdouble c) * 100
         , tdflags = ctdflags
         , stat = cstat
         , flag = cflag
         , rss = crssf * pageSize
         , pid = cpid
         , runtime = cruntimef}

  poke _ _    = pure ()

pctdouble :: Int -> Float
pctdouble p = (fromIntegral p) / #{const FSCALE}


pageSize :: Float
pageSize = fromIntegral c_getpagesize / 1024


getProcStat:: IO ProcStat
getProcStat = do
    proc_ptr <- c_procstat_open_sysctl
    ptr <- newForeignPtr c_procstat_close proc_ptr
    return $ ProcStat ptr


getProcessesInfo :: ProcStat -> IO [ProcData]
getProcessesInfo (ProcStat ps_fp) = do
  withForeignPtr ps_fp $ \ps_ptr -> do
    alloca $ \n_ptr -> do
      kinfo_proc_ptr <- c_procstat_getprocs ps_ptr #{const KERN_PROC_PROC} 0 n_ptr
      newForeignPtrEnv c_procstat_freeprocs ps_ptr kinfo_proc_ptr
      num <- peek (n_ptr :: Ptr CUInt)
      pds <- peekArray (fromIntegral num) $ castPtr kinfo_proc_ptr :: IO [ProcData]

      return $ [p | p <- pds, flag p .&. #{const P_SYSTEM} == 0]


processes :: IO [ProcData]
processes = do
  proc_stat <- getProcStat
  getProcessesInfo proc_stat

handleProcesses :: (ProcData -> a) -> IO [a]
handleProcesses f = do
  ps <- processes
  return $ fmap (\pd -> f pd) ps

meminfo :: ProcData -> MemInfo
meminfo pd = (pname pd, rss pd)

meminfos :: IO [MemInfo]
meminfos = handleProcesses meminfo

timeMemEntry :: ProcData -> (TimeEntry, MemInfo)
timeMemEntry pd = ((p, (n, t)), (n, r))
  where p = pid pd
        n = pname pd
        t = runtime pd
        (_, r) = meminfo pd

timeMemEntries :: IO [(TimeEntry, MemInfo)]
timeMemEntries = handleProcesses timeMemEntry

scale :: IO Float
scale = return 1
