module Custom.Utils where

import XMonad

spawnList :: [String] -> X ()
spawnList = spawn . unwords

(+++) :: String -> String -> String
a +++ b = a <> [' '] <> b

debugNotif :: MonadIO m => String -> m ()
debugNotif x = spawn $ "notify-send" +++ x
