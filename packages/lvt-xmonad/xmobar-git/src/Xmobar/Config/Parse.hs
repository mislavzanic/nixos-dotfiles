{-# LANGUAGE FlexibleContexts, CPP #-}
------------------------------------------------------------------------------
-- |
-- Module: Xmobar.Config.Parse
-- Copyright: (c) 2018, 2020 Jose Antonio Ortega Ruiz
-- License: BSD3-style (see LICENSE)
--
-- Maintainer: jao@gnu.org
-- Stability: unstable
-- Portability: portable
-- Created: Sun Nov 25, 2018 23:56
--
--
-- Parsing of configuration files
--
------------------------------------------------------------------------------


module Xmobar.Config.Parse(readConfig, parseConfig) where

import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Number (int)
import Text.ParserCombinators.Parsec.Perm ((<|?>), (<$?>), permute)
import Control.Monad.IO.Class (liftIO)
import Data.Functor ((<&>))

import Xmobar.Config.Types

#if defined XFT || defined UTF8
import qualified System.IO as S (readFile)
#endif

readFileSafe :: FilePath -> IO String
#if defined XFT || defined UTF8
readFileSafe = S.readFile
#else
readFileSafe = readFile
#endif

stripComments :: String -> String
stripComments =
  unlines . map (drop 5 . strip False . (replicate 5 ' '++)) . lines
    where strip m ('-':'-':xs) = if m then "--" ++ strip m xs else ""
          strip m ('"':xs) = '"': strip (not m) xs
          strip m (x:xs) = x : strip m xs
          strip _ [] = []

-- | Parse the config, logging a list of fields that were missing and replaced
-- by the default definition.
parseConfig :: Config -> String -> Either ParseError (Config,[String])
parseConfig defaultConfig =
  runParser parseConf fields "Config" . stripComments
    where
      parseConf = do
        many space
        sepEndSpc ["Config","{"]
        x <- perms
        eof
        s <- getState
        return (x, s)

      perms = permute $ Config
              <$?> pFont <|?> pFontList <|?> pWmClass <|?> pWmName
              <|?> pBgColor <|?> pFgColor
              <|?> pPosition <|?> pTextOffset <|?> pTextOffsets
              <|?> pIconOffset <|?> pBorder
              <|?> pBdColor <|?> pBdWidth <|?> pAlpha <|?> pHideOnStart
              <|?> pAllDesktops <|?> pOverrideRedirect <|?> pPickBroadest
              <|?> pLowerOnStart <|?> pPersistent <|?> pIconRoot
              <|?> pCommands <|?> pSepChar <|?> pAlignSep <|?> pTemplate
              <|?> pVerbose <|?> pSignal

      fields    = [ "font", "additionalFonts","bgColor", "fgColor"
                  , "wmClass", "wmName", "sepChar"
                  , "alignSep" , "border", "borderColor" ,"template"
                  , "position" , "textOffset", "textOffsets", "iconOffset"
                  , "allDesktops", "overrideRedirect", "pickBroadest"
                  , "hideOnStart", "lowerOnStart", "persistent", "iconRoot"
                  , "alpha", "commands", "verbose", "signal"
                  ]

      pFont = strField font "font"
      pFontList = strListField additionalFonts "additionalFonts"
      pWmClass = strField wmClass "wmClass"
      pWmName = strField wmName "wmName"
      pBgColor = strField bgColor "bgColor"
      pFgColor = strField fgColor "fgColor"
      pBdColor = strField borderColor "borderColor"
      pSepChar = strField sepChar "sepChar"
      pAlignSep = strField alignSep "alignSep"
      pTemplate = strField template "template"

      pTextOffset = readField textOffset "textOffset"
      pTextOffsets = readIntList textOffsets "textOffsets"
      pIconOffset = readField iconOffset "iconOffset"
      pPosition = readField position "position"
      pHideOnStart = readField hideOnStart "hideOnStart"
      pLowerOnStart = readField lowerOnStart "lowerOnStart"
      pPersistent = readField persistent "persistent"
      pBorder = readField border "border"
      pBdWidth = readField borderWidth "borderWidth"
      pAllDesktops = readField allDesktops "allDesktops"
      pOverrideRedirect = readField overrideRedirect "overrideRedirect"
      pPickBroadest = readField pickBroadest "pickBroadest"
      pIconRoot = readField iconRoot "iconRoot"
      pAlpha = readField alpha "alpha"
      pVerbose = readField verbose "verbose"

      pSignal = field signal "signal" $
        fail "signal is meant for use with Xmobar as a library.\n It is not meant for use in the configuration file."

      pCommands = field commands "commands" readCommands

      staticPos = do string "Static"
                     wrapSkip (string "{")
                     p <- many (noneOf "}")
                     wrapSkip (string "}")
                     string ","
                     return ("Static {"  ++ p  ++ "}")
      tillFieldEnd = staticPos <|> many (noneOf ",}\n\r")

      commandsEnd  = wrapSkip (string "]") >> (string "}" <|> notNextRun)
      notNextRun = do {string ","
                      ; notFollowedBy $ wrapSkip $ string "Run"
                      ; return ","
                      }
      readCommands = manyTill anyChar (try commandsEnd) >>=
                        read' commandsErr . flip (++) "]"
      strField e n = field e n strMulti

      strMulti = scan '"'
          where
            scan lead = do
                spaces
                char lead
                s <- manyTill anyChar (rowCont <|> unescQuote)
                (char '"' >> return s) <|> fmap (s ++) (scan '\\')
            rowCont    = try $ char '\\' >> string "\n"
            unescQuote = lookAhead (noneOf "\\") >> lookAhead (string "\"")

      strListField e n = field e n strList
      strList = do
        spaces
        char '['
        list <- sepBy (strMulti >>= \x -> spaces >> return x) (char ',')
        spaces
        char ']'
        return list

      wrapSkip   x = many space >> x >>= \r -> many space >> return r
      sepEndSpc    = mapM_ (wrapSkip . try . string)
      fieldEnd     = many $ space <|> oneOf ",}"
      field  e n c = (,) (e defaultConfig) $
                     updateState (filter (/= n)) >> sepEndSpc [n,"="] >>
                     wrapSkip c >>= \r -> fieldEnd >> return r
      readField a n = field a n $ tillFieldEnd >>= read' n

      readIntList d n = field d n intList
      intList = do
        spaces
        char '['
        list <- sepBy (spaces >> int >>= \x-> spaces >> return x) (char ',')
        spaces
        char ']'
        return list

      read' d s = case reads s of
                    [(x, _)] -> return x
                    _ -> fail $ "error reading the " ++ d ++ " field: " ++ s

commandsErr :: String
commandsErr = "commands: this usually means that a command could not" ++
              "\nbe parsed." ++
              "\nThe error could be located at the begining of the command" ++
              "\nwhich follows the offending one."

-- | Reads the configuration from a file or an error if it cannot be
-- parsed.
readConfig :: Config -> FilePath -> IO (Either ParseError (Config,[String]))
readConfig defaultConfig f =
  liftIO (readFileSafe f) <&> parseConfig defaultConfig
