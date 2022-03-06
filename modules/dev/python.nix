{ config, options, lib, pkgs, my, ... }:

with lib;
with lib.my;
let
  devCfg = config.modules.dev;
  cfg = devCfg.python;
in {
  options.modules.dev.python = {
    enable = mkBoolOpt false;
    xdg.enable = mkBoolOpt devCfg.xdg.enable;
  };

  config = mkMerge [
    (mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        python310
        python310Packages.pip
        python310Packages.ipython
        python310Packages.black
        python310Packages.setuptools
        python310Packages.pylint
        python310Packages.poetry
        nodePackages.pyright
      ];
    })
  ];
}
