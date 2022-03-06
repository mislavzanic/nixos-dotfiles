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

    programs = {
      zsh = {
        enable = true;
        enableCompletion = true;
        enableGlobalCompInit = false;

        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;

        # autocd = true;
        # cdpath = true;
      };

      # fzf = {
      #   enable = true;
      #   enableZshIntegration = true;
      # };
    };

    environment.systemPackages = with pkgs; [
      zsh
      nix-zsh-completions
      zsh-git-prompt
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
    };

    home.configFile = {
      "zsh" = { source = "${configDir}/zsh"; recursive = true; };
    };
  };
}
