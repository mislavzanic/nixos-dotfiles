{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Xmobar.Plugins.Kraken (Kraken(..)) where

import Control.Concurrent (MVar, newEmptyMVar, putMVar, takeMVar)
import Control.Concurrent.Async (async, cancel)
import Control.Exception (bracket, catch)
import Control.Monad (forever, mzero, void, when)
import Data.Aeson
import Data.Aeson.Types (Parser, typeMismatch)
import Data.List (sort)
import Data.Text (Text, pack, unpack)
import GHC.Generics
import Network.WebSockets (ClientApp, ConnectionException(ConnectionClosed), receiveData, sendTextData)
import System.IO (hPutStrLn, stderr)
import Text.Read (readMaybe)
import Wuss (runSecureClient)
import Xmobar.Run.Exec(Exec(..))

import qualified Data.HashMap.Lazy as HML (lookup)
import qualified Data.Map as Map
import qualified Data.Vector as V

data Kraken = Kraken [String] String
  deriving (Read, Show)

instance Exec Kraken where
  alias (Kraken _ a) = a
  start (Kraken ps _) cb = do
    mvar <- newEmptyMVar 
    bracket (async $ reconnectOnConnectionClose $ wsClientApp ps mvar) cancel $ \_ -> do
      let loop mv p = do
           v <- takeMVar mv
           let g = Map.insert (unpack $ fst v) (snd v) p
           cb (display g)
           loop mv g

      loop mvar (Map.fromList $ zip ps (repeat 0.0))

    where
      display :: Map.Map String Double -> String 
      display m = unwords $ sort $ map (\x -> fst x ++ ": " ++ show (snd x)) $ Map.toList m

      reconnectOnConnectionClose :: ClientApp () -> IO ()
      reconnectOnConnectionClose ws = runSecureClient "ws.kraken.com" 443 "/" ws
        `catch` (\e -> when (e == ConnectionClosed) $ reconnectOnConnectionClose ws)

wsClientApp :: [String] -> MVar (Text, Double)  -> ClientApp ()
wsClientApp ps mvar connection = do
  sendTextData connection (encode Subscribe { event = "subscribe", pair = map pack ps, subscription = Subscription { name = "ticker" }})
  void . forever $ do
    message <- receiveData connection
    case (eitherDecode message :: Either String Message) of
      Right m ->
        case m of
          TickerMessage _ ti _ tp  -> putMVar mvar (tp, askPrice $ ask ti)
          _ -> return ()
      Left e -> hPutStrLn stderr e

data Ask = Ask {
    askPrice :: Double
  , askWholeLotVolume :: Int
  , askLotVolume :: Double
  } deriving Show

parseDoubleString :: Value -> Parser Double
parseDoubleString v = do
  j <- parseJSON v
  case readMaybe j of
    Just num -> return num
    Nothing -> typeMismatch "Double inside a String" v

instance FromJSON Ask where 
  parseJSON (Array v)
    | V.length v == 3 = do
      p <- parseDoubleString $ v V.! 0
      w <- parseJSON $ v V.! 1
      l <- parseDoubleString $ v V.! 2
      return Ask { askPrice = p, askWholeLotVolume = w, askLotVolume = l }
    | otherwise = mzero
  parseJSON nonArray = typeMismatch "Array" nonArray

data Bid = Bid {
    bidPrice :: Double
  , bidWholeLotVolume :: Int
  , bidLotVolume :: Double
  } deriving Show

instance FromJSON Bid where 
  parseJSON (Array v)
    | V.length v == 3 = do
      p <- parseDoubleString $ v V.! 0
      w <- parseJSON $ v V.! 1
      l <- parseDoubleString $ v V.! 2
      return Bid { bidPrice = p, bidWholeLotVolume = w, bidLotVolume = l }
    | otherwise = mzero
  parseJSON nonArray = typeMismatch "Array" nonArray

data Close = Close {
    closePrice :: Double
  , closeLotVolume :: Double
  } deriving Show

instance FromJSON Close where 
  parseJSON (Array v)
    | V.length v == 2 = do
      p <- parseDoubleString $ v V.! 0
      l <- parseDoubleString $ v V.! 1
      return Close { closePrice= p, closeLotVolume = l }
    | otherwise = mzero
  parseJSON nonArray = typeMismatch "Array" nonArray

data TickerInformation = TickerInformation {
    ask :: Ask
  , bid :: Bid
  , close :: Close
  } deriving Show

instance FromJSON TickerInformation where 
  parseJSON = withObject "P" $ \v -> TickerInformation
    <$> v .: "a"
    <*> v .: "b"
    <*> v .: "c"
  
data Message =
    Heartbeat
  | TickerMessage { channelId :: Int, tickerInformation :: TickerInformation, channelName :: Text, tickerPair :: Text }
  | SubscriptionStatus { channelName :: Text, status :: Text, subscriptionPair :: Text }
  | SystemStatus { connectionId :: Integer, status :: Text, version :: Text }
  | UnrecognizedMessage String
  deriving Show

newtype Subscription = Subscription { name :: Text } deriving (Generic, Show)
instance ToJSON Subscription where
  toEncoding = genericToEncoding defaultOptions

data Subscribe = Subscribe { event :: Text, pair :: [Text], subscription :: Subscription } deriving (Generic, Show)
instance ToJSON Subscribe where
  toEncoding = genericToEncoding defaultOptions

instance FromJSON Message where
  parseJSON (Object o) = case HML.lookup (pack "event") o of
    Just (String "heartbeat") -> pure Heartbeat
    Just (String "systemStatus") -> systemStatus o
    Just (String "subscriptionStatus") -> subscriptionStatus o
    Just eventType -> pure $ UnrecognizedMessage $ "Unrecognized event type " ++ show eventType
    Nothing -> pure $ UnrecognizedMessage "Missing event"
    where
      systemStatus obj = SystemStatus <$> obj .: "connectionID" <*> obj .: "status" <*> obj .: "version"
      subscriptionStatus obj = SubscriptionStatus <$> obj .: "channelName" <*> obj .: "status" <*> obj .: "pair"
  parseJSON (Array a)
    | V.length a == 4 = do
      cId   <- parseJSON $ a V.! 0
      info  <- parseJSON $ a V.! 1
      cName <- parseJSON $ a V.! 2
      p     <- parseJSON $ a V.! 3
      pure TickerMessage { channelId = cId, tickerInformation = info, channelName = cName, tickerPair = p }
    | otherwise = mzero
  parseJSON v = typeMismatch "Object or Array" v
