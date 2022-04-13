{ config, options, lib, pkgs, my, ... }:

with lib;
with lib.my;
let
  devopsCfg = config.modules.devops;
  cfg = devCfg.k8s;
in {
  options.modules.devops.k8s = { enable = mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      google-cloud-sdk
      kubectl
      k9s
    ];
  };
}
