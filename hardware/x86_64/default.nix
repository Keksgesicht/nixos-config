{ config, lib, ... }:

{
  imports = [
    #./binfmt.nix
    ./uefi.nix
    ../.
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
