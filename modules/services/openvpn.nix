{ config, lib, pkgs, options, my, ... }:

with lib;
with lib.my;
{

  options.modules.services.openvpn = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.openvpn.servers = {
      officeVPN = { config = '' config  ''; };
    };
  };
}
