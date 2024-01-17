{ config, ... }:

{
  imports = [
    #./android.nix
    ./base-devel.nix
    ./gnupg.nix
    ./neovim.nix
    ./NixOS-wrappers
    ./tmux.nix
  ];
}
