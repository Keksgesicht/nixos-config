{ config, pkgs, ... }:

{
  imports = [
    ./base-devel.nix
    ./desktop.nix
    ./neovim.nix
    ./nix-cage.nix
  ];
}
