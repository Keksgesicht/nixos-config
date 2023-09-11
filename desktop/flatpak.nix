# file: packages/flatpak-flathub.nix

{ config, pkgs, ...}:

{
  # enable flatpak
  services.flatpak.enable = true;
  # add flathub as a flatpak repository
  /*
   * flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
   * flatpak update
   */

  # install KDE package manager
  users.users."keks".packages = with pkgs; [
    discover
  ];
  # use PackageKit for nixpkgs in Discover
  services.packagekit.enable = true;
}
