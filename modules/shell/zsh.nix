{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.shell.zsh;
  configDir = config.dotfiles.configDir;
in {
  options.modules.shell.zsh.enable = mkBoolOpt false;

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

    env = {
      ZDOTDIR   = "$XDG_CONFIG_HOME/zsh";
      ZSH_CACHE = "$XDG_CACHE_HOME/zsh";
      ZGEN_DIR  = "$XDG_DATA_HOME/zgenom";
    };

    home.configFile = {
      "zsh" = { source = "${configDir}/zsh"; recursive = true; };
    };
  };
}
