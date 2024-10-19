{ ... }:

{
  # Define your hostname
  networking.hostName = "cookiethinker";

  imports = [
    ../desktop
    ../development
    ../hardware
    ../hardware/laptop
    ../hardware/office
    ../hardware/services/baremetal.nix
    ../hardware/x86_64/desktop.nix
    ../nix
    ../nix/build-cache-client.nix
    ../nix/version-23-05.nix
    ../services/system/backup-snapshot.nix
    ../services/system/files-cleanup.nix
    ../services/system/wireguard/client.nix
    ../system
    ../system/containers/podman.nix
    ../system/network/desktop
    ../system/network/desktop/secrets.nix
  ];
}
