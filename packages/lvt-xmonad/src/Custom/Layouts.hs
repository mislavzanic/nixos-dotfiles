{-# LANGUAGE FlexibleContexts #-}
module Custom.Layouts where

import Custom.Colors.KaolinAurora

import XMonad hiding ( (|||) ) -- jump to layout
import XMonad.Layout.LayoutCombinators ( (|||) ) -- jump to layout
import XMonad.Hooks.ManageDocks (avoidStruts, docksStartupHook, docksEventHook, manageDocks, ToggleStruts(..))

import Data.Ratio ((%))

import XMonad.Layout.Simplest (Simplest (Simplest))
import XMonad.Layout.SubLayouts (subLayout)
import XMonad.Layout.LayoutModifier
import XMonad.Layout.Renamed (renamed, Rename(Replace))
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing
import XMonad.Layout.LimitWindows (limitWindows)
import XMonad.Layout.Magnifier (MagnifyThis (NoMaster), magnify)
import XMonad.Layout.GridVariants
import XMonad.Layout.ResizableTile
import XMonad.Layout.BinarySpacePartition
import XMonad.Layout.BoringWindows (boringAuto)
import XMonad.Layout.Tabbed ( Theme ( decoWidth
                                    , decoHeight
                                    , activeColor
                                    , urgentColor
                                    , inactiveColor
                                    , activeTextColor
                                    , urgentTextColor
                                    , inactiveTextColor
                                    , activeBorderColor
                                    , activeBorderWidth
                                    , urgentBorderColor
                                    , urgentBorderWidth
                                    , inactiveBorderColor
                                    , inactiveBorderWidth
                                    )
                            , Shrinker (shrinkIt)
                            , def
                            , addTabsBottom
                            )
import XMonad.Layout.MultiToggle ( (??)
                                , EOT (EOT)
                                , Transformer (transform)
                                , mkToggle
                                , mkToggle1
                                )
import XMonad.Layout.MultiToggle.Instances (StdTransformers ( NBFULL
                                                            , NOBORDERS
                                                            )
                                           )
import XMonad.Layout.Renamed ( Rename ( Replace
                                      , CutWordsLeft
                                      )
                             , renamed
                             )


mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

setName :: String -> l a -> ModifiedLayout Rename l a
setName n = renamed [Replace n]

rTall :: Int -> Rational -> Rational -> ResizableTall l
rTall m r c = ResizableTall m r c []

myLayout = layoutOpts $ tiled ||| full where
     layoutOpts = addTabbed . smartBorders . toggleBorders . avoidStruts

     full = setName "Full"
          $ noBorders Full

     -- tiled
     tiled = setName "Tall"
           $ mySpacing 4
           $ ResizableTall 1 (3/100) (1/2) []

     hacking = setName "Hacking"
       . limitWindows 3
       . magnify 1.3 (NoMaster 3) True
       $ mySpacing 4
       $ rTall 1 (3 % 100) (13 % 25)


     -- bsp
     bsp = renamed [Replace "BSP"]
         $ emptyBSP

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

     toggleBorders = mkToggle $ NBFULL ?? NOBORDERS ?? EOT
     addTabbed x = boringAuto . addTabsBottom EmptyShrinker tabTheme . subLayout [] Simplest $ x


data EmptyShrinker = EmptyShrinker deriving (Read, Show)
instance Shrinker EmptyShrinker where
    shrinkIt _ _ = []

cutWords :: Int -> l a -> ModifiedLayout Rename l a
cutWords i = renamed [CutWordsLeft i]

tabTheme :: Theme
tabTheme = def { decoHeight = 4
               , decoWidth = maxBound
               , activeColor = border
               , urgentColor = myppUrgent
               , activeBorderWidth = 0
               , urgentBorderWidth = 0
               , inactiveColor = myNormalBorderColor
               , inactiveBorderWidth = 0
               , activeBorderColor = border
               , inactiveBorderColor = myNormalBorderColor
               }
