# file: user/desktop.nix
# desc: focus on user specific settings for systems with DE/WM

{ config, pkgs, ...}:

{
  # Enable CUPS to print documents.
  services.printing.enable = true;

  imports = [
    ./audio.nix
    ./environment-desktop.nix
    ./flatpak.nix
    ./home-manager.nix
    ./kde-plasma.nix
    ./openssh.nix
    ./packages.nix
    ./user-keks.nix
    ../services/user/xscreensaver.nix
  ];
}
