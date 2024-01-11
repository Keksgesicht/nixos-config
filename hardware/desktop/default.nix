{ config, pkgs, ... }:

{
  imports = [
    ../services/impermanence.nix
    ../x86_64
    ./filesystem.nix
    ./gaming.nix
    ./services.nix
    ./sysctl.nix
  ];
}
