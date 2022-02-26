{ pkgs, lib, ... }: {

  users.users.mislav = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  boot = {
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
    emacs
    alacritty
    zsh
    transmission
    git
    mpv
    wget
    feh
    brave
  ];

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

}
