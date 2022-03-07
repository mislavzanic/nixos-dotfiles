{ config, lib, pkgs, options, my, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.dunst;
  configDir = config.dotfiles.configDir;
in {

  options.modules.services.dunst = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    #services.dunst = {
    #  enable = true;
    #};

    environment.systemPackages = with pkgs; [ libnotify ];

    home.configFile = {
      "dunst" = {
        source = "${configDir}/dunst";
        recursive = true;
      };
    };
  };
}
