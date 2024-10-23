{ ... }:

{
  # Define your hostname
  networking.hostName = "cookieclicker";

  imports = [
    ../desktop
    ../desktop/gaming.nix
    ../development
    ../hardware
    ../hardware/office
    ../hardware/tower
    ../hardware/services/baremetal.nix
    ../hardware/x86_64/desktop.nix
    ../nix
    ../nix/build-cache-client.nix
    ../nix/build-cache-server.nix
    ../nix/version-23-05.nix
    ../services/system/cookieclicker.nix
    ../services/system/dyndns.nix
    ../system
    ../system/containers/podman.nix
    ../system/network/desktop
    ../system/network/desktop/secrets.nix
  ];
}
