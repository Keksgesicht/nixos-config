{ config, pkgs, ... }:

{
  imports = [
    ../x86_64

    ../btrfs.nix
    ../secure-boot.nix
    ../services.nix
    ../tpm2.nix

    ./filesystem.nix
    ./impermanence.nix
    ./gaming.nix
    ./services.nix
    ./sysctl.nix
  ];
}
