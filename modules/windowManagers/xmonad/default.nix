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
      feh
      sxiv
      xcompmgr
      htop
      xmonad-log
      xdotool
      xorg.xset
      tremc
    ];

    services = {
      xserver = {
        enable = true;
        displayManager = {
          startx.enable = true;
          defaultSession = "none+xmonad";
        };
        windowManager = {
          xmonad.enable = true;
        };
      };
    };
  };

}
