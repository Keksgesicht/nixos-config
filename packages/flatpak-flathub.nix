# file: packages/flatpak-flathub.nix

{ config, pkgs, ...}:

{
  # enable flatpak
  services.flatpak.enable = true;

  # add flathub as a flatpak repository
  environment.etc = {
    "enable-flathub-as-repo" = {
      target = "flatpak/remotes.d/flathub.flatpakrepo";
      source = pkgs.fetchurl {
        url = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        # Let this run once and you will get the hash as an error.
        hash = "sha256:3371dd250e61d9e1633630073fefda153cd4426f72f4afa0c3373ae2e8fea03a";
      };
    };
  };
}
