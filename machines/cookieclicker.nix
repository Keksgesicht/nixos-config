# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, ... }:

{
  # Define your hostname
  networking.hostName = "cookieclicker";

  imports = [
    ../desktop
    ../desktop/gaming.nix
    ../development
    ../hardware
    ../hardware/desktop
    ../nix
    ../nix/build-cache-server.nix
    ../nix/version-23-05.nix
    ../services/system
    ../system
    ../system/container.nix
    ../system/networking-desktop.nix
    ../system/networking-desktop-secrets.nix
  ];
}
