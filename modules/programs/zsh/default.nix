inputs@{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.lvt.zsh;
in {
  # imports = [ ./xdg.nix ];
  options.programs.lvt.zsh.enable = mkEnableOption "Enable zsh";

  config = mkIf cfg.enable {
    users.defaultUserShell = pkgs.zsh;

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableGlobalCompInit = false;
    };

    environment.systemPackages = with pkgs; [
      zsh
      nix-zsh-completions
      bat
      exa
      fasd
      fd
      fzf
      tldr
      ripgrep
    ];

    environment.variables = {
      "ZDOTDIR"   = "$XDG_CONFIG_HOME/zsh";
      "ZSH_CACHE" = "$XDG_CACHE_HOME/zsh";
      "ZGEN_DIR"  = "$XDG_DATA_HOME/zgenom";
    };
  };
}
