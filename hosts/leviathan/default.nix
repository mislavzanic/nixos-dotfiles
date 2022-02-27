{ pkgs, lib, config, ... }: {

  networking.hostName = "leviathan";

  windowManager.lvt.xmonad.enable = true;
  programs.lvt.xmobar.enable = true;
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
}
