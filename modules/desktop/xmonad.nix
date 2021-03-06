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
      compton
      xorg.xmodmap
      networkmanagerapplet
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
