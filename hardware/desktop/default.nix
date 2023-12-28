{ config, pkgs, ... }:

{
  imports = [
    ../x86_64
    ./filesystem.nix
    ./impermanence.nix
    ./gaming.nix
    ./services.nix
    ./sysctl.nix
  ];
}
