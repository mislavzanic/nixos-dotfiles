{ config, lib, pkgs, inputs, ... }:

with lib;
let
  cfg = config.modules.lvt.emacs;
in {

  options.modules.lvt.emacs = {
    enable = mkEnableOption "Enable emacs";
    doom.enable = mkEnableOption "Enable doom emacs";
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];

    environment.systemPackages = with pkgs; [
      emacs
      binutils
      git
      gnutls
      fd
      ripgrep
      imagemagick
    ];

    fonts.fonts = [ pkgs.emacs-all-the-icons-fonts ];
  };
}
