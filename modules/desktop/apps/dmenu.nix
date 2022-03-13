{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.apps.dmenu;
  configDir = config.dotfiles.configDir;
in {

  options.modules.desktop.apps.dmenu = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (dmenu.overrideAttrs (oldAttrs: rec {
        patches = [
          (fetchpatch {
            url = "https://tools.suckless.org/dmenu/patches/highlight/dmenu-highlight-4.9.diff";
            sha256 = "nn/caxVhS6S4eF3Bbw04c5CV2Y6GgSdyc+0hPKfMlCE=";
          })
          (fetchpatch {
            url = "https://tools.suckless.org/dmenu/patches/center/dmenu-center-4.8.diff";
            sha256 = "9D/BLUSddy0ZglghzdBZlz8A/ZjMmlCEgwqZCHOgyzU=";
          })
        ];
        configFile = writeText "config.def.h" (builtins.readFile "${configDir}/dmenu/config.def.h");
        postPatch = "${oldAttrs.postPatch}\n cp ${configFile} config.def.h";
      }))
    ];

    home.configFile = {
      "dmenu" = {
        source = "${configDir}/dmenu";
        recursive = false;
      };
    };
  };
}
