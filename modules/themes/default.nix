{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.theme;
in {
  options.modules.theme = with types; {
    active = mkOption {
      type = nullOr str;
      default = null;
      apply = v: let theme = builtins.getEnv "THEME"; in
                 if theme != "" then theme else v;
      description = ''
        Name of the theme to enable. Can be overridden by the THEME environment
        variable. Themes can also be hot-swapped with 'hey theme $THEME'.
      '';
    };

    wallpaper = mkOpt (either path null) null;

    loginWallpaper = mkOpt (either path null)
      (if cfg.wallpaper != null
       then toFilteredImage cfg.wallpaper "-gaussian-blur 0x2 -modulate 70 -level 5%"
       else null);

    onReload = mkOpt (attrsOf lines) {};

    fonts = {
      # TODO Use submodules
      mono = {
        name = mkOpt str "Monospace";
        size = mkOpt int 12;
      };
      sans = {
        name = mkOpt str "Sans";
        size = mkOpt int 10;
      };
    };

    colors = {
      black         = mkOpt str "#000000"; # 0
      red           = mkOpt str "#FF0000"; # 1
      green         = mkOpt str "#00FF00"; # 2
      yellow        = mkOpt str "#FFFF00"; # 3
      blue          = mkOpt str "#0000FF"; # 4
      magenta       = mkOpt str "#FF00FF"; # 5
      cyan          = mkOpt str "#00FFFF"; # 6
      silver        = mkOpt str "#BBBBBB"; # 7
      grey          = mkOpt str "#888888"; # 8
      brightred     = mkOpt str "#FF8800"; # 9
      brightgreen   = mkOpt str "#00FF80"; # 10
      brightyellow  = mkOpt str "#FF8800"; # 11
      brightblue    = mkOpt str "#0088FF"; # 12
      brightmagenta = mkOpt str "#FF88FF"; # 13
      brightcyan    = mkOpt str "#88FFFF"; # 14
      white         = mkOpt str "#FFFFFF"; # 15

      # Color classes
      types = {
        bg        = mkOpt str cfg.colors.black;
        fg        = mkOpt str cfg.colors.white;
        panelbg   = mkOpt str cfg.colors.types.bg;
        panelfg   = mkOpt str cfg.colors.types.fg;
        border    = mkOpt str cfg.colors.types.bg;
        error     = mkOpt str cfg.colors.red;
        warning   = mkOpt str cfg.colors.yellow;
        highlight = mkOpt str cfg.colors.white;
        opacity   = mkOpt str "255";
      };
    };
  };

  config = mkIf (cfg.active != null) (mkMerge [
    # Read xresources files in ~/.config/xtheme/* to allow modular configuration
    # of Xresources.
    (let xrdb = ''cat "$XDG_CONFIG_HOME"/xtheme/* | ${pkgs.xorg.xrdb}/bin/xrdb -load'';
     in {
       home.configFile."xtheme.init" = {
         text = xrdb;
         executable = true;
       };
       modules.theme.onReload.xtheme = xrdb;
     })
    (mkIf config.modules.desktop.xmonad.enable {
      home.configFile."xmonad/xinit" = {
        text = "$XDG_CONFIG_HOME/xtheme.init";
        executable = true;
      };
    })
    {
      home.configFile = {
        "xtheme/00-init".text = with cfg.colors; ''
          #define brd  ${types.border}
          #define bg   ${types.bg}
          #define fg   ${types.fg}
          #define blk  ${black}
          #define red  ${red}
          #define grn  ${green}
          #define ylw  ${yellow}
          #define blu  ${blue}
          #define mag  ${magenta}
          #define cyn  ${cyan}
          #define wht  ${silver}
          #define bblk ${grey}
          #define bred ${brightred}
          #define bgrn ${brightgreen}
          #define bylw ${brightyellow}
          #define bblu ${brightblue}
          #define bmag ${brightmagenta}
          #define bcyn ${brightcyan}
          #define bwht ${white}
          #define alph ${types.opacity}
        '';
        "xtheme/05-colors".text = ''
          st.border: brd
          st.foreground: fg
          st.background: bg
          st.color0:  blk
          st.color1:  red
          st.color2:  grn
          st.color3:  ylw
          st.color4:  blu
          st.color5:  mag
          st.color6:  cyn
          st.color7:  wht
          st.color8:  bblk
          st.color9:  bred
          st.color10: bgrn
          st.color11: bylw
          st.color12: bblu
          st.color13: bmag
          st.color14: bcyn
          st.color15: bwht
          st.opacity: alph
        '';
      };

      fonts.fontconfig.defaultFonts = {
        sansSerif = [ cfg.fonts.sans.name ];
        monospace = [ cfg.fonts.mono.name ];
      };
    }

    (mkIf (cfg.wallpaper != null)
      # Set the wallpaper ourselves so we don't need .background-image and/or
      # .fehbg polluting $HOME
      (let wCfg = config.services.xserver.desktopManager.wallpaper;
           command = ''
             if [ -e "$XDG_DATA_HOME/wallpaper" ]; then
               ${pkgs.feh}/bin/feh --bg-${wCfg.mode} \
                 ${optionalString wCfg.combineScreens "--no-xinerama"} \
                 --no-fehbg \
                 $XDG_DATA_HOME/wallpaper
             fi
          '';
       in {
         services.xserver.displayManager.sessionCommands = command;
         modules.theme.onReload.wallpaper = command;

         home.dataFile = mkIf (cfg.wallpaper != null) {
           "wallpaper".source = cfg.wallpaper;
         };
       }))

    (mkIf (cfg.loginWallpaper != null) {
      services.xserver.displayManager.lightdm.background = cfg.loginWallpaper;
    })

    (mkIf (cfg.onReload != {})
      (let reloadTheme =
             with pkgs; (writeScriptBin "reloadTheme" ''
               #!${stdenv.shell}
               echo "Reloading current theme: ${cfg.active}"
               ${concatStringsSep "\n"
                 (mapAttrsToList (name: script: ''
                   echo "[${name}]"
                   ${script}
                 '') cfg.onReload)}
             '');
       in {
         user.packages = [ reloadTheme ];
         system.userActivationScripts.reloadTheme = ''
           [ -z "$NORELOAD" ] && ${reloadTheme}/bin/reloadTheme
         '';
       }))
  ]);
}
