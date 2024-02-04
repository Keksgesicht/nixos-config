{ config, ... }:

{
  imports = [
    ../services/impermanence.nix
    ./filesystem.nix
    ./gaming.nix
    ./services.nix
    ./sysctl.nix
  ];
}
