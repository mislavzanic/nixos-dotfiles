{ config, lib, pkgs, options, my, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.picom;
in {

  options.modules.services.picom = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.picom.enable = true;
  };
}
