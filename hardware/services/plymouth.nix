{ config, pkgs, ... }:

let
  logoFile = ../../files/face.png;
  themePkg = pkgs.plasma5Packages.breeze-plymouth;
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
      osVersion = config.system.nixos.release;
    }) ];
  };

  # replace all log output with black screen
  boot.kernelParams = [ "quiet" ];
}
