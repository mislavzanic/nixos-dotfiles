{ pkgs, lib, config, ... }: {

  networking.hostName = "leviathan";

  windowManager.lvt.xmonad.enable = true;

  programs.lvt.xmobar.enable = true;
  programs.lvt.alacritty.enable = true;
  programs.lvt.rofi.enable = true;
  programs.lvt.zsh.enable = true;
  modules.lvt.emacs.enable = true;
  modules.lvt.emacs.doom.enable = true;

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
}
