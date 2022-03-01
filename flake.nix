{
  description = "My nixos config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "nixpkgs/master";
    emacs-overlay.url  = "github:nix-community/emacs-overlay";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, ... }:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
      overlays = [
        (import ./packages)
      ];
    };

    myLib = import ./lib/lib.nix pkgs.lib;
    myModules = myLib.listModulesRec ./modules;

  in {
    inherit pkgs;
    inherit myLib;

    devShell.${system} = import ./shell.nix { inherit pkgs; };

    packages.${system} = {
      lvt-xmonad = pkgs.lvt.lvt-xmonad;
      lvt-xmobar = pkgs.lvt.lvt-xmobar;
    };

    nixosConfigurations = {
      leviathan = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs pkgs; };
        modules = pkgs.lib.lists.flatten [
          ./hosts/base
          ./hosts/leviathan
          ./hosts/leviathan/hardware-configuration.nix
          myModules
        ];
      };
    };
  };
}
