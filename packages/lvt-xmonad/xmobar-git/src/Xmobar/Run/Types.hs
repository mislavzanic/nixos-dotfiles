{-# LANGUAGE TypeOperators, CPP #-}
------------------------------------------------------------------------------
-- |
-- Module: Xmobar.Run.Types
-- Copyright: (c) 2018 Jose Antonio Ortega Ruiz
-- License: BSD3-style (see LICENSE)
--
-- Maintainer: jao@gnu.org
-- Stability: unstable
-- Portability: portable
-- Created: Sun Nov 25, 2018 07:17
--
--
-- An enumeration of all runnable types
--
------------------------------------------------------------------------------


module Xmobar.Run.Types(runnableTypes) where

import {-# SOURCE #-} Xmobar.Run.Runnable()
import Xmobar.Plugins.Monitors
import Xmobar.Plugins.Date
import Xmobar.Plugins.PipeReader
import Xmobar.Plugins.BufferedPipeReader
import Xmobar.Plugins.MarqueePipeReader
import Xmobar.Plugins.CommandReader
import Xmobar.Plugins.StdinReader
import Xmobar.Plugins.XMonadLog
import Xmobar.Plugins.EWMH
import Xmobar.Plugins.Kbd
import Xmobar.Plugins.Locks
import Xmobar.Plugins.NotmuchMail

#ifdef INOTIFY
import Xmobar.Plugins.Mail
import Xmobar.Plugins.MBox
#endif

#ifdef DATEZONE
import Xmobar.Plugins.DateZone
#endif

#ifdef KRAKEN
import Xmobar.Plugins.Kraken
#endif

import Xmobar.Run.Command

-- | An alias for tuple types that is more convenient for long lists.
type a :*: b = (a, b)
infixr :*:

-- | This is the list of types that can be hidden inside
-- 'Runnable.Runnable', the existential type that stores all commands
-- to be executed by Xmobar. It is used by 'Runnable.readRunnable' in
-- the 'Runnable.Runnable' Read instance. To install a plugin just add
-- the plugin's type to the list of types (separated by ':*:') appearing in
-- this function's type signature.
runnableTypes :: Command :*: Monitors :*: Date :*: PipeReader :*:
                 BufferedPipeReader :*: CommandReader :*: StdinReader :*:
                 XMonadLog :*: EWMH :*: Kbd :*: Locks :*: NotmuchMail :*:
#ifdef INOTIFY
                 Mail :*: MBox :*:
#endif
#ifdef DATEZONE
                 DateZone :*:
#endif
#ifdef KRAKEN
                 Kraken :*:
#endif
                 MarqueePipeReader :*: ()
runnableTypes = undefined
