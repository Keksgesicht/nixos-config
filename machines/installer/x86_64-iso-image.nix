# This module defines a small NixOS installation CD.
# It does not contain any graphical stuff.
{ config, pkgs, ... }:

# nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=installer-x86_64-iso-image.nix
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>

    ../nix/installer.nix
  ];
}
