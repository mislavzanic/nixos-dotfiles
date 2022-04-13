{ config, options, lib, pkgs, my, ... }:

with lib;
with lib.my;
let
  devopsCfg = config.modules.devops;
  cfg = devopsCfg.terraform;
in {
  options.modules.devops.terraform = {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      terraform
      terraform-lsp
      terragrunt
    ];
  };
}
