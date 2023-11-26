{ config, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    binutils
    binwalk
    fd
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
    unrar
    unzip
    xdot
    zellij
  ];

  programs.tmux.enable = true;
}
