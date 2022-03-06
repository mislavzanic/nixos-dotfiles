{ config, options, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.xmobar;
  configDir = config.dotfiles.configDir;
in {

  options.modules.desktop.xmobar = { enable = mkBoolOpt false; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      trayer
      xmobar
    ];

    home.configFile = {
      "xmobar" = {
        source = "${configDir}/xmobar";
        recursive = true;
      };
    };
  };
}
