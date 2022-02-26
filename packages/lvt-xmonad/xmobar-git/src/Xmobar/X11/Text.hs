{-# LANGUAGE CPP #-}

-----------------------------------------------------------------------------
-- |
-- Module      :  Xmobar.X11.Text
-- Copyright   :  (C) 2011, 2012, 2013, 2014, 2015, 2017, 2018 Jose Antonio Ortega Ruiz
--                (C) 2007 Andrea Rossato
-- License     :  BSD3
--
-- Maintainer  :  jao@gnu.org
-- Stability   :  unstable
-- Portability :  unportable
--
-----------------------------------------------------------------------------

module Xmobar.X11.Text
    ( XFont(..)
    , initFont
    , initCoreFont
    , initUtf8Font
    , textExtents
    , textWidth
    ) where

import Control.Exception (SomeException, handle)
import Data.List
import Foreign
import Graphics.X11.Xlib hiding (textExtents, textWidth)
import qualified Graphics.X11.Xlib as Xlib (textExtents, textWidth)
import Graphics.X11.Xlib.Extras
import System.Mem.Weak ( addFinalizer )

#if defined XFT
import Xmobar.X11.MinXft
import Graphics.X11.Xrender
#else
import System.IO(hPutStrLn, stderr)
#endif

data XFont = Core FontStruct
           | Utf8 FontSet
#ifdef XFT
           | Xft  [AXftFont]
#endif

-- | When initFont gets a font name that starts with 'xft:' it switchs
-- to the Xft backend Example: 'xft:Sans-10'
initFont :: Display -> String -> IO XFont
initFont d s =
       let xftPrefix = "xft:" in
       if  xftPrefix `isPrefixOf` s then
#ifdef XFT
           fmap Xft $ initXftFont d s
#else
           do
               hPutStrLn stderr $ "Warning: Xmobar must be built with "
                   ++ "the with_xft flag to support font '" ++ s
                   ++ ".' Falling back on default."
               initFont d miscFixedFont
#endif
       else
           fmap Utf8 $ initUtf8Font d s

miscFixedFont :: String
miscFixedFont = "-misc-fixed-*-*-*-*-*-*-*-*-*-*-*-*"

-- | Given a fontname returns the font structure. If the font name is
--  not valid the default font will be loaded and returned.
initCoreFont :: Display -> String -> IO FontStruct
initCoreFont d s = do
  f <- handle fallBack getIt
  addFinalizer f (freeFont d f)
  return f
      where getIt = loadQueryFont d s
            fallBack :: SomeException -> IO FontStruct
            fallBack = const $ loadQueryFont d miscFixedFont

-- | Given a fontname returns the font structure. If the font name is
--  not valid the default font will be loaded and returned.
initUtf8Font :: Display -> String -> IO FontSet
initUtf8Font d s = do
  (_,_,f) <- handle fallBack getIt
  addFinalizer f (freeFontSet d f)
  return f
      where getIt = createFontSet d s
            fallBack :: SomeException -> IO ([String], String, FontSet)
            fallBack = const $ createFontSet d miscFixedFont

#ifdef XFT
initXftFont :: Display -> String -> IO [AXftFont]
initXftFont d s = do
  let fontNames = wordsBy (== ',') (drop 4 s)
  mapM openFont fontNames
  where
    openFont fontName = do
        f <- openAXftFont d (defaultScreenOfDisplay d) fontName
        addFinalizer f (closeAXftFont d f)
        return f
    wordsBy p str = case dropWhile p str of
                        ""   -> []
                        str' -> w : wordsBy p str''
                                where
                                    (w, str'') = break p str'
#endif

textWidth :: Display -> XFont -> String -> IO Int
textWidth _   (Utf8 fs) s = return $ fromIntegral $ wcTextEscapement fs s
textWidth _   (Core fs) s = return $ fromIntegral $ Xlib.textWidth fs s
#ifdef XFT
textWidth dpy (Xft xftdraw) s = do
    gi <- xftTxtExtents' dpy xftdraw s
    return $ xglyphinfo_xOff gi
#endif

textExtents :: XFont -> String -> IO (Int32,Int32)
textExtents (Core fs) s = do
  let (_,a,d,_) = Xlib.textExtents fs s
  return (a,d)
textExtents (Utf8 fs) s = do
  let (_,rl)  = wcTextExtents fs s
      ascent  = fromIntegral $ negate (rect_y rl)
      descent = fromIntegral $ rect_height rl + fromIntegral (rect_y rl)
  return (ascent, descent)
#ifdef XFT
textExtents (Xft xftfonts) _ = do
  ascent  <- fromIntegral `fmap` xft_ascent'  xftfonts
  descent <- fromIntegral `fmap` xft_descent' xftfonts
  return (ascent, descent)
#endif
