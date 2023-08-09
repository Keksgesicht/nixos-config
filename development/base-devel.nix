# file: packages/base-devel.nix
# desc: tools for devops

{ config, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    binutils
    binwalk
    ldns
    lsof
    jq
    moar
    nix-index
    nmap
    psmisc
    pstree
    sshuttle
    strace
    tmux
    vim
    zellij

    # make signed commits
    git
    pinentry-qt
  ];

  # make signed commits
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    # echo "pinentry-program /run/current-system/sw/bin/pinentry-qt" > ~/.config/gnupg/gpg-agent.conf
    pinentryFlavor = "qt";
  };
}
