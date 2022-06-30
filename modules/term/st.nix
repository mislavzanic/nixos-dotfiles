{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.term.st;
  configDir = config.dotfiles.configDir;
in {

  options.modules.term.st = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    # fonts.fonts = with pkgs; [
    #   jetbrains-mono
    # ];

    environment.systemPackages = with pkgs; [ st ];

    home.configFile = {
      "st" = {
        source = "${configDir}/st";
        recursive = false;
      };
    };
  };
}
