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

    environment.systemPackages = with pkgs; [
      ((emacsPackagesFor emacs).emacsWithPackages (epkgs: [
        epkgs.vterm
      ]))

      binutils
      git
      gnutls
      fd
      ripgrep
      jq
      imagemagick
      sqlite
      texlive.combined.scheme-medium
      xdotool
      xorg.xwininfo
    ];

    fonts.fonts = with pkgs; [
      emacs-all-the-icons-fonts
      jetbrains-mono
      nerdfonts
      cantarell-fonts
    ];
  };
}
