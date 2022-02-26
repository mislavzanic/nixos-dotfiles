------------------------------------------------------------------------------
-- |
-- Module: Xmobar.Plugins.Monitors.Run
-- Copyright: (c) 2018 Jose Antonio Ortega Ruiz
-- License: BSD3-style (see LICENSE)
--
-- Maintainer: jao@gnu.org
-- Stability: unstable
-- Portability: portable
-- Created: Sun Dec 02, 2018 04:17
--
--
-- Running a monitor
--
------------------------------------------------------------------------------


module Xmobar.Plugins.Monitors.Common.Run ( runM
                                          , runMD
                                          , runMB
                                          , runMBD
                                          , runML
                                          , runMLD
                                          , getArgvs
                                          , doArgs
                                          , computeMonitorConfig
                                          , pluginOptions
                                          ) where

import Control.Exception (SomeException,handle)
import Data.List
import Control.Monad.Reader
import System.Console.GetOpt

import Xmobar.Plugins.Monitors.Common.Types
import Xmobar.Run.Exec (doEveryTenthSeconds)

pluginOptions :: [OptDescr Opts]
pluginOptions =
    [
      Option ['H'] ["High"] (ReqArg High "number") "The high threshold"
    , Option ['L'] ["Low"] (ReqArg Low "number") "The low threshold"
    , Option "h" ["high"] (ReqArg HighColor "color number") "Color for the high threshold: ex \"#FF0000\""
    , Option "n" ["normal"] (ReqArg NormalColor "color number") "Color for the normal threshold: ex \"#00FF00\""
    , Option "l" ["low"] (ReqArg LowColor "color number") "Color for the low threshold: ex \"#0000FF\""
    , Option "t" ["template"] (ReqArg Template "output template") "Output template."
    , Option "S" ["suffix"] (ReqArg UseSuffix "True/False") "Use % to display percents or other suffixes."
    , Option "d" ["ddigits"] (ReqArg DecDigits "decimal digits") "Number of decimal digits to display."
    , Option "p" ["ppad"] (ReqArg PercentPad "percent padding") "Minimum percentage width."
    , Option "m" ["minwidth"] (ReqArg MinWidth "minimum width") "Minimum field width"
    , Option "M" ["maxwidth"] (ReqArg MaxWidth "maximum width") "Maximum field width"
    , Option "w" ["width"] (ReqArg Width "fixed width") "Fixed field width"
    , Option "e" ["maxwidthellipsis"] (ReqArg WidthEllipsis "Maximum width ellipsis") "Ellipsis to be added to the field when it has reached its max width."
    , Option "c" ["padchars"] (ReqArg PadChars "padding chars") "Characters to use for padding"
    , Option "a" ["align"] (ReqArg PadAlign "padding alignment") "'l' for left padding, 'r' for right"
    , Option "b" ["bback"] (ReqArg BarBack "bar background") "Characters used to draw bar backgrounds"
    , Option "f" ["bfore"] (ReqArg BarFore "bar foreground") "Characters used to draw bar foregrounds"
    , Option "W" ["bwidth"] (ReqArg BarWidth "bar width") "Bar width"
    , Option "x" ["nastring"] (ReqArg NAString "N/A string") "String used when the monitor is not available"
    , Option "T" ["maxtwidth"] (ReqArg MaxTotalWidth "Maximum total width") "Maximum total width"
    , Option "E" ["maxtwidthellipsis"] (ReqArg MaxTotalWidthEllipsis "Maximum total width ellipsis") "Ellipsis to be added to the total text when it has reached its max width."
    ]

-- | Get all argument values out of a list of arguments.
getArgvs :: [String] -> [String]
getArgvs args =
    case getOpt Permute pluginOptions args of
        (_, n, []  ) -> n
        (_, _, errs) -> errs



doArgs :: [String]
       -> ([String] -> Monitor String)
       -> ([String] -> Monitor Bool)
       -> Monitor String
doArgs args action detect =
    case getOpt Permute pluginOptions args of
      (o, n, [])   -> do doConfigOptions o
                         ready <- detect n
                         if ready
                            then action n
                            else return "<Waiting...>"
      (_, _, errs) -> return (concat errs)

doConfigOptions :: [Opts] -> Monitor ()
doConfigOptions [] = io $ return ()
doConfigOptions (o:oo) =
    do let next = doConfigOptions oo
           nz s = let x = read s in max 0 x
           bool = (`elem` ["True", "true", "Yes", "yes", "On", "on"])
       (case o of
          High                  h -> setConfigValue (read h) high
          Low                   l -> setConfigValue (read l) low
          HighColor             c -> setConfigValue (Just c) highColor
          NormalColor           c -> setConfigValue (Just c) normalColor
          LowColor              c -> setConfigValue (Just c) lowColor
          Template              t -> setConfigValue t template
          PercentPad            p -> setConfigValue (nz p) ppad
          DecDigits             d -> setConfigValue (nz d) decDigits
          MinWidth              w -> setConfigValue (nz w) minWidth
          MaxWidth              w -> setConfigValue (nz w) maxWidth
          Width                 w -> setConfigValue (nz w) minWidth >>
                                   setConfigValue (nz w) maxWidth
          WidthEllipsis         e -> setConfigValue e maxWidthEllipsis
          PadChars              s -> setConfigValue s padChars
          PadAlign              a -> setConfigValue ("r" `isPrefixOf` a) padRight
          BarBack               s -> setConfigValue s barBack
          BarFore               s -> setConfigValue s barFore
          BarWidth              w -> setConfigValue (nz w) barWidth
          UseSuffix             u -> setConfigValue (bool u) useSuffix
          NAString              s -> setConfigValue s naString
          MaxTotalWidth         w -> setConfigValue (nz w) maxTotalWidth
          MaxTotalWidthEllipsis e -> setConfigValue e maxTotalWidthEllipsis) >> next

runM :: [String] -> IO MConfig -> ([String] -> Monitor String) -> Int
        -> (String -> IO ()) -> IO ()
runM args conf action r = runML args conf action (doEveryTenthSeconds r)

runMD :: [String] -> IO MConfig -> ([String] -> Monitor String) -> Int
        -> ([String] -> Monitor Bool) -> (String -> IO ()) -> IO ()
runMD args conf action r = runMLD args conf action (doEveryTenthSeconds r)

runMB :: [String] -> IO MConfig -> ([String] -> Monitor String) -> IO ()
        -> (String -> IO ()) -> IO ()
runMB args conf action wait = runMBD args conf action wait (\_ -> return True)

runMBD :: [String] -> IO MConfig -> ([String] -> Monitor String) -> IO ()
        -> ([String] -> Monitor Bool) -> (String -> IO ()) -> IO ()
runMBD args conf action wait detect cb = handle (cb . showException) loop
  where ac = doArgs args action detect
        loop = conf >>= runReaderT ac >>= cb >> wait >> loop

runML :: [String] -> IO MConfig -> ([String] -> Monitor String)
      -> (IO () -> IO ()) -> (String -> IO ()) -> IO ()
runML args conf action looper = runMLD args conf action looper (\_ -> return True)

runMLD :: [String] -> IO MConfig -> ([String] -> Monitor String)
       -> (IO () -> IO ()) -> ([String] -> Monitor Bool) -> (String -> IO ())
       -> IO ()
runMLD args conf action looper detect cb = handle (cb . showException) loop
  where ac = doArgs args action detect
        loop = looper $ conf >>= runReaderT ac >>= cb

showException :: SomeException -> String
showException = ("error: "++) . show . flip asTypeOf undefined

computeMonitorConfig :: [String] -> IO MConfig -> IO MonitorConfig
computeMonitorConfig args mconfig = do
  newConfig <- getMConfig args mconfig
  getMonitorConfig newConfig

getMConfig :: [String] -> IO MConfig -> IO MConfig
getMConfig args mconfig = do
  config <- mconfig
  runReaderT (updateOptions args >> ask) config

updateOptions :: [String] -> Monitor ()
updateOptions args= case getOpt Permute pluginOptions args of
                      (o, _, []) -> doConfigOptions o
                      _ -> return ()
