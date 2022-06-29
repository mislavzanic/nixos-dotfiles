{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.theme;
in {
  config = mkIf (cfg.active == "gruvbox") (mkMerge [
    {
      modules = {
        theme = {
          wallpaper = mkDefault ./config/wallpaper.jpg;
          loginWallpaper = mkDefault ./config/wallpaper.jpg;
          colors = {
            black         = "#1d2021";
            red           = "#cc241d"; # 1
            green         = "#98971a"; # 2
            yellow        = "#d79921"; # 3
            blue          = "#458588"; # 4
            magenta       = "#b16286"; # 5
            cyan          = "#689d6a"; # 6
            silver        = "#a89984"; # 7
            grey          = "#928374"; # 8
            brightred     = "#fb4934"; # 9
            brightgreen   = "#b8bb26"; # 10
            brightyellow  = "#fabd2f"; # 11
            brightblue    = "#83a598"; # 12
            brightmagenta = "#d3869b"; # 13
            brightcyan    = "#8ec07c"; # 14
            white         = "#ebdbb2"; # 15


            types = {
              fg        = cfg.colors.white;
              bg        = cfg.colors.black;
              border    = cfg.colors.black;
              opacity   = "200";
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
          "xmonad/lib/Config/Colors.hs".source = ./config/xmonad/Colors.hs;
        })
      ];
    })
  ]);
}
