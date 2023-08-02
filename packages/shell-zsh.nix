# file: packages/shell-zsh.nix
# desc: zsh and its extensions

{ config, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    zsh
    zsh-autosuggestions
    zsh-history-substring-search
    zsh-syntax-highlighting
    zsh-powerlevel10k
  ];

  programs.zsh.enable = true;
}

