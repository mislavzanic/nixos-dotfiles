{ config, lib, pkgs, ... }:

with lib;
let cfg = config.programs.lvt.alacritty;
in {

  options.programs.lvt.alacritty = {
    enable = mkEnableOption "Enable Alacritty";
  };

  config = mkIf cfg.enable {
    fonts.fonts = with pkgs; [
      jetbrains-mono
    ];

    environment.systemPackages =
      let
        config = pkgs.writeText "alacritty config" (
          (builtins.readFile ./config/alacritty.yml)
        );

        wrapped = pkgs.writeShellScriptBin "alacritty" ''
          exec ${pkgs.alacritty}/bin/alacritty --config-file ${config}
        '';
        package = pkgs.symlinkJoin {
          name = "alacritty";
          paths = [
            wrapped
            pkgs.alacritty
          ];
        };
      in
      [ package ];
  };
}
