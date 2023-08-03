# file: packages/flatpak-flathub.nix

{ config, pkgs, ...}:

{
  # enable flatpak
  services.flatpak.enable = true;
  users.users.keks.packages = with pkgs; [
    discover
  ];

  # add flathub as a flatpak repository
  /*
   * flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
   * flatpak update
   */
}
