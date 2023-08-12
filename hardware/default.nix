# file: packages/hardware.nix

{ config, pkgs, ... }:

{
  imports = [
    ./services.nix
  ];

  environment.systemPackages = with pkgs; [
    (hwloc.override {
      x11Support = (config.services.xserver.enable);
    })
    iftop
    iotop
    compsize
  ];
}
