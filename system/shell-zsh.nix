# file: packages/shell-zsh.nix
# desc: zsh and its extensions
{ pkgs, ...}:

let
  my_zsh_config = (pkgs.callPackage ../packages/config-zsh.nix {});
in
{
  programs.zsh = {
    enable = true;
    interactiveShellInit = ''
      export ZSH_PLUGIN_AUTOSUGGESTIONS=${pkgs.zsh-autosuggestions}
      export ZSH_PLUGIN_HISTORY_SEARCH=${pkgs.zsh-history-substring-search}
      export ZSH_PLUGIN_SYNTAX_HIGHTLIGHTING=${pkgs.zsh-syntax-highlighting}
      export ZSH_PLUGIN_POWERLEVEL=${pkgs.zsh-powerlevel10k}

      export ZSHCFGDIR=${my_zsh_config}
      source ${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh
    '';
  };

  # Fuck you. Fucking fuck you NixOS default /etc/zshrc
  # Here is my workaround to restore my `ll` alias.
  environment.etc."zshrc.local".source = "${my_zsh_config}/zshrc";

  users.defaultUserShell = pkgs.zsh;
}
