{ config, pkgs, ...}:

{
  imports = [
    # $AUTH nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    # $AUTH nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager
    # $AUTH nix-channel --update
    <home-manager/nixos>
  ];
  # The home.stateVersion option does not have a default and must be set
  home-manager.users."keks".home.stateVersion = "18.09";
}
