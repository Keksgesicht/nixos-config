{ config, pkgs, sloth, bindHomeDir, myKDEpkg, myKDEmount, ... }:

let
  name = "VideoEdit";

  gwenviewPkg = (myKDEpkg pkgs.kdePackages.gwenview "gwenview" "cp -n" [ "" ]);
  kdenlivePkg = (myKDEpkg pkgs.kdePackages.kdenlive "kdenlive" "ln -sf" [
    "" "-flatpak" "-layouts"
  ]);
  silence-cutter = (pkgs.callPackage ../silence-cutter.nix {});
in
{
  nixpak = if (config.networking.hostName == "cookieclicker") then {
  "${name}" = {
    wrapper = {
      packages = [
        { package = kdenlivePkg; binName = "kdenlive"; appFile = [
          { src = "org.kde.kdenlive"; }
        ]; }
        #{ package = pkgs.handbrake; binName = "ghb"; appFile = [
        #  { src = "fr.handbrake.ghb"; }
        #]; }
        { package = pkgs.audacity; binName = "audacity"; }
        # tools for kdenlive
        # https://github.com/NixOS/nixpkgs/issues/209923
        gwenviewPkg
        pkgs.glaxnimate
        pkgs.mediainfo
        pkgs.mlt
        pkgs.mlt.ffmpeg
        # additional cli tools for video editing
        silence-cutter
      ];
      qtKDEintegration = true;
      audio = true;
    };

    dbus.policies = {
      "org.kde.kdenlive.*" = "own";
    };

    bubblewrap = {
      bind.ro = [
        [
          ("${pkgs.mlt}/share/mlt-7/profiles")
          ("/app/share/mlt-7/profiles")
        ]
        (myKDEmount "gwenview" "")

        sloth.xdgDocumentsDir
        sloth.xdgMusicDir
        sloth.xdgPicturesDir
      ];
      bind.rw = [
        (bindHomeDir name "/.config/ghb")
        (bindHomeDir name "/.config/kdenlive")

        (sloth.mkdir (sloth.concat' sloth.xdgDownloadDir "/sandbox"))
        (sloth.xdgVideosDir)
      ];
    };
  }; } else {};
}
