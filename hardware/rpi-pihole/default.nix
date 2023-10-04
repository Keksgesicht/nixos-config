{ config, pkgs, lib, ... }:

{
  imports = [
    ./filesystem.nix
    ../aarch64
    ../aarch64/RaspberryPi.nix
  ];
}
