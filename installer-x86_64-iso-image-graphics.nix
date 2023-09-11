# This module defines a NixOS installation CD.
# It does contain graphical stuff.
{ config, pkgs, lib, ... }:

# nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=installer-x86_64-iso-image-graphics.nix
{
  # Define your hostname
  networking.hostName = "live-cd-image";

  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>

    ./desktop
    ./development
    ./hardware/cd-image.nix
    ./hardware/x86_64-uefi.nix
    ./nix/basic.nix
    ./nix/version-23-05.nix
    ./system
    ./system/container.nix
    ./system/networking-desktop.nix
    ./system/qemu-user-binfmt.nix
  ];

  environment.systemPackages = with pkgs; [
    firefox
    librewolf
    ungoogled-chromium
  ];

  # conflict with iso-image defaults (hardware/x86_64-uefi.nix)
  boot.loader.timeout = lib.mkForce 5;

  # conflict with NetworkManager (system/networking-desktop.nix)
  networking.wireless.enable = lib.mkForce false;

  # enable login for custom user
  users.users."keks".initialPassword = "qwerty123";
  services.xserver.displayManager.autoLogin.user = "keks";
}
