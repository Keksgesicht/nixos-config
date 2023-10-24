{ config, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    binutils
    binwalk
    fd
    fzf
    git
    imagemagick
    jq
    ldns
    lsof
    moar
    nix-index
    nmap
    psmisc
    pstree
    pv
    ripgrep
    screen
    sshuttle
    strace
    unixtools.xxd
    zellij
  ];

  programs.tmux.enable = true;
}
