{ pkgs, lib, config, ... }: {

  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "leviathan";
  time.timeZone = "Europe/Zagreb";

  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  networking.interfaces.enp9s0.useDHCP = true;

  modules = {
    desktop = {
      xmonad.enable = true;
      xmobar.enable = true;
      rofi.enable   = true;
    };
    term = { alacritty.enable = true; };
    shell = { zsh.enable = true; };
    editor = {
      emacs.enable = true;
      emacs.doom.enable = true;
    };
    dev = {
      python.enable = true;
    };
  };

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
}
