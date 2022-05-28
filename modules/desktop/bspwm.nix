{ options, config, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.bspwm;
  configDir = config.dotfiles.configDir;

in {

  options.modules.desktop.bspwm = { enable = mkBoolOpt false; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      feh
      libnotify
      dunst
      sxhkd
      bsp-layout
      xclip
      pavucontrol
      dmenu
      pasystray
      autorandr
      polybar
      qutebrowser
      xst
      firefox
      zathura
      compton
      xorg.xmodmap
      networkmanagerapplet
    ];

    services = {
      xserver = {
        enable = true;
        windowManager.bspwm.enable = true;
        displayManager = {
          defaultSession = "none+bspwm";
          sessionCommands = ''
              ${pkgs.bspwm}/bin/bspc wm -r
              source $HOME/.config/bspwm/bspwmrc
          '';
          lightdm = {
            enable = true;
            greeters.mini = {
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

          autoLogin = {
            enable = true;
            user = config.user.name;
          };

        };
      };
    };

    home.configFile = {
      "sxhkd".source = "${configDir}/sxhkd";
      "bspwm" = {
        source = "${configDir}/bspwm";
        recursive = true;
      };
    };
  };

}
