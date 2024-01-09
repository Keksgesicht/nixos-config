{ config, lib, pkgs, ssd-mnt, hdd-mnt, ... }:

let
  ssd-dev = "/dev/mapper/root";
  bfs-opts = [
    "compress=zstd:3"
  ];
in
{
  boot.initrd.luks.devices = {
    "root" = {
      device = "/dev/disk/by-uuid/c720b152-baf0-4336-bb04-83f01857cfab";
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/90CE-7A63";
      fsType = "vfat";
      options = [
        "umask=0077"
        "shortname=winnt"
      ];
    };
    "/nix" = {
      device = ssd-dev;
      fsType = "btrfs";
      options = bfs-opts ++ [ "subvol=nix" ];
      # implicit neededForBoot
    };

    "${hdd-mnt}" = {
      device = ssd-dev;
      fsType = "btrfs";
      options = bfs-opts ++ [ "subvol=mnt-array" ];
    };
    "${ssd-mnt}" = {
      device = ssd-dev;
      fsType = "btrfs";
      options = bfs-opts ++ [ "subvol=/" ];
      neededForBoot = true;
    };
  };

  swapDevices = [
    {
      # random encryption will resetup the LUKS header
      # using by-id should not change between system reboots or kernel updates
      device = "/dev/disk/by-id/nvme-KINGSTON_SNVS500G_50026B76856C0884-part2";
      randomEncryption.enable = true;
    }
  ];
}
