-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Mem.FreeBSD
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

module Xmobar.Plugins.Monitors.Mem.FreeBSD (parseMEM) where

import System.BSD.Sysctl (sysctlReadUInt)

parseMEM :: IO [Float]
parseMEM = do stats <- mapM sysctlReadUInt [
                "vm.stats.vm.v_page_size"
                , "vm.stats.vm.v_page_count"
                , "vm.stats.vm.v_free_count"
                , "vm.stats.vm.v_active_count"
                , "vm.stats.vm.v_inactive_count"
                , "vm.stats.vm.v_wire_count"
                , "vm.stats.vm.v_cache_count"]

              let [ pagesize, totalpages, freepages, activepages, inactivepages, wiredpages, cachedpages ] = fmap fromIntegral stats
                  usedpages = activepages + wiredpages + cachedpages
                  availablepages = inactivepages + cachedpages + freepages
                  bufferedpages = activepages + inactivepages + wiredpages

                  available = availablepages * pagesize
                  used = usedpages * pagesize
                  free = freepages * pagesize
                  cache = cachedpages * pagesize
                  buffer = bufferedpages * pagesize
                  total = totalpages * pagesize

                  usedratio = usedpages / totalpages
                  freeratio = freepages / totalpages
                  availableratio = availablepages / totalpages

              return [usedratio, freeratio, availableratio, total, free, buffer, cache, available, used]
