{ config, ... }:

{
  imports = [
    ../x86_64

    ../btrfs.nix
    ../secure-boot.nix
    ../services.nix
    ../tpm2.nix

    ./filesystem.nix
    ./persistence.nix
    ./tuxedo.nix
  ];
}
