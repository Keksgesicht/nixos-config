{ ... }:

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

    ../containers/dyndns.nix
    ../containers/lancache.nix
    ../containers/pihole.nix
    ../containers/proxy.nix
    ../containers/unbound.nix
  ];
}
