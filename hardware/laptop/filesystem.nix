{ config, lib, pkgs, ... }:

let
  bfs-opts = [
    "compress=zstd:3"
  ];
in
{
  boot = {
    initrd = {
      luks.devices = {
        "root" = {
          device = "/dev/disk/by-uuid/c720b152-baf0-4336-bb04-83f01857cfab";
        };
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = bfs-opts ++ [ "subvol=root" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/90CE-7A63";
      fsType = "vfat";
      options = [
        "umask=0077"
        "shortname=winnt"
      ];
    };
    "/home" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = bfs-opts ++ [ "subvol=home" ];
    };
    "/nix" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = bfs-opts ++ [ "subvol=nix" ];
    };

    "/mnt" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = bfs-opts ++ [ "subvol=mnt" ];
    };
    "/mnt/array" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = bfs-opts ++ [ "subvol=mnt-array" ];
    };
    "/mnt/cache" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = bfs-opts ++ [ "subvol=/" ];
    };
  };

  swapDevices = [
    {
      # random encryption will resetup the LUKS header
      # using by-id should not change between system reboots or kernel updates
      device = "/dev/disk/by-id/nvme-KINGSTON_SNVS500G_50026B76856C0884-part3";
      randomEncryption.enable = true;
    }
  ];
}
