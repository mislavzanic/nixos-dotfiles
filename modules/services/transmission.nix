{ config, lib, pkgs, options, my, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.transmission;
in {

  options.modules.services.transmission = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.transmission = {
      enable = true;
      settings = {
        download-dir = "${config.user.home}/.local/torrents";
        incomplete-dir = "${config.user.home}/.local/torrents";
      };
    };
    user.extraGroups = [ "transmission" ];
  };
}
