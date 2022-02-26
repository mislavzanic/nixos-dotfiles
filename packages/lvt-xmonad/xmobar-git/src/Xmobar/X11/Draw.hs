{-# LANGUAGE CPP #-}
{-# LANGUAGE TupleSections #-}

------------------------------------------------------------------------------
-- |
-- Module: Xmobar.X11.Draw
-- Copyright: (c) 2018, 2020 Jose Antonio Ortega Ruiz
-- License: BSD3-style (see LICENSE)
--
-- Maintainer: jao@gnu.org
-- Stability: unstable
-- Portability: portable
-- Created: Sat Nov 24, 2018 18:49
--
--
-- Drawing the xmobar contents
--
------------------------------------------------------------------------------


module Xmobar.X11.Draw (drawInWin) where

import Prelude hiding (lookup)
import Control.Monad.IO.Class
import Control.Monad.Reader
import Control.Arrow ((&&&))
import Data.Map hiding ((\\), foldr, map, filter)
import Data.List ((\\))
import qualified Data.List.NonEmpty as NE

import Graphics.X11.Xlib hiding (textExtents, textWidth)
import Graphics.X11.Xlib.Extras

import Xmobar.Config.Types
import qualified Xmobar.X11.Bitmap as B
import Xmobar.X11.Actions (Action(..))
import Xmobar.X11.Types
import Xmobar.X11.Text
import Xmobar.X11.ColorCache
import Xmobar.X11.Window (drawBorder)
import Xmobar.X11.Parsers hiding (parseString)
import Xmobar.System.Utils (safeIndex)

#ifdef XFT
import Xmobar.X11.MinXft
import Graphics.X11.Xrender
#endif

fi :: (Integral a, Num b) => a -> b
fi = fromIntegral

-- | Draws in and updates the window
drawInWin :: Rectangle -> [[(Widget, TextRenderInfo, Int, Maybe [Action])]] -> X ()
drawInWin wr@(Rectangle _ _ wid ht) ~[left,center,right] = do
  r <- ask
  let (c,d) = (config &&& display) r
      (w,(fs,vs)) = (window &&& fontListS &&& verticalOffsets) r
      strLn = liftIO . mapM getWidth
      iconW i = maybe 0 B.width (lookup i $ iconS r)
      getWidth (Text s,cl,i,_) =
        textWidth d (safeIndex fs i) s >>= \tw -> return (Text s,cl,i,fi tw)
      getWidth (Icon s,cl,i,_) = return (Icon s,cl,i,fi $ iconW s)
      getWidth (Hspace p,cl,i,_) = return (Hspace p,cl,i,fi p)

  p <- liftIO $ createPixmap d w wid ht
                         (defaultDepthOfScreen (defaultScreenOfDisplay d))
#if XFT
  when (alpha c /= 255) (liftIO $ drawBackground d p (bgColor c) (alpha c) wr)
#else
  _ <- return wr
#endif
  withColors d [bgColor c, borderColor c] $ \[bgcolor, bdcolor] -> do
    gc <- liftIO $ createGC  d w
#if XFT
    when (alpha c == 255) $ do
#else
    do
#endif
      liftIO $ setForeground d gc bgcolor
      liftIO $ fillRectangle d p gc 0 0 wid ht
    -- write to the pixmap the new string
    printStrings p gc fs vs 1 L [] =<< strLn left
    printStrings p gc fs vs 1 R [] =<< strLn right
    printStrings p gc fs vs 1 C [] =<< strLn center
    -- draw border if requested
    liftIO $ drawBorder (border c) (borderWidth c) d p gc bdcolor wid ht
    -- copy the pixmap with the new string to the window
    liftIO $ copyArea d p w gc 0 0 wid ht 0 0
    -- free up everything (we do not want to leak memory!)
    liftIO $ freeGC d gc
    liftIO $ freePixmap d p
    -- resync
    liftIO $ sync d False

verticalOffset :: (Integral b, Integral a, MonadIO m) =>
                  a -> Widget -> XFont -> Int -> Config -> m b
verticalOffset ht (Text t) fontst voffs _
  | voffs > -1 = return $ fi voffs
  | otherwise = do
     (as,ds) <- liftIO $ textExtents fontst t
     let margin = (fi ht - fi ds - fi as) `div` 2
     return $ fi as + margin - 1
verticalOffset ht (Icon _) _ _ conf
  | iconOffset conf > -1 = return $ fi (iconOffset conf)
  | otherwise = return $ fi (ht `div` 2) - 1
verticalOffset _ (Hspace _) _ voffs _ = return $ fi voffs

printString :: Display -> Drawable -> XFont -> GC -> String -> String
            -> Position -> Position -> Position -> Position -> String -> Int -> IO ()
printString d p (Core fs) gc fc bc x y _ _ s a = do
    setFont d gc $ fontFromFontStruct fs
    withColors d [fc, bc] $ \[fc', bc'] -> do
      setForeground d gc fc'
      when (a == 255) (setBackground d gc bc')
      drawImageString d p gc x y s

printString d p (Utf8 fs) gc fc bc x y _ _ s a =
    withColors d [fc, bc] $ \[fc', bc'] -> do
      setForeground d gc fc'
      when (a == 255) (setBackground d gc bc')
      liftIO $ wcDrawImageString d p fs gc x y s

#ifdef XFT
printString dpy drw fs@(Xft fonts) _ fc bc x y ay ht s al =
  withDrawingColors dpy drw fc bc $ \draw fc' bc' -> do
    when (al == 255) $ do
      (a,d)  <- textExtents fs s
      gi <- xftTxtExtents' dpy fonts s
      if ay < 0
        then drawXftRect draw bc' x (y - a) (1 + xglyphinfo_xOff gi) (a + d + 2)
        else drawXftRect draw bc' x ay (1 + xglyphinfo_xOff gi) ht
    drawXftString' draw fc' fonts (toInteger x) (toInteger y) s
#endif

-- | An easy way to print the stuff we need to print
printStrings :: Drawable -> GC -> NE.NonEmpty XFont -> NE.NonEmpty Int -> Position
             -> Align -> [((Position, Position), Box)] -> [(Widget, TextRenderInfo, Int, Position)] -> X ()
printStrings _ _ _ _ _ _ _ [] = return ()
printStrings dr gc fontlist voffs offs a boxes sl@((s,c,i,l):xs) = do
  r <- ask
  let (conf,d) = (config &&& display) r
      alph = alpha conf
      Rectangle _ _ wid ht = rect r
      totSLen = foldr (\(_,_,_,len) -> (+) len) 0 sl
      remWidth = fi wid - fi totSLen
      fontst = safeIndex fontlist i
      voff = safeIndex voffs i
      offset = case a of
                 C -> (remWidth + offs) `div` 2
                 R -> remWidth
                 L -> offs
      (fc,bc) = case break (==',') (tColorsString c) of
                 (f,',':b) -> (f, b           )
                 (f,    _) -> (f, bgColor conf)
  valign <- verticalOffset ht s fontst voff conf
  let (ht',ay) = case (tBgTopOffset c, tBgBottomOffset c) of
                   (-1,_)  -> (0, -1)
                   (_,-1)  -> (0, -1)
                   (ot,ob) -> (fromIntegral ht - ot - ob, ob)
  case s of
    (Text t) -> liftIO $ printString d dr fontst gc fc bc offset valign ay ht' t alph
    (Icon p) -> liftIO $ maybe (return ())
                           (B.drawBitmap d dr gc fc bc offset valign)
                           (lookup p (iconS r))
    (Hspace _) -> liftIO $ return ()
  let triBoxes = tBoxes c
      dropBoxes = filter (\(_,b) -> b `notElem` triBoxes) boxes
      boxes' = map (\((x1,_),b) -> ((x1, offset + l), b)) (filter (\(_,b) -> b `elem` triBoxes) boxes)
            ++ map ((offset, offset + l),) (triBoxes \\ map snd boxes)
  if Prelude.null xs
    then liftIO $ drawBoxes d dr gc (fromIntegral ht) (dropBoxes ++ boxes')
    else liftIO $ drawBoxes d dr gc (fromIntegral ht) dropBoxes
  printStrings dr gc fontlist voffs (offs + l) a boxes' xs

drawBoxes :: Display -> Drawable -> GC -> Position -> [((Position, Position), Box)] -> IO ()
drawBoxes _ _ _ _ [] = return ()
drawBoxes d dr gc ht (b:bs) = do
  let (xx, Box bb offset lineWidth fc mgs) = b
      lw = fromIntegral lineWidth :: Position
  withColors d [fc] $ \[fc'] -> do
    setForeground d gc fc'
    setLineAttributes d gc lineWidth lineSolid capNotLast joinMiter
    case bb of
      BBVBoth -> do
        drawBoxBorder d dr gc BBTop    offset ht xx lw mgs
        drawBoxBorder d dr gc BBBottom offset ht xx lw mgs
      BBHBoth -> do
        drawBoxBorder d dr gc BBLeft   offset ht xx lw mgs
        drawBoxBorder d dr gc BBRight  offset ht xx lw mgs
      BBFull  -> do
        drawBoxBorder d dr gc BBTop    offset ht xx lw mgs
        drawBoxBorder d dr gc BBBottom offset ht xx lw mgs
        drawBoxBorder d dr gc BBLeft   offset ht xx lw mgs
        drawBoxBorder d dr gc BBRight  offset ht xx lw mgs
      _ -> drawBoxBorder d dr gc bb    offset ht xx lw mgs
  drawBoxes d dr gc ht bs

drawBoxBorder :: Display -> Drawable -> GC -> BoxBorder -> BoxOffset -> Position
                 -> (Position, Position) -> Position -> BoxMargins -> IO ()
drawBoxBorder d dr gc pos (BoxOffset alg offset) ht (x1,x2) lw (BoxMargins mt mr mb ml) = do
  let (p1,p2) = case alg of
                 L -> (0,      -offset)
                 C -> (offset, -offset)
                 R -> (offset, 0      )
      lc = lw `div` 2
  case pos of
    BBTop    -> drawLine d dr gc (x1 + p1) (mt + lc) (x2 + p2) (mt + lc)
    BBBottom -> do
      let lc' = max lc 1 + mb
      drawLine d dr gc (x1 + p1) (ht - lc') (x2 + p2) (ht - lc')
    BBLeft   -> drawLine d dr gc (x1 - 1 + ml) p1 (x1 - 1 + ml) (ht + p2)
    BBRight  -> drawLine d dr gc (x2 + lc - 1 - mr) p1 (x2 + lc - 1 - mr) (ht + p2)
    _ -> error "unreachable code"
