# This module defines a NixOS installation CD.
# It does contain graphical stuff.
{ config, pkgs, lib, username, ... }:

{
  imports = [
    ./laptop.nix
    ../../desktop/audio.nix
    ../../desktop/environment-desktop.nix
    ../../desktop/home-manager
    ../../desktop/kde-plasma.nix
    ../../desktop/packages.nix
    ../../development
    ../../nix/basic.nix
    ../../nix/version-23-05.nix
    ../../system
    ../../system/container.nix
    ../../system/networking-desktop.nix
  ];

  users.users."${username}".packages = with pkgs; [
    firefox
    librewolf
    ungoogled-chromium
  ];

  # conflict with iso-image defaults (hardware/x86_64-uefi.nix)
  boot.loader.timeout = lib.mkForce 5;

  # conflict with NetworkManager (system/networking-desktop.nix)
  networking.wireless.enable = lib.mkForce false;

  # enable login for custom user
  services.xserver.displayManager.autoLogin.user = username;
}
