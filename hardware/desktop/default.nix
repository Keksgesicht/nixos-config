{ config, pkgs, ... }:

{
  imports = [
    ../.
    ../x86_64-uefi.nix
    ./filesystem.nix
  ];
}
