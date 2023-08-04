{ config, pkgs, ... }:

{
  imports = [
    ../.
    ./filesystem.nix
    ../x86_64-uefi.nix
  ];
}
