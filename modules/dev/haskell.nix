{ config, options, lib, pkgs, my, ... }:

with lib;
with lib.my;
let
  devCfg = config.modules.dev;
  cfg = devCfg.haskell;
in {
  options.modules.dev.haskell = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ghc
      cabal2nix
      haskellPackages.haskell-language-server
      cabal-install
      hlint
    ];
  };
}
