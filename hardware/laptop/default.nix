{ config, pkgs, ... }:

{
  imports = [
    ../.
    ./filesystem.nix
    ../x86_64-uefi-secure-boot-tpm2.nix
    ./tuxedo.nix
  ];
}
