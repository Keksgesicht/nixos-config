{ config, ... }:

{
  imports = [
    ./auto-update.nix
    ./basic.nix
    ./garbage-collect.nix
  ];
}
