{ config, pkgs, ... }:

let
  tuxedo = import (builtins.fetchTarball "https://github.com/blitz/tuxedo-nixos/archive/master.tar.gz");
in
{
  imports = [
    tuxedo.module
  ];

  # https://nixos.wiki/wiki/TUXEDO_Devices
  hardware.tuxedo-control-center.enable = true;
  boot.kernelParams = [
    "tuxedo_keyboard.mode=0"
    "tuxedo_keyboard.brightness=64"
    "tuxedo_keyboard.color_left=0xff0000"
  ];
}
