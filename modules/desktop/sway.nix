{ options, config, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.i3;
  configDir = config.dotfiles.configDir;

in {

  options.modules.desktop.i3 = { enable = mkBoolOpt true; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      xdotool
      htop
      feh
      sxiv
      xorg.xset
      tremc
      dunst
      xcompmgr
      lxappearance
      pamixer
    ];

    services = {
      xserver = {
        enable = true;

        displayManager = {
          defaultSession = "none+i3";
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
	  autoLogin = {
	    enable = true;
	    user = config.user.name;
	  };
        };

        windowManager = {
          i3 = {
            enable = true;
            package = pkgs.i3-gaps;
            extraPackages = with pkgs; [
              dmenu
              i3status
              i3lock
              i3blocks
            ];
          };
        };
      };
    };

    home.configFile = {
      "i3" = {
        source    = "${configDir}/i3";
        recursive = true;
      };
    };
  };

}
