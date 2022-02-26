------------------------------------------------------------------------------
-- |
-- Module: Xmobar.App.Main
-- Copyright: (c) 2018, 2019, 2020 Jose Antonio Ortega Ruiz
-- License: BSD3-style (see LICENSE)
--
-- Maintainer: jao@gnu.org
-- Stability: unstable
-- Portability: portable
-- Created: Sun Nov 25, 2018 21:53
--
--
-- Support for creating executable main functions
--
------------------------------------------------------------------------------


module Xmobar.App.Main (xmobar, xmobarMain, configFromArgs) where

import Control.Concurrent.Async (Async, cancel)
import Control.Concurrent.STM (newEmptyTMVarIO)
import Control.Exception (bracket)
import Control.Monad (unless)

import Data.Foldable (for_)
import qualified Data.Map as Map
import Data.List (intercalate)
import Data.Maybe (isJust)
import System.Posix.Process (executeFile)
import System.Environment (getArgs)
import System.FilePath ((</>), takeBaseName, takeDirectory, takeExtension)
import Text.Parsec.Error (ParseError)
import Data.List.NonEmpty (NonEmpty(..))

import Graphics.X11.Xlib

import Xmobar.Config.Types
import Xmobar.Config.Parse
import Xmobar.System.Signal (setupSignalHandler, withDeferSignals)
import Xmobar.Run.Template
import Xmobar.X11.Types
import Xmobar.X11.Text
import Xmobar.X11.Window
import Xmobar.App.Opts (recompileFlag, verboseFlag, getOpts, doOpts)
import Xmobar.App.EventLoop (startLoop, startCommand, newRefreshLock, refreshLock)
import Xmobar.App.Compile (recompile, trace)
import Xmobar.App.Config
import Xmobar.App.Timer (withTimer)

xmobar :: Config -> IO ()
xmobar conf = withDeferSignals $ do
  initThreads
  d <- openDisplay ""
  fs    <- initFont d (font conf)
  fl    <- mapM (initFont d) (additionalFonts conf)
  cls   <- mapM (parseTemplate (commands conf) (sepChar conf))
                (splitTemplate (alignSep conf) (template conf))
  let confSig = unSignalChan (signal conf)
  sig   <- maybe newEmptyTMVarIO pure confSig
  unless (isJust confSig) $ setupSignalHandler sig
  refLock <- newRefreshLock
  withTimer (refreshLock refLock) $
    bracket (mapM (mapM $ startCommand sig) cls)
            cleanupThreads
            $ \vars -> do
      (r,w) <- createWin d fs conf
      let ic = Map.empty
          to = textOffset conf
          ts = textOffsets conf ++ replicate (length fl) (-1)
      startLoop (XConf d r w (fs :| fl) (to :| ts) ic conf) sig refLock vars

configFromArgs :: Config -> IO Config
configFromArgs cfg = getArgs >>= getOpts >>= doOpts cfg . fst

cleanupThreads :: [[([Async ()], a)]] -> IO ()
cleanupThreads vars =
  for_ (concat vars) $ \(asyncs, _) ->
    for_ asyncs cancel

buildLaunch :: [String] -> Bool -> Bool -> String -> ParseError -> IO ()
buildLaunch args verb force p e = do
  let exec = takeBaseName p
      confDir = takeDirectory p
      ext = takeExtension p
  if ext `elem` [".hs", ".hsc", ".lhs"]
    then xmobarDataDir >>= \dd -> recompile confDir dd exec force verb >>
         executeFile (confDir </> exec) False args Nothing
    else trace True ("Invalid configuration file: " ++ show e) >>
         trace True "\n(No compilation attempted: \
                    \only .hs, .hsc or .lhs files are compiled)"

xmobar' :: [String] -> Config -> IO ()
xmobar' defs cfg = do
  unless (null defs || not (verbose cfg)) $ putStrLn $
    "Fields missing from config defaulted: " ++ intercalate "," defs
  xmobar cfg

xmobarMain :: IO ()
xmobarMain = do
  args <- getArgs
  (flags, rest) <- getOpts args
  cf <- case rest of
          [c] -> return (Just c)
          [] -> xmobarConfigFile
          _ -> error $ "Too many arguments: " ++ show rest
  case cf of
    Nothing -> case rest of
                (c:_) -> error $ c ++ ": file not found"
                _ -> doOpts defaultConfig flags >>= xmobar
    Just p -> do r <- readConfig defaultConfig p
                 case r of
                   Left e ->
                     buildLaunch (filter (/= p) args) (verboseFlag flags) (recompileFlag flags) p e
                   Right (c, defs) -> doOpts c flags >>= xmobar' defs
