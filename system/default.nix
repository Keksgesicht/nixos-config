# file: packages/common.nix
# desc: packages which probably all systems need

{ config, pkgs, ... }:

{
  imports = [
    ./base-pkgs.nix
    ./environment.nix
    ./networking.nix
    ./openssh.nix
    ./shell-zsh.nix
    ./systemd.nix
  ];
}
