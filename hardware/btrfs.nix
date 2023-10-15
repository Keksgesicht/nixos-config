{ config, ... }:

{
  services.btrfs.autoScrub = {
    enable = true;
    # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/tasks/filesystems/btrfs.nix
    # the above says the timer is "Persistent".
    interval = "*-2,5,8,11-13 04:20:42";
    fileSystems =
      if (config.networking.hostName == "cookieclicker") then
        [
          "/mnt/cache"
          "/mnt/array"
          "/mnt/ram"
        ]
      else [ "/" ];
  };
}
