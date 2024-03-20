{ pkgs, ... }:

let
  name = "Mousai";
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.mousai; binName = "mousai"; appFile = [
          { src = "io.github.seadve.Mousai"; }
        ]; }
      ];
      audio = true;
    };

    dbus = {
      #args = [ "--log" ];
      policies = {
        # why does this prevent the application from even starting
        "io.github.seadve.Mousai" = "own";
      };
    };

    bubblewrap = {
      network = true;
    };
  };
}
