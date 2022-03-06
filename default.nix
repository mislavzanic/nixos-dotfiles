{ inputs, config, lib, pkgs, ... }:

with lib;
with lib.my;
{

  imports =
    # I use home-manager to deploy files to $HOME; little else
    [ inputs.home-manager.nixosModules.home-manager ]
    # All my personal modules
    ++ (mapModulesRec' (toString ./modules) import);

  # Common config for all nixos machines; and to ensure the flake operates
  # soundly
  environment.variables.DOTFILES = config.dotfiles.dir;
  environment.variables.DOTFILES_BIN = config.dotfiles.binDir;

  users.users.mislav = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_5_16;
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
      };
    };
    supportedFilesystems = [ "ntfs" ];
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    vim
    zsh
    transmission
    git
    mpv
    wget
    feh
    brave
    python3
    ripgrep
    fd
    cmake
    gcc
  ];

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  nix = {
    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 30d";
    };

    settings = {
      auto-optimise-store = true;
      trusted-users = [ "mislav" "root" ];
    };

    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

}
