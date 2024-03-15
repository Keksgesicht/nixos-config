{ config, pkgs, username, ... }:

{
  users.users."${username}".packages = with pkgs; [
    binutils
    binwalk
    fd
    file
    fzf
    git
    jq
    ldns
    lsof
    moar
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
  ];
}
