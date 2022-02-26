{-# LANGUAGE InstanceSigs        #-}
{-# LANGUAGE NamedFieldPuns      #-}
{-# LANGUAGE ScopedTypeVariables #-}

-----------------------------------------------------------------------------
-- |
-- Module      :  Xmobar.Plugins.NotmuchMail
-- Copyright   :  (c) slotThe
-- License     :  BSD-style (see LICENSE)
--
-- Maintainer  :  slotThe <soliditsallgood@mailbox.org>
-- Stability   :  unstable
-- Portability :  unportable
--
-- This plugin checks for new mail, provided that this mail is indexed
-- by @notmuch@.  You can think of it as a thin wrapper around the
-- functionality provided by @notmuch search@.
--
-- As mail that was tagged is moved from the @new@ directory to @cur@,
-- the @inotify@ solution that he mail 'Mail' plugin (and its variants)
-- uses won't work for such mail.  Hence, we have to resort to a
-- refresh-based monitor.
--
-- Note that, in the `notmuch` spirit, this plugin checks for new
-- threads and not new individual messages.  For convenience, the
-- @unread@ tag is added before the user query (compose via an @and@).
--
-----------------------------------------------------------------------------

module Xmobar.Plugins.NotmuchMail
  ( -- * Types
    MailItem(..)     -- instances: Read, Show
  , NotmuchMail(..)  -- instances: Read, Show
  ) where

import Xmobar.Run.Exec (Exec(alias, rate, run))

import Control.Concurrent.Async (mapConcurrently)
import Data.Maybe (catMaybes)
import System.Exit (ExitCode(ExitSuccess))
import System.Process (readProcessWithExitCode)
import Text.Read (Lexeme(Ident), ReadPrec, lexP, parens, prec, readPrec, reset)


-- | A 'MailItem' is a name, an address, and a query to give to @notmuch@.
data MailItem = MailItem
  { name    :: String  -- ^ Display name for the item in the bar
  , address :: String  -- ^ Only check for mail sent to this address; may be
                       --   the empty string to query all indexed mail instead
  , query   :: String  -- ^ Query to give to @notmuch search@
  }
  deriving (Show)

instance Read MailItem where
  readPrec :: ReadPrec MailItem
  readPrec = parens . prec 11 $ do
    Ident "MailItem" <- lexP
    MailItem <$> reset readPrec <*> reset readPrec <*> reset readPrec

-- | A full mail configuration.
data NotmuchMail = NotmuchMail
  { nmAlias   :: String      -- ^ Alias for the template string
  , mailItems :: [MailItem]  -- ^ 'MailItem's to check
  , nmRate    :: Int         -- ^ Update frequency (in deciseconds)
  }
  deriving (Show)

instance Read NotmuchMail where
  readPrec :: ReadPrec NotmuchMail
  readPrec = parens . prec 11 $ do
    Ident "NotmuchMail" <- lexP
    NotmuchMail <$> reset readPrec <*> reset readPrec <*> reset readPrec

-- | How to execute this plugin.
instance Exec NotmuchMail where
  -- | How often to update the plugin (in deciseconds).
  rate :: NotmuchMail -> Int
  rate NotmuchMail{ nmRate } = nmRate

  -- | How to alias the plugin in the template string.
  alias :: NotmuchMail -> String
  alias NotmuchMail{ nmAlias } = nmAlias

  -- | Run the plugin exactly once.
  run :: NotmuchMail -> IO String
  run NotmuchMail{ mailItems } =
    unwords . catMaybes <$> mapConcurrently notmuchSpawn mailItems
   where
    -- | Given a single 'MailItem', shell out to @notmuch@ and get the number
    -- of unread mails, then decide whether what we have is worth printing.
    notmuchSpawn :: MailItem -> IO (Maybe String)
      = \MailItem{ address, name, query } -> do
          -- Shell out to @notmuch@
          let args = [ "search"
                     , tryAdd "to:" address
                     , "tag:unread", tryAdd "and " query
                     ]
          (exitCode, out, _) <- readProcessWithExitCode "notmuch" args []

          -- Only print something when there is at least _some_ new mail
          let numThreads = length (lines out)
          pure $!
            (name <>) . show <$> if   exitCode /= ExitSuccess || numThreads < 1
                                 then Nothing
                                 else Just numThreads

    -- | Only add something to a 'String' if it's not empty.
    tryAdd :: String -> String -> String
      = \prefix str -> if null str then "" else prefix <> str
