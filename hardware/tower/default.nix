{ ... }:

{
  imports = [
    ../services/impermanence.nix
    ./filesystem.nix
    ./services.nix
    ./sysctl.nix
  ];
}
