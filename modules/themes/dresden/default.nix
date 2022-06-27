{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.theme;
in {
  config = mkIf (cfg.active == "dresden") (mkMerge [
    {
      modules = {
        theme = {
          wallpaper = mkDefault ./config/wallpaper.jpg;
          loginWallpaper = mkDefault ./config/wallpaper.jpg;
          colors = {
            red           = "#df5b61"; # 1
            green         = "#87c7a1"; # 2
            yellow        = "#de8f78"; # 3
            blue          = "#6791c9"; # 4
            magenta       = "#bc83e3"; # 5
            cyan          = "#70b9cc"; # 6
            silver        = "#848484"; # 7
            grey          = "#4a4a4a"; # 8
            brightred     = "#ee6a70"; # 9
            brightgreen   = "#96d6b0"; # 10
            brightyellow  = "#ffb29b"; # 11
            brightblue    = "#7ba5dd"; # 12
            brightmagenta = "#cb92f2"; # 13
            brightcyan    = "#7fc8db"; # 14
            white         = "#eeeeee"; # 15


            types = {
              panelfg   = "#cccccc";
              border    = "#a88058";
              error     = cfg.colors.red;
              warning   = cfg.colors.yellow;
              highlight = cfg.colors.red;
            };
          };
        };
      };
    }

    (mkIf config.services.xserver.enable {
      fonts = {
        fonts = with pkgs; [
          fira-code
          fira-code-symbols
          open-sans
          jetbrains-mono
          siji
          font-awesome
          symbola
        ];
      };

      services.picom = {
        fade = false;
        shadow = false;
        settings = {
          blur-kern = "7x7box";
          blur-strength = 320;
        };
      };

      services.xserver.displayManager.lightdm.greeters.mini.extraConfig = ''
        text-color = "${cfg.colors.white}"
        password-background-color = "${cfg.colors.black}"
        window-color = "#303012"
        border-color = "${cfg.colors.types.border}"
        background-color = "#151230"
      '';

      home.configFile = with config.modules; mkMerge [
        (mkIf desktop.xmonad.enable {
          "xmobar/xmobarrc0".source = ./config/xmobar/xmobarrc0;
          "xmobar/xmobarrc1".source = ./config/xmobar/xmobarrc1;
        })
      ];
    })
  ]);
}
