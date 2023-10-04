{ config, lib, ... }:

{
  imports = [
    ./binfmt.nix
    ../.
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
