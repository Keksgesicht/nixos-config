{ config, ... }:

{
  imports = [
    ./base-devel.nix
    ./desktop.nix
    ./neovim.nix
    ./NixOS-wrappers
  ];
}
