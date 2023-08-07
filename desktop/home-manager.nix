{ config, pkgs, ...}:

let
  # $AUTH nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
in
{
  imports = [
    #<home-manager/nixos>
    (import "${home-manager}/nixos")
  ];
  # The home.stateVersion option does not have a default and must be set
  home-manager.users.keks.home.stateVersion = "18.09";
}
