{ pkgs, lib, config, ... }: {

  networking.hostName = "leviathan";

  windowManager.lvt.xmonad.enable = true;
  services.xserver.enable = true;
}
