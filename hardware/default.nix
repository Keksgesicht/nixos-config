{ config, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  environment.systemPackages = with pkgs; [
    compsize
    dmidecode
    efibootmgr
    e2fsprogs
    gptfdisk
    (hwloc.override {
      x11Support = (config.services.xserver.enable);
    })
    iftop
    iotop
    i2c-tools # https://superuser.com/questions/519822/how-to-check-ram-timings-in-linux#answer-1499521
    /*
     * sudo modprobe eeprom
     * sudo modprobe at24
     * sudo modprobe i2c-i801
     * sudo modprobe i2c-amd-mp2-pci
     * sudo modprobe ee1004
     * decode-dimms
     */
    lshw
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
