{ config, ... }:

{
  imports = [
    ../services/impermanence.nix
    ./filesystem.nix
    ./tuxedo.nix
  ];
}
