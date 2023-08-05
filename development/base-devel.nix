# file: packages/base-devel.nix
# desc: tools for devops

{ config, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    binutils
    binwalk
    ldns
    nmap
    sshuttle
    strace
    tmux
    vim
    zellij

    # make signed commits
    git
    pinentry
  ];


  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    # FIXME: qt for KDE Plasma, it automatically falls back to curses.
    # https://search.nixos.org/options?channel=23.05&show=programs.gnupg.agent.pinentryFlavor
    pinentryFlavor = "qt";
  };
}
