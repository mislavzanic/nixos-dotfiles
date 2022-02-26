{-# LANGUAGE ExistentialQuantification  #-}
module Xmobar.Run.Runnable where
import Xmobar.Run.Exec

data Runnable = forall r . (Exec r,Read r,Show r) => Run r

instance Show Runnable
instance Read Runnable
instance Exec Runnable
