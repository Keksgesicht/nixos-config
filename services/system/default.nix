{ config, ... }:

{
  imports = [
    ./auto-suspend.nix
    ./btrfs-snapshot.nix
    ./fancontrol.nix
    ./files-cleanup.nix
    ./offline-backup.nix
    ./server-and-config-update.nix
  ];
}
