module Config.Scratchpad where

import XMonad
import Config.Vars
import XMonad.Util.NamedScratchpad
import XMonad.StackSet

myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm
                , NS "tremc" spawnTremc findTremc manageTremc
                , NS "spotify" spawnSpotify findSpotify manageSpotify
                -- , NS "discord" spawnDiscord findDiscord manageDiscord
                ]
  where
    spawnTerm  = myTerminal ++ " -t scratchpad"
    findTerm   = title =? "scratchpad"
    manageTerm = customFloating $ RationalRect l t w h
                 where
                   h = 0.9
                   w = 0.9
                   t = 0.95 - h
                   l = 0.95 - w
    spawnTremc  = myTerminal ++ " -t tremc -e tremc"
    findTremc   = title =? "tremc"
    manageTremc = customFloating $ RationalRect l t w h
                 where
                   h = 0.9
                   w = 0.9
                   t = 0.95 - h
                   l = 0.95 - w
    spawnSpotify  = "spotify"
    findSpotify   = title =? "Spotify" <||> title =? "spotify" <||> className =? "Spotify" <||> title =? ""
    manageSpotify = customFloating $ RationalRect l t w h
                    where
                      h = 0.9
                      w = 0.9
                      t = 0.95 - h
                      l = 0.95 - w
