{ config, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    binutils
    binwalk
    fd
    fzf
    git
    ldns
    lsof
    jq
    moar
    neovim
    nix-index
    nmap
    psmisc
    pstree
    pv
    ripgrep
    screen
    sshuttle
    strace
    zellij
  ];

  programs.tmux.enable = true;
}
