{ config, pkgs, ... }:

{
  imports = [
    ../.
    ../x86_64-uefi-secure-boot-tpm2.nix
    ../tpm2.nix
    ./filesystem.nix
    ./tuxedo.nix
  ];
}
