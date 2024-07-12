{ ... }:

{
  imports = [
    ./auto-update.nix
    ./basic.nix
    ./extra-options.nix
    ./flake-registry.nix
    ./garbage-collect.nix
  ];
}
