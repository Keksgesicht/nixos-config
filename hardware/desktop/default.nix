{ config, pkgs, ... }:

{
  imports = [
    ../.
    ../x86_64-uefi.nix
    ../tpm2.nix
    ./filesystem.nix
    ./services.nix
    ./sysctl.nix
  ];
}
