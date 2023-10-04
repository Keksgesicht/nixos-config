{ config, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  environment.systemPackages = with pkgs; [
    compsize
    efibootmgr
    e2fsprogs
    gptfdisk
    (hwloc.override {
      x11Support = (config.services.xserver.enable);
    })
    iftop
    iotop
    parted
    pciutils
    usbutils
  ];

  boot.kernelPackages =
    if (config.services.xserver.enable) then
      pkgs.linuxPackages_latest
    else
      pkgs.linuxPackages;
}
