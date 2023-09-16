{ config, pkgs, ... }:

{
  imports = [
    ./binfmt.nix
    ./uefi.nix
  ];
}
