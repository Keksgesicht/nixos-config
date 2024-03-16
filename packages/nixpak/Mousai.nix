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

    bubblewrap = {
      network = true;
    };
  };
}
