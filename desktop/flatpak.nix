{ config, pkgs, username, ... }:

let
  flatpak-overrides = pkgs.callPackage ../packages/flatpak-overrides.nix {};
in
{
  users.users."${username}".packages = with pkgs; [
    (callPackage ../packages/flatpak-rollback.nix {})
  ];

  # enable flatpak
  services.flatpak.enable = true;
  # add flathub as a flatpak repository
  /*
   * flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
   * flatpak update
   */

  # generate flatpak overrides by NixOS config
  systemd.tmpfiles.rules = [
    "L+ /var/lib/flatpak/overrides - - - - ${flatpak-overrides}"
  ];
}
