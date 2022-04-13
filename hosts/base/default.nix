{ pkgs, lib, ... }: {

  networking.networkmanager.enable = true;
  networking.useDHCP = false;

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

  time.timeZone = "Europe/Zagreb";
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
    };

    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

}
