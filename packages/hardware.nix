# file: packages/hardware.nix

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    apcupsd
    hwloc
    iftop
    iotop
    rasdaemon
  ];
}
