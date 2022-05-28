
{ options, config, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.qtile;
  configDir = config.dotfiles.configDir;

in {

  options.modules.desktop.qtile = { enable = mkBoolOpt false; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      feh
      libnotify
      dunst
      xclip
      pavucontrol
      dmenu
      pasystray
      autorandr
      qutebrowser
      xst
      firefox
      zathura
      compton
      xorg.xmodmap
      wlroots
      networkmanagerapplet
    ];

    services = {
      xserver = {
        enable = true;
        windowManager.qtile.enable = true;
        displayManager = {
          defaultSession = "none+qtile";
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
      "qtile" = {
        source = "${configDir}/qtile";
        recursive = true;
      };
    };
  };

}
