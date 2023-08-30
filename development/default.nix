{ config, pkgs, ... }:

{
  imports = [
    ./android.nix
    ./base-devel.nix
    ./desktop.nix
    ./neovim.nix
  ];
}
