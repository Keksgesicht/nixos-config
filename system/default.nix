{ config, ... }:

{
  imports = [
    ./base-pkgs.nix
    ./boot-tmpfs.nix
    ./environment.nix
    ./openssh.nix
    ./shell-zsh.nix
    ./sudo.nix
    ./systemd.nix
  ];
}
