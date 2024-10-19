{ ssd-mnt, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    storageDriver = "btrfs";
    autoPrune = {
      enable = true;
      dates = "Wed *-*-* 12:34:56";
      flags = [ "--all" ];
    };
  };

  environment.persistence."${ssd-mnt}".directories = [
    "/var/lib/docker"
  ];
}
