------------------------------------------------------------------------------
-- |
-- Module: Xmobar.Template
-- Copyright: (c) 2018 Jose Antonio Ortega Ruiz
-- License: BSD3-style (see LICENSE)
--
-- Maintainer: jao@gnu.org
-- Stability: unstable
-- Portability: portable
-- Created: Sun Nov 25, 2018 05:49
--
--
-- Handling the top-level output template
--
------------------------------------------------------------------------------


module Xmobar.Run.Template(parseTemplate, splitTemplate) where

import qualified Data.Map as Map
import Text.ParserCombinators.Parsec

import Xmobar.Run.Exec
import Xmobar.Run.Command
import Xmobar.Run.Runnable

defaultAlign :: String
defaultAlign = "}{"

allTillSep :: String -> Parser String
allTillSep = many . noneOf

-- | Parses the output template string
templateStringParser :: String -> Parser (String,String,String)
templateStringParser sepChar = do
  s   <- allTillSep sepChar
  com <- templateCommandParser sepChar
  ss  <- allTillSep sepChar
  return (com, s, ss)

-- | Parses the command part of the template string
templateCommandParser :: String -> Parser String
templateCommandParser sepChar =
  let chr = char (head sepChar) in between chr chr (allTillSep sepChar)

-- | Combines the template parsers
templateParser :: String -> Parser [(String,String,String)]
templateParser s = many $ templateStringParser s

-- | Actually runs the template parsers over a (segment of) a template
-- string, returning a list of runnables with their prefix and suffix.
parseTemplate :: [Runnable] -> String -> String -> IO [(Runnable,String,String)]
parseTemplate c sepChar s =
    do str <- case parse (templateParser sepChar) "" s of
                Left _  -> return [("", s, "")]
                Right x -> return x
       let cl = map alias c
           m  = Map.fromList $ zip cl c
       return $ combine c m str

-- | Given a finite "Map" and a parsed template produce the resulting
-- output string.
combine :: [Runnable] -> Map.Map String Runnable -> [(String, String, String)]
           -> [(Runnable,String,String)]
combine _ _ [] = []
combine c m ((ts,s,ss):xs) = (com, s, ss) : combine c m xs
    where com  = Map.findWithDefault dflt ts m
          dflt = Run $ Com ts [] [] 10

-- | Given an two-char alignment separator and a template string,
-- splits it into its segments, that can then be parsed via parseCommands
splitTemplate :: String -> String -> [String]
splitTemplate alignSep template =
  case break (==l) template of
    (le,_:re) -> case break (==r) re of
                   (ce,_:ri) -> [le, ce, ri]
                   _         -> def
    _         -> def
  where [l, r] = if length alignSep == 2 then alignSep else defaultAlign
        def = [template, "", ""]
