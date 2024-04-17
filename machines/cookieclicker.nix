# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
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
    ../nix
    ../nix/build-cache-client.nix
    ../nix/build-cache-server.nix
    ../nix/version-23-05.nix
    ../services/system
    ../system
    ../system/container.nix
    ../system/network/desktop
    ../system/network/desktop/secrets.nix
  ];
}
