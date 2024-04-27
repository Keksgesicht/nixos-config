{ ssd-mnt, hdd-mnt, ... }:

let
  ssd-dev = "/dev/mapper/root";
  bfs-opts = [
    "compress=zstd:3"
  ];
in
{
  fileSystems = {
    "/boot" = {
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
}
