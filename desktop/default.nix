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
    ./home-manager.nix
    ./kde-plasma.nix
    ./openssh.nix
    ./packages.nix
  ];
}
