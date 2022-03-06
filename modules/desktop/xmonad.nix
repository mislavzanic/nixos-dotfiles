{ options, config, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.xmonad;
  configDir = config.dotfiles.configDir;

in {

  options.modules.desktop.xmonad = { enable = mkBoolOpt true; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      xdotool
      htop
      feh
      # ghc
      sxiv
      xorg.xset
      xmonad-log
      tremc
      dmenu
      unclutter
      dunst
      lxappearance
      pamixer
    ];

    services = {
      xserver = {
        enable = true;

        displayManager = {
          defaultSession = "none+xmonad";
          lightdm.enable = true;
          lightdm.greeters.mini = {
            enable = true;
            user = config.user.name;
            extraConfig = ''
              [greeter-theme]
              background-image = "";
              background-color = "#0C0F12"
              text-color = "#ff79c6"
              password-background-color = "#1E2029"
              window-color = "#181a23"
              border-color = "#bd93f9"
            '';
          };
        };

        windowManager = {
          xmonad = {
            enable = true;
            enableContribAndExtras = true;
            extraPackages = hpkgs: [
              hpkgs.xmonad_0_17_0
              hpkgs.xmonad-contrib_0_17_0
              hpkgs.xmonad-extras_0_17_0
            ];
          };
        };
      };
    };

    home.configFile = {
      "xmonad" = {
        source    = "${configDir}/xmonad";
        recursive = true;
      };
    };
  };

}
