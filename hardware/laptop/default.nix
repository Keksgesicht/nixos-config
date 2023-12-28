{ config, ... }:

{
  imports = [
    ../x86_64
    ../desktop/impermanence.nix
    ./filesystem.nix
    ./tuxedo.nix
  ];
}
