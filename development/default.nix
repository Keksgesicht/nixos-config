{ config, ... }:

{
  imports = [
    #./android.nix
    ./base-devel.nix
    ./desktop.nix
    ./neovim.nix
    ./NixOS-wrappers
  ];
}
