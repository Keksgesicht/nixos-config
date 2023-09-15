{ config, ... }:

{
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
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
