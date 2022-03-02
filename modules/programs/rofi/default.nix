{ config, lib, pkgs, ... }:

with lib;
let 
  cfg = config.programs.lvt.rofi;
  rofiConfig = pkgs.writeText "rofi.rasi" (builtins.readFile ./config/rofi.rasi);
  wrapped = pkgs.writeShellScriptBin "rofi" ''
    exec ${pkgs.rofi}/bin/rofi -config ${rofiConfig} $@
  '';
  package = pkgs.symlinkJoin {
    name = "rofi";
    paths = [
      wrapped
      pkgs.rofi
    ];
  };
in {
  options.programs.lvt.rofi = {
    enable = mkEnableOption "Enable Rofi";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      paper-icon-theme
      font-awesome
      roboto-mono
      package 
    ];
  };
}
