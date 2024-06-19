{ bindHomeDir, myKDEpkg, myKDEmount, ... }:
{ pkgs, ... }:

let
  name = "BilderAnguck";

  gwenviewPkg = (myKDEpkg pkgs.kdePackages.gwenview "gwenview" "cp -n" [ "" ]);
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        # base system
        { package = pkgs.copyq; binName = "copyq"; appFile = [
          { src = "com.github.hluk.copyq"; }
        ]; }
        gwenviewPkg
        pkgs.metadata-cleaner
        # picture editor
        { package = pkgs.gimp; binName = "gimp"; }
        { package = pkgs.inkscape; binName = "inkscape"; appFile = [
          { src = "org.inkscape.Inkscape"; }
        ]; }
        # cli tools for pictures
        pkgs.graphviz
        pkgs.imagemagick
        pkgs.xdot
      ];
      qtKDEintegration = true;
    };

    bubblewrap = {
      bind.ro =
      [
        (myKDEmount "gwenview" "")
      ];
      bind.rw = [
        (bindHomeDir name "/.config/copyq")
        (bindHomeDir name "/.config/GIMP")
        (bindHomeDir name "/.config/inkscape")
      ];
    };
  };
}
