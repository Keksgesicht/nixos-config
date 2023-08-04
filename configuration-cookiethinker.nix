# file: conguration-cookiethinker.nix
# desc: config for laptop

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # Define your hostname
  networking.hostName = "cookiethinker";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  imports = [
    ./desktop
    ./development/base-devel.nix
    ./hardware/filesystem-laptop.nix
    ./hardware/packages.nix
    ./nix/nix.nix
    ./nix/upstream-23-05.nix
    ./system
    ./system/container.nix
    ./system/networking.nix
    ./system/qemu-user-binfmt.nix
  ];
}
