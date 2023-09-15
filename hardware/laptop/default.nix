{ config, pkgs, ... }:

{
  imports = [
    ../.
    ../btrfs.nix
    ../x86_64-uefi.nix
    ../services.nix
    ../tpm2.nix
    ./filesystem.nix
    ./tuxedo.nix
  ];
}
