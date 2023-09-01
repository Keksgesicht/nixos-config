# file: packages/hardware.nix

{ config, pkgs, ... }:

{
  imports = [
    ./services.nix
  ];

  environment.systemPackages = with pkgs; [
    compsize
    efibootmgr
    gptfdisk
    (hwloc.override {
      x11Support = (config.services.xserver.enable);
    })
    iftop
    iotop
    pciutils
    usbutils
  ];
}
