{ ... }:
{ pkgs-stable, ... }:

let
  pkgs = pkgs-stable {};
  name = "Metadata-Cleaner";
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.metadata-cleaner; binName = "metadata-cleaner"; appFile = [
          { src = "fr.romainvigier.MetadataCleaner"; }
        ]; }
      ];
      variables = {
        GDK_BACKEND = "x11";
      };
    };

    dbus.policies = {
      "fr.romainvigier.MetadataCleaner" = "own";
    };

    bubblewrap = {
      sockets.x11 = true;
    };
  };
}
