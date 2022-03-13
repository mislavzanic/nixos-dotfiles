{ config, options, lib, pkgs, my, ... }:

with lib;
with lib.my;
let devCfg = config.modules.dev;
    cfg = devCfg.sh;
in {
  options.modules.dev.sh = {
    enable = mkBoolOpt false;
    xdg.enable = mkBoolOpt devCfg.xdg.enable;
  };

  config = mkMerge [
    (mkIf cfg.enable {
      user.packages = with pkgs; [
        shellcheck
      ];
    })

    (mkIf cfg.xdg.enable {
      # TODO
    })
  ];
}
