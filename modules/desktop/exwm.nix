{ options, config, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.exwm;
  configDir = config.dotfiles.configDir;

in {

  options.modules.desktop.exwm = { enable = mkBoolOpt true; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      feh
      dunst
      xclip
      pavucontrol
      pasystray
      autorandr
      polybar
      qutebrowser
      firefox
      zathura
      compton
      xorg.xmodmap
      networkmanagerapplet
    ];

    services = {
      xserver = {
        enable = true;

        updateDbusEnvironment = true;

        windowManager.session = singleton {
          name = "exwm";
          start = ''
            ${pkgs.dbus.dbus-launch} --exit-with-session emacs -mm --fullscreen
          '';
        };

        displayManager = {
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
  };

}
