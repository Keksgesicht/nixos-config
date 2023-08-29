# file: packages/shell-zsh.nix
# desc: zsh and its extensions

{ config, pkgs, ...}:

let
  my_zsh_config = (pkgs.callPackage ../packages/zsh-config.nix {});
in
{
  environment.systemPackages = with pkgs; [
    zsh
    zsh-autosuggestions
    zsh-history-substring-search
    zsh-syntax-highlighting
    zsh-powerlevel10k
    zsh-nix-shell
  ];

  programs.zsh = {
    enable = true;
    interactiveShellInit = ''
      touch ~/.zshrc
      export ZSHCFGDIR=${my_zsh_config}
    '';
  };

  # Fuck you. Fucking fuck you NixOS default /etc/zshrc
  # Here is my workaround to restore my `ll` alias.
  environment.etc."zshrc.local" = {
    source = "${my_zsh_config}/zshrc";
    mode = "0555";
  };

  users.defaultUserShell = pkgs.zsh;
}
