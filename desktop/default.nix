{ ... }:

{
  # Enable CUPS to print documents.
  services.printing.enable = true;

  imports = [
    ./audio
    ./environment-desktop.nix
    ./flatpak.nix
    ./home-manager
    ./home-manager/desktop.nix
    ./impermanence-directories.nix
    ./impermanence-files.nix
    ./kde-plasma.nix
    ./my-user.nix
    ./openssh.nix
    ./packages.nix
    ../packages/nixpak
    ../services/user/xscreensaver.nix
  ];
}
