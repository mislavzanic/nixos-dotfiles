{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let 
  cfg = config.modules.desktop.rofi;
  configDir = config.dotfiles.configDir;

in {
  options.modules.desktop.rofi = { enable = mkBoolOpt false; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      paper-icon-theme
      font-awesome
      roboto-mono
    ];

    home.configFile = {
      "rofi" = {
        source = "${configDir}/rofi";
        recursive = true;
      };
    };
  };

}
