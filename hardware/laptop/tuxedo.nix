{ config, pkgs, ... }:

let
  # $AUTH nix-channel --add https://github.com/blitz/tuxedo-nixos/archive/master.tar.gz tuxedo
  # $AUTH nix-channel --update
  #tuxedo = import <tuxedo>;
in
{
  imports = [
    #tuxedo.module
  ];

  # https://nixos.wiki/wiki/TUXEDO_Devices
  hardware.tuxedo-keyboard.enable = true;
  boot.kernelParams = [
    "tuxedo_keyboard.mode=0"
    "tuxedo_keyboard.brightness=64"
    "tuxedo_keyboard.color_left=0xff0000"
  ];
  # optional
  #hardware.tuxedo-control-center.enable = true;
}
