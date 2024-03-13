{ config, pkgs, username, ... }:

{
  users.users."${username}".packages = with pkgs; [
    binutils
    binwalk
    fd
    file
    fzf
    git
    graphviz
    imagemagick
    jq
    ldns
    lsof
    moar
    nix-index
    nmap
    psmisc
    pv
    p7zip
    ripgrep
    screen
    sshuttle
    strace
    unixtools.xxd
    unzip
    xdot
  ];
}
