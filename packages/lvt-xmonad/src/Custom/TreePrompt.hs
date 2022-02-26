module Custom.TreePrompt where

import XMonad

import qualified XMonad.Actions.TreeSelect as TS
import qualified Data.Map as M
import Data.Tree

import Custom.Vars

tsDefaultConfig :: TS.TSConfig a
tsDefaultConfig = TS.TSConfig { TS.ts_hidechildren = True
                              , TS.ts_background   = 0xdd14191e
                              , TS.ts_font         = myFont
                              , TS.ts_node         = (0xffd0d0d0, 0xff202331)
                              , TS.ts_nodealt      = (0xffd0d0d0, 0xff292d3e)
                              , TS.ts_highlight    = (0xff000000, 0xff8265e6)
                              , TS.ts_extra        = 0xffd0d0d0
                              , TS.ts_node_width   = 200
                              , TS.ts_node_height  = 20
                              , TS.ts_originX      = 0
                              , TS.ts_originY      = 0
                              , TS.ts_indent       = 80
                              , TS.ts_navigate     = myTreeNavigation
                              }
myTreeNavigation = M.fromList
    [ ((0, xK_Escape),   TS.cancel)
    , ((0, xK_Return),   TS.select)
    , ((0, xK_space),    TS.select)
    , ((0, xK_Up),       TS.movePrev)
    , ((0, xK_Down),     TS.moveNext)
    , ((0, xK_Left),     TS.moveParent)
    , ((0, xK_Right),    TS.moveChild)
    , ((0, xK_k),        TS.movePrev)
    , ((0, xK_j),        TS.moveNext)
    , ((0, xK_h),        TS.moveParent)
    , ((0, xK_l),        TS.moveChild)
    , ((0, xK_o),        TS.moveHistBack)
    , ((0, xK_i),        TS.moveHistForward)
    ]


treeselectAction :: TS.TSConfig (X ()) -> X ()
treeselectAction a = TS.treeselectAction a
   [ Node (TS.TSNode "config files" "" (return ()))
     [Node (TS.TSNode (fst3 $ myConfigs !! n)
                      (thd3 $ myConfigs !! n)
                      (spawn $ snd3 $ myConfigs !! n)
           ) [] | n <- [0..(length myConfigs - 1)]
     ]
   ]


fst3 :: (a,b,c) -> a
fst3 (a,b,c) = a

snd3:: (a,b,c) -> b
snd3 (a,b,c) = b

thd3 :: (a,b,c) -> c
thd3 (a,b,c) = c
