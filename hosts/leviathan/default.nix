{ pkgs, lib, config, ... }: {

  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "leviathan";
  time.timeZone = "Europe/Zagreb";

  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  networking.interfaces.enp9s0.useDHCP = true;

  modules = {
    desktop = {
      xmonad.enable = false;
      xmobar.enable = false;
      i3.enable = false;
      exwm.enable = true;
      apps = {
        zathura.enable = true;
        dmenu.enable   = true;
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
      ruby.enable     = true;
    };
    services = {
      transmission.enable = true;
      picom.enable        = false;
    };
  };

  programs.dconf.enable = true;
  services = {
    xserver.enable       = true;
    xserver.videoDrivers = [ "nvidia" ];

    dbus.packages = with pkgs; [ dconf ];

    fwupd.enable = true;
  };

  environment = {
    sessionVariables = {
      "PRIMARY_MONITOR" = "DP-0";
      "PRIMARY_MONITOR_POS" = "1920x0";
      "PRIMARY_MONITOR_RES" = "1920x1080";

      "SECONDARY_MONITOR" = "HDMI-0";
      "SECONDARY_MONITOR_POS" = "0x0";
      "SECONDARY_MONITOR_RES" = "1920x1080";

      "MONITOR_LIST" = "2 HDMI-0 3 HDMI-0";
    };

    systemPackages = with pkgs; [
      transmission
    ];
  };

  nix = {
    settings = {
      trusted-users = [ "mislav" "root" ];
    };
  };
}
