# file: hardware/filesystem-laptop.nix
# desc: (mostly) auto generated file for the hardware of my laptop

# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  boot = {
    initrd = {
      /*
       * fTPM not working under Linux
       * TEMPORARY SOLUTION (throwing away single drives without thinking should work and I can still use Wake on LAN)
       * find -L /dev/disk -samefile /dev/sdh2
       * dd status=progress bs=2048 if=/etc/unCookie/keys/luks-cache of=/dev/sdh2 seek=0
       */
      luks.devices = {
        "cache1" = {
          device = "/dev/disk/by-label/cache1";
          keyFile = "/dev/disk/by-partuuid/c58965ae-8061-714c-94ef-11c57da14a63";
          keyFileSize = 2048;
        };
        "cache2" = {
          device = "/dev/disk/by-label/cache2";
          keyFile = "/dev/disk/by-partuuid/c58965ae-8061-714c-94ef-11c57da14a63";
          keyFileSize = 2048;
        };
        "array1" = {
          device = "/dev/disk/by-label/array1";
          keyFile = "/dev/disk/by-partuuid/3375b91e-8e21-7e46-ad42-fcdc11b8858a";
          keyFileSize = 2048;
        };
        "array3" = {
          device = "/dev/disk/by-label/array3";
          keyFile = "/dev/disk/by-partuuid/3375b91e-8e21-7e46-ad42-fcdc11b8858a";
          keyFileSize = 2048;
        };
        "array4" = {
          device = "/dev/disk/by-label/array4";
          keyFile = "/dev/disk/by-partuuid/3375b91e-8e21-7e46-ad42-fcdc11b8858a";
          keyFileSize = 2048;
        };
        "ram3" = {
          device = "/dev/disk/by-label/ram3";
          keyFile = "/dev/disk/by-partuuid/7bf59cfb-f4ea-c047-84b0-8b7ac74d76a4";
          keyFileSize = 2048;
          allowDiscards = true;
          #keyFileOffset = 14107;
        };
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/cache";
      fsType = "btrfs";
      options = [
        "subvol=root"
        "compress=zstd:3"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/71BF-4837";
      fsType = "vfat";
      options = [
        "umask=0077"
        "shortname=winnt"
      ];
    };

    "/home" = {
      device = "/dev/disk/by-label/cache";
      fsType = "btrfs";
      options = [
        "subvol=home"
        "compress=zstd:3"
      ];
    };

    "/mnt/cache" = {
      device = "/dev/disk/by-label/cache";
      fsType = "btrfs";
      options = [
        "subvol=/"
        "compress=zstd:3"
      ];
    };

    "/mnt/array" = {
      device = "/dev/disk/by-label/array";
      fsType = "btrfs";
      options = [
        "subvol=/"
        "compress-force=zstd:3"
      ];
    };

    "/mnt/ram" = {
      device = "/dev/disk/by-label/ram";
      fsType = "btrfs";
      options = [
        "subvol=/"
        "compress=zstd:3"
      ];
    };

    "/nix" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = [
        "subvol=nix"
        "compress=zstd:3"
      ];
    };
  };

  swapDevices = [
    {
      # random encryption will resetup the LUKS header
      # using by-partuuid should not change between system reboots or kernel updates
      device = "/dev/disk/by-partuuid/85439545-b3f4-f742-948f-e3a7190f5fc7";
      randomEncryption.enable = true;
      options = [
        "nofail"
      ];
    }
  ];
}