# file: user/desktop.nix
# desc: focus on user specific settings for systems with DE/WM

{ config, ... }:

{
  # Enable CUPS to print documents.
  services.printing.enable = true;

  imports = [
    ./audio
    ./environment-desktop.nix
    ./flatpak.nix
    ./home-manager
    ./impermanence-directories.nix
    ./impermanence-files.nix
    ./kde-plasma.nix
    ./my-user.nix
    ./openssh.nix
    ./packages.nix
    ../services/user/xscreensaver.nix
  ];
}
