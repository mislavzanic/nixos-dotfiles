{ config, options, lib, pkgs, my, ... }:

with lib;
with lib.my;
let
  devopsCfg = config.modules.devops;
  cfg = deopsvCfg.kubernetes;
in {
  options.modules.devops.kubernetes = { enable = mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      google-cloud-sdk
      kubectl
      k9s
    ];
  };
}
