# https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi
# booting sdImage and nixos-generate-config
{ config, lib, ... }:

{
  boot = {
    loader = {
      # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
      grub.enable = false;
      # Enables the generation of /boot/extlinux/extlinux.conf
      generic-extlinux-compatible.enable = true;
    };

    # I have a RPi 3B, so I disable this
    tmp.useTmpfs = lib.mkForce false;
  };

  hardware.enableRedistributableFirmware = true;
  powerManagement.cpuFreqGovernor = "ondemand";
}
