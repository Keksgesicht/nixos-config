{ config, pkgs, ... }:

{
  imports = [
    ../.
    ../x86_64

    ../btrfs.nix
    ../services.nix
    ../tpm2.nix

    ./filesystem.nix
    ./tuxedo.nix
  ];
}
