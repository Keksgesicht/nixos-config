{ config, pkgs, ...}:

{
  imports = [
    # $AUTH nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    # $AUTH nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager
    # $AUTH nix-channel --update
    #<home-manager/nixos>
  ];
  # The home.stateVersion option does not have a default and must be set
  home-manager.users."keks".home.stateVersion = "23.05";

  # By default, Home Manager uses a private pkgs instance [...]
  # To instead use the global pkgs that is configured via the system level nixpkgs options,
  # set the following to `true`
  home-manager.useGlobalPkgs = true;

  # By default packages will be installed to $HOME/.nix-profile
  # but they can be installed to /etc/profiles if following is set to `true`
  home-manager.useUserPackages = true;
}
