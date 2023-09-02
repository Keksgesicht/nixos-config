# file: packages/hardware.nix

{ config, pkgs, ... }:

{
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

  boot.kernelPackages =
    if (config.services.xserver.enable) then
      pkgs.linuxPackages_latest
    else
      pkgs.linuxPackages;
}
