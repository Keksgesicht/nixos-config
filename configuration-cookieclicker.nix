# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # Define your hostname
  networking.hostName = "cookieclicker";

  imports = [
    ./desktop
    ./desktop/gaming.nix
    ./development/base-devel.nix
    ./hardware/desktop
    ./nix
    ./nix/flakes.nix
    ./nix/upstream-23-05.nix
    ./services/system
    ./services/user/ferdium.nix
    ./system
    ./system/container.nix
    ./system/networking-desktop.nix
    ./system/qemu-user-binfmt.nix
  ];
}
