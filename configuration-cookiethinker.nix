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
    ./desktop/desktop.nix
    ./hardware/filesystem-laptop.nix
    ./nix/nix.nix
    ./nix/upstream.nix
    ./packages/base-devel.nix
    ./packages/common.nix
    ./packages/container.nix
    ./packages/hardware.nix
    ./packages/shell-zsh.nix
    ./system/environment.nix
    ./system/networking.nix
    ./system/qemu-user-binfmt.nix
    ./system/systemd.nix
  ];
}