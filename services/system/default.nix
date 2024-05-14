{ ... }:

{
  imports = [
    ./auto-suspend.nix
    ./backup-download.nix
    ./backup-offline.nix
    ./backup-snapshot.nix
    ./fancontrol.nix
    ./files-cleanup.nix
    ./wireguard/server.nix

    ../containers/dyndns.nix
    ../containers/lancache.nix
    ../containers/pihole.nix
    ../containers/proxy.nix
    ../containers/unbound.nix
  ];
}
