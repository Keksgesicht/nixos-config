{ config, ... }:

{
  imports = [
    #./android.nix
    ./base-devel.nix
    ./gnupg.nix
    ./neovim.nix
    ./tmux.nix
  ];
}
