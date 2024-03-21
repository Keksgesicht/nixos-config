{ config, ... }:

{
  imports = [
    ./auto-update.nix
    ./basic.nix
    ./extra-options.nix
    ./garbage-collect.nix
  ];
}
