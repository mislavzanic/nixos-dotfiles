{
  description = "My nixos config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "nixpkgs/master";

    home-manager.url = "github:rycee/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url  = "github:nix-community/emacs-overlay";
  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, ... }:
  let
    inherit (lib.my) mapModules mapModulesRec mapHosts;

    system = "x86_64-linux";

    mkPkgs = pkgs: extraOverlays: import pkgs {
      inherit system;
      config.allowUnfree = true;  # forgive me Stallman senpai
      overlays = extraOverlays ++ (lib.attrValues self.overlays);
    };
    pkgs  = mkPkgs nixpkgs [ self.overlay ];
    pkgs' = mkPkgs nixpkgs-unstable [];

    lib = nixpkgs.lib.extend
      (self: super: { my = import ./lib { inherit pkgs inputs; lib = self; }; });
  in {
    lib = lib.my;

    overlay =
      final: prev: {
        unstable = pkgs';
        my = self.packages."${system}";
      };

    overlays =
      mapModules ./overlays import;

    nixosModules = { dotfiles = import ./.; } // mapModulesRec ./modules import;

    nixosConfigurations = mapHosts ./hosts {};

  };
}
