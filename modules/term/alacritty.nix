{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.term.alacritty;
  configDir = config.dotfiles.configDir;
in {

  options.modules.term.alacritty = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    fonts.fonts = with pkgs; [
      jetbrains-mono
    ];

    environment.systemPackages = with pkgs; [ alacritty ];

    home.configFile = {
      "alacritty" = {
        source = "${configDir}/alacritty";
        recursive = false;
      };
    };
  };
}
