# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, ... }:

{
  # Define your hostname
  networking.hostName = "cookiethinker";

  imports = [
    ../desktop
    ../development
    ../hardware
    ../hardware/laptop
    ../nix
    ../nix/build-cache-client.nix
    ../nix/version-23-05.nix
    ../services/system/bluetooth-autoconnect.nix
    ../services/system/backup-snapshot.nix
    ../services/system/files-cleanup.nix
    ../services/system/wireguard.nix
    ../system
    ../system/container.nix
    ../system/networking-desktop.nix
    ../system/networking-desktop-secrets.nix
  ];
}
