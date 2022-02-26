{-#LANGUAGE RecordWildCards#-}

------------------------------------------------------------------------------
-- |
-- Module: Xmobar.Plugins.Monitors.Types
-- Copyright: (c) 2018 Jose Antonio Ortega Ruiz
-- License: BSD3-style (see LICENSE)
--
-- Maintainer: jao@gnu.org
-- Stability: unstable
-- Portability: portable
-- Created: Sun Dec 02, 2018 04:31
--
--
-- Type definitions and constructors for Monitors
--
------------------------------------------------------------------------------


module Xmobar.Plugins.Monitors.Common.Types ( Monitor
                                            , MConfig (..)
                                            , Opts (..)
                                            , Selector
                                            , setConfigValue
                                            , mkMConfig
                                            , io
                                            , MonitorConfig (..)
                                            , getPConfigValue
                                            , getConfigValue
                                            , getMonitorConfig
                                            , PSelector
                                            , TemplateInput(..)
                                            ) where

import Control.Monad.Reader (ReaderT, ask, liftIO)
import Data.IORef (IORef, modifyIORef, newIORef, readIORef)


type Monitor a = ReaderT MConfig IO a

io :: IO a -> Monitor a
io = liftIO

data TemplateInput = TemplateInput {
      temMonitorValues :: [String],
      temInputTemplate :: [(String, String, String)],
      temAllTemplate :: [(String, [(String, String, String)])]
    }

data MConfig =
    MC { normalColor :: IORef (Maybe String)
       , low :: IORef Int
       , lowColor :: IORef (Maybe String)
       , high :: IORef Int
       , highColor :: IORef (Maybe String)
       , template :: IORef String
       , export :: IORef [String]
       , ppad :: IORef Int
       , decDigits :: IORef Int
       , minWidth :: IORef Int
       , maxWidth :: IORef Int
       , maxWidthEllipsis :: IORef String
       , padChars :: IORef String
       , padRight :: IORef Bool
       , barBack :: IORef String
       , barFore :: IORef String
       , barWidth :: IORef Int
       , useSuffix :: IORef Bool
       , naString :: IORef String
       , maxTotalWidth :: IORef Int
       , maxTotalWidthEllipsis :: IORef String
       }

data MonitorConfig =
  MonitorConfig
    { pNormalColor :: Maybe String
    , pLow :: Int
    , pLowColor :: Maybe String
    , pHigh :: Int
    , pHighColor :: Maybe String
    , pTemplate :: String
    , pExport :: [String]
    , pPpad :: Int
    , pDecDigits :: Int
    , pMinWidth :: Int
    , pMaxWidth :: Int
    , pMaxWidthEllipsis :: String
    , pPadChars :: String
    , pPadRight :: Bool
    , pBarBack :: String
    , pBarFore :: String
    , pBarWidth :: Int
    , pUseSuffix :: Bool
    , pNaString :: String
    , pMaxTotalWidth :: Int
    , pMaxTotalWidthEllipsis :: String
    }
  deriving (Eq, Ord)

getMonitorConfig :: MConfig -> IO MonitorConfig
getMonitorConfig MC{..} = do
  pNormalColor <- readIORef normalColor
  pLow <- readIORef low
  pLowColor <- readIORef lowColor
  pHigh <- readIORef high
  pHighColor <- readIORef highColor
  pTemplate <- readIORef template
  pExport <- readIORef export
  pPpad <- readIORef ppad
  pDecDigits <- readIORef decDigits
  pMinWidth <- readIORef minWidth
  pMaxWidth <- readIORef maxWidth
  pMaxWidthEllipsis <- readIORef maxWidthEllipsis
  pPadChars <- readIORef padChars
  pPadRight <- readIORef padRight
  pBarBack <- readIORef barBack
  pBarFore <- readIORef barFore
  pBarWidth <- readIORef barWidth
  pUseSuffix <- readIORef useSuffix 
  pNaString <- readIORef naString
  pMaxTotalWidth <- readIORef maxTotalWidth
  pMaxTotalWidthEllipsis <- readIORef maxTotalWidthEllipsis
  pure $ MonitorConfig {..}

-- | from 'http:\/\/www.haskell.org\/hawiki\/MonadState'
type Selector a = MConfig -> IORef a
type PSelector a = MonitorConfig -> a

psel :: MonitorConfig -> PSelector a -> a
psel value accessor = accessor value

sel :: Selector a -> Monitor a
sel s =
    do hs <- ask
       liftIO $ readIORef (s hs)

mods :: Selector a -> (a -> a) -> Monitor ()
mods s m =
    do v <- ask
       io $ modifyIORef (s v) m

setConfigValue :: a -> Selector a -> Monitor ()
setConfigValue v s =
       mods s (const v)

getConfigValue :: Selector a -> Monitor a
getConfigValue = sel

getPConfigValue :: MonitorConfig -> PSelector a -> a
getPConfigValue = psel

mkMConfig :: String
          -> [String]
          -> IO MConfig
mkMConfig tmpl exprts =
    do lc <- newIORef Nothing
       l  <- newIORef 33
       nc <- newIORef Nothing
       h  <- newIORef 66
       hc <- newIORef Nothing
       t  <- newIORef tmpl
       e  <- newIORef exprts
       p  <- newIORef 0
       d  <- newIORef 0
       mn <- newIORef 0
       mx <- newIORef 0
       mel <- newIORef ""
       pc <- newIORef " "
       pr <- newIORef False
       bb <- newIORef ":"
       bf <- newIORef "#"
       bw <- newIORef 10
       up <- newIORef False
       na <- newIORef "N/A"
       mt <- newIORef 0
       mtel <- newIORef ""
       return $ MC nc l lc h hc t e p d mn mx mel pc pr bb bf bw up na mt mtel

data Opts = HighColor String
          | NormalColor String
          | LowColor String
          | Low String
          | High String
          | Template String
          | PercentPad String
          | DecDigits String
          | MinWidth String
          | MaxWidth String
          | Width String
          | WidthEllipsis String
          | PadChars String
          | PadAlign String
          | BarBack String
          | BarFore String
          | BarWidth String
          | UseSuffix String
          | NAString String
          | MaxTotalWidth String
          | MaxTotalWidthEllipsis String
