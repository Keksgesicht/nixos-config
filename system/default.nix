{ ... }:

{
  imports = [
    ./base-pkgs.nix
    ./boot-tmpfs.nix
    ./environment.nix
    ./openssh
    ./shell-zsh.nix
    ./sudo.nix
    ./systemd.nix
  ];
}
