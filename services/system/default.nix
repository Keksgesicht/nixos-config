{ config, ... }:

{
  imports = [
    ./auto-suspend.nix
    ./backup-offline.nix
    ./backup-snapshot.nix
    ./bluetooth-autoconnect.nix
    ./fancontrol.nix
    ./files-cleanup.nix
    ./server-and-config-update.nix
    ./wireguard.nix
    ../containers
  ];
}
