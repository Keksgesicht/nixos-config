# file: nix/nix.nix
# desc: basic settings for nix tools itself

{ config, pkgs, ... }:

{
  imports = [
    ./auto-update.nix
    ./basic.nix
    ./garbage-collect.nix
  ];
}
