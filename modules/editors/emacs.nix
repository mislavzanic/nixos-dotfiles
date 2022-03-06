{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.editor.emacs;
  configDir = config.dotfiles.configDir;
in {

  options.modules.editor.emacs = {
    enable = mkBoolOpt false;
    doom.enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];

    services.emacs.enable = true;

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
