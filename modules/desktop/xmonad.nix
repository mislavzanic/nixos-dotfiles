{ options, config, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.xmonad;
  configDir = config.dotfiles.configDir;

in {

  options.modules.desktop.xmonad = { enable = mkBoolOpt false; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      xdotool
      trayer
      xmobar
      htop
      feh
      sxiv
      xorg.xset
      xmonad-log
      dmenu
      dunst
      lxappearance
      pamixer
      libnotify
      xclip
      maim
      pavucontrol
      pasystray
      autorandr
      xst
      firefox
      zathura
      xorg.xmodmap
      networkmanagerapplet
    ];

    services = {
      xserver = {
        enable = true;

        displayManager = {
          defaultSession = "none+xmonad";
          sessionCommands = ''
            cat ~/.config/xtheme/* | '${pkgs.xorg.xrdb}/bin/xrdb' -load
          '';
          lightdm.enable = true;
          lightdm.greeters.mini = {
            enable = true;
            user = config.user.name;
          };
        };

        windowManager = {
          xmonad = {
            enable = true;
            enableContribAndExtras = true;
            extraPackages = hpkgs: [
              hpkgs.xmonad
              hpkgs.xmonad-contrib
              hpkgs.xmonad-extras
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
