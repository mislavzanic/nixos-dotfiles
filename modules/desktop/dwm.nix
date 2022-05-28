{ options, config, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.dwm;
  configDir = config.dotfiles.configDir;

in {

  options.modules.desktop.dwm = { enable = mkBoolOpt false; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      dwm
      dmenu
      feh
      libnotify
      dunst
      sxhkd
      bsp-layout
      xclip
      pavucontrol
      pasystray
      autorandr
      polybar
      qutebrowser
      xst
      firefox
      zathura
      xorg.xmodmap
      networkmanagerapplet
    ];

    nixpkgs.overlays = [
      (self: super: {
        dwm = super.dwm.overrideAttrs(_: {
          src = builtins.fetchGit {
            url = "https://github.com/mislavzanic/dwm";
            rev = "a3aa030606af99d32f45b939f8955b266c1a427d";
            ref = "master";
          };
        });
      })
    ];
    # programs.slock.enabe = true;

    # xsession.enable = true;
    # xsession.windowManager.command = "${pkgs.dwm}/bin/dwm";
    services.xserver.windowManager.dwm.enable = true;

    services.picom.enable = true;
    services.picom.shadow = false;
  };
}
