{ config, ... }:

{
  imports = [
    ./auto-suspend.nix
    ./backup-download.nix
    ./backup-offline.nix
    ./backup-snapshot.nix
    ./bluetooth-autoconnect.nix
    ./fancontrol.nix
    ./files-cleanup.nix
    ./wireguard.nix
    ../containers
  ];
}
