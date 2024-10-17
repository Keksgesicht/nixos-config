{ config, pkgs, ... }:

let
  logoFile = ../../files/face.png;
  themePkg = pkgs.plasma5Packages.breeze-plymouth;

  osVer = config.system.nixos.label;
  netName = config.networking.hostName;
in
{
  boot.plymouth = {
    enable = true;
    theme = "breeze";
    logo = logoFile;
    themePackages = [ (themePkg.override {
      inherit logoFile;
      logoName = "keks";
      osName = "KexOS";
      osVersion = osVer;
    }) ];
  };

  # replace all log output with black screen
  boot.kernelParams = [ "quiet" ];
}
