module Main (main) where

import Data.IORef (newIORef)
import Data.Time
import Gauge
import Xmobar
import Xmobar.Plugins.Monitors.Cpu

main :: IO ()
main = do
  defaultMain =<< sequence [cpuBench, dateBench]

mkCpuArgs :: IO CpuArguments
mkCpuArgs = getArguments ["-L", "3", "-H", "50", "--normal", "green", "--high", "red", "-t", "Cpu: <total>%"]

cpuBench :: IO Benchmark
cpuBench = do
  cpuArgs <- mkCpuArgs
  return $ bgroup "Cpu Benchmarks"
    [ bench "CPU normal args" $ nfIO (runCpu cpuArgs)
    ]

dateBench :: IO Benchmark
dateBench = do
  let format = "D: %B %d %A W%V"
  zone <- getCurrentTimeZone
  zone' <- newIORef =<< getCurrentTimeZone
  return $ bgroup "Date Benchmarks"
    [ bench "Date" $ nfIO (date zone' format)
    , bench "DateZonedTime" $ nfIO (dateZonedTime format)
    , bench "DateWithTimeZone" $ nfIO (dateWithTimeZone zone format)
    ]

dateZonedTime :: String -> IO String
dateZonedTime format = fmap (formatTime defaultTimeLocale format) getZonedTime

dateWithTimeZone :: TimeZone -> String -> IO String
dateWithTimeZone zone format =
    fmap (formatTime defaultTimeLocale format . utcToZonedTime zone) getCurrentTime
