# file: user/desktop.nix
# desc: focus on user specific settings for systems with DE/WM

{ config, pkgs, ...}:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.keks = {
    isNormalUser = true;
    description = "Jan B.";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  imports = [
    ./audio.nix
    ./environment.nix
    ./flatpak.nix
    ./kde-plasma.nix
    ./packages.nix
  ];
}
