# file: packages/base-devel.nix
# desc: tools for devops

{ config, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    binutils
    binwalk
    flatpak-builder
    git
    ldns
    nmap
    sshuttle
    strace
    inetutils
    tmux
    vim
    zellij
  ];
}
