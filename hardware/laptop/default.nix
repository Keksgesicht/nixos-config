{ config, ... }:

{
  imports = [
    ../services/impermanence.nix
    ../x86_64
    ./filesystem.nix
    ./tuxedo.nix
  ];
}
