{ config, ... }:

{
  # mountpoints on RaspberryPi
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [
        "umask=0077"
        "shortname=winnt"
      ];
    };
  };
}
