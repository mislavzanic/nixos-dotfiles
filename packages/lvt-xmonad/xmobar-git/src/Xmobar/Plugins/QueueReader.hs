{-# LANGUAGE RecordWildCards #-}
module Xmobar.Plugins.QueueReader
  (QueueReader (..)
  ) where

import Xmobar.Run.Exec (Exec (..))

import Control.Monad (forever)
import qualified Control.Concurrent.STM as STM

-- | A 'QueueReader' displays data from an 'TQueue a' where
-- the data items 'a' are rendered by a user supplied function.
--
-- Like the 'HandleReader' plugin this is only useful if you are
-- running @xmobar@ from other Haskell code.  You should create a
-- new @TQueue a@ and pass it to this plugin.
--
-- @
-- main :: IO
-- main = do
--   q <- STM.newQueueIO @String
--   bar <- forkIO $ xmobar conf
--     { commands = Run (QueueReader q id "Queue") : commands conf }
--   STM.atomically $ STM.writeTQueue q "Some Message"
-- @
data QueueReader a
  = QueueReader
  { qQueue    :: STM.TQueue a
  , qShowItem :: a -> String
  , qName :: String
  }

-- | This cannot be read back.
instance Show (QueueReader a) where
  -- | Only show the name/alias for the queue reader.
  show q = "QueueReader " <> qName q

-- | WARNING: This read instance will throw an exception if used! It is
-- only implemented, because it is required by 'Xmobar.Run` in 'Xmobar.commands'.
instance Read (QueueReader a) where
  -- | Throws an 'error'!
  readsPrec = error "QueueReader: instance is a stub"

-- | Async queue/channel reading.
instance Exec (QueueReader a) where
  -- | Read from queue as data arrives.
  start QueueReader{..} cb =
    forever (STM.atomically (qShowItem <$> STM.readTQueue qQueue) >>= cb)

  alias = qName
