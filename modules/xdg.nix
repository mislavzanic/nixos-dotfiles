{ config, home-manager, ... }: {

  home-manager.users.${config.user.name}.xdg.enable = true;

  environment = {
    sessionVariables = {
      "XDG_CACHE_HOME"  = "$HOME/.cache";
      "XDG_CONFIG_HOME" = "$HOME/.config";
      "XDG_DATA_HOME"   = "$HOME/.local/share";
      "XDG_BIN_HOME"    = "$HOME/.local/bin";
      "PATH"            = "$PATH:$HOME/.local/bin/scripts:$HOME/.config/emacs/bin:$HOME/.local/bin:$HOME/.config/.dotfiles/bin";
    };

    variables = {
      "HISTFILE"        = "$XDG_DATA_HOME/zsh/history";
      "INPUTRC"         = "$XDG_CONFIG_HOME/readline/inputrc";
      "LESSHISTFILE"    = "$XDG_CACHE_HOME/lesshst";
      "WGETRC"          = "$XDG_CONFIG_HOME/wgetrc";

      "EMACSDIR"        = "$XDG_CONFIG_HOME/emacs";
      "DOOMDIR"         = "$XDG_CONFIG_HOME/doom";
      "CABAL_CONFIG"    = "$XDG_CONFIG_HOME/cabal/config";
      "CABAL_DIR"       = "$XDG_CACHE_HOME/cabal";
      "ZDOTDIR"         = "$XDG_CONFIG_HOME/zsh";
    };
  };
}
