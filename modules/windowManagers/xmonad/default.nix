input@{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.windowManager.lvt.xmonad;
  lvt-xmonad = pkgs.lvt.lvt-xmonad;
  configDir = "xmonad/xmonad-x86_64-linux";

in {

  imports = [ ./xcompmgr.nix ];

  options.windowManager.lvt.xmonad = {
    enable = mkEnableOption "Enable lvt xmonad config";
  };

  config = mkIf cfg.enable {
    environment.variables = {
      "XMONAD_CONFIG_DIR" = "/etc/xmonad";
      "XMONAD_DATA_DIR" = "/etc/xmonad";
      "XMONAD_CACHE_DIR" = "/etc/xmonad";
    };

    environment.etc."${configDir}".source =
      "${lvt-xmonad}/bin/lvt-xmonad-x86_64-linux";

    environment.etc."xmonad/build" = {
      text = "# This file stops xmonad from recompiling on restart";
      mode = "0774";
    };

    environment.systemPackages = with pkgs; [
      xdotool
      htop
      feh
      sxiv
      xorg.xset
      xmonad-log
      xcompmgr
      tremc
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
          lightdm.greeters.gtk.iconTheme = {
            package = pkgs.capitaine-cursors;
            name = "Capitaine Cursors";
          };
        };

        windowManager.xmonad.enable = true;
        windowManager.xmonad.enableContribAndExtras = true;

      };
      lvt.xcompmgr.enable = true;
    };
  };
}
