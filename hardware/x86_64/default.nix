{ config, lib, ... }:

{
  imports = [
    ./uefi.nix
    ../.
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
