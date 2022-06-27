module Config.Xresources where

import Prelude ( ($)
               , (.)
               , (==)
               , (<$>)
               , IO ()
               , Int ()
               , Maybe ()
               , String ()
               , fst
               , snd
               , tail
               , lines
               , splitAt
               , dropWhile
               )

import Data.List ( find
                 , elemIndex
                 , dropWhileEnd
                 )
import Data.Char (isSpace)
import Data.Maybe ( fromMaybe
                  , catMaybes
                  )
import Data.Bifunctor (bimap)

import System.IO.Unsafe (unsafeDupablePerformIO)

import XMonad.Util.Run (runProcessWithInput)

xProperty :: String -> IO String
xProperty k = fromMaybe "" . findValue k <$> runProcessWithInput "xrdb" ["-query"] []

findValue :: String -> String -> Maybe String
findValue k x = snd <$> find ((== k) . fst) (catMaybes $ splitAtColon <$> lines x)

splitAtColon :: String -> Maybe (String, String)
splitAtColon s = splitAtTrimming s <$> elemIndex ':' s

splitAtTrimming :: String -> Int -> (String, String)
splitAtTrimming s i = bimap trim (trim . tail) $ splitAt i s

trim, xprop :: String -> String
trim = dropWhileEnd isSpace . dropWhile isSpace
xprop = unsafeDupablePerformIO . xProperty
