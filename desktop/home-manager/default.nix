{ config, pkgs, lib
, username, home-dir
, ...}:

{
  home-manager.users."${username}" = {
    # The home.stateVersion option does not have a default and must be set
    home.stateVersion  = "23.05";
    # Some modules do not do anything without it.
    home.homeDirectory = home-dir;

    imports = [
      ((import ./applications.desktop.nix) username)
      ((import ./autostart.nix) config username)
      ./mimeapps.nix
    ];
  };

  # By default, Home Manager uses a private pkgs instance [...]
  # To instead use the global pkgs that is configured via the system level nixpkgs options,
  # set the following to `true`
  home-manager.useGlobalPkgs = true;

  # By default packages will be installed to $HOME/.nix-profile
  # but they can be installed to /etc/profiles if following is set to `true`
  home-manager.useUserPackages = true;
}
