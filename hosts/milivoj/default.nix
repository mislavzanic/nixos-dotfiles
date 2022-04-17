{ pkgs, lib, config, ... }:
let configDir = config.dotfiles.configDir;
in {

  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "milivoj";
  time.timeZone = "Europe/Zagreb";

  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  networking.interfaces.wlp2s0.useDHCP = true;

  modules = {
    desktop = {
      xmonad.enable = false;
      xmobar.enable = false;
      i3.enable = false;
      exwm.enable = true;
      apps = {
        zathura.enable = true;
        spotify.enable = true;
      };
    };
    term = { alacritty.enable = true; };
    shell = { zsh.enable = true; };
    editor = {
      emacs.enable      = true;
      emacs.doom.enable = true;
    };
    dev = {
      python.enable = true;
      sh.enable     = true;
    };
    devops = {
      kubernetes.enable = true;
      terraform.enable = true;
    };
  };

  programs.dconf.enable = true;
  services = {
    xserver.enable = true;
    dbus.packages = with pkgs; [ dconf ];
    fwupd.enable = true;
    xserver.libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = false;
        middleEmulation = true;
        tapping = true;
      };
    };
  };

  user.packages = with pkgs; [
    openvpn
    cantarell-fonts
  ];

  environment = {
    sessionVariables = {
      "PRIMARY_MONITOR" = "eDP-1";
      "SECONDARY_MONITOR" = "HDMI-1";
    };

    etc."modprobe.d/alsa-base.conf".source = "${configDir}/modprobe/alsa-base.conf";
  };
}
