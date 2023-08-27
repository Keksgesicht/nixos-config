# file: packages/common.nix
# desc: packages which probably all systems need

{ config, pkgs, ... }:

{
  imports = [
    ./base-pkgs.nix
    ./boot-tmpfs.nix
    ./environment.nix
    ./openssh.nix
    ./shell-zsh.nix
    ./systemd.nix
  ];
}
