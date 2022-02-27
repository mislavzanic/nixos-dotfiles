input@{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.programs.lvt.xmobar;
  lvt-xmobar = pkgs.lvt.lvt-xmobar;
  configDir = "xmobar/xmobar-x86_64-linux";
in {

  options.programs.lvt.xmobar = {
    enable = mkEnableOption "Enable lvt xmobar config";
  };

  config = mkIf cfg.enable {
    environment.variables = {
      "XMOBAR_CONFIG_DIR" = "/etc/xmobar";
      "XMOBAR_DATA_DIR" = "/etc/xmobar";
      "XMOBAR_CACHE_DIR" = "/etc/xmobar";
    };

    environment.etc."${configDir}".source =
      "${lvt-xmobar}/bin/lvt-xmobar-x86_64-linux";

    environment.etc."xmobar/build" = {
      text = "# This file stops xmobar from recompiling on restart";
      mode = "0774";
    };

    environment.systemPackages = with pkgs; [
      trayer
    ];
  };
}
