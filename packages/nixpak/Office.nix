{ pkgs, sloth, bindHomeDir, ... }:

let
  name = "Office";
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.libreoffice; binName = "soffice"; appFile = [
          { src = "base"; }
          { src = "calc"; }
          { src = "draw"; }
          { src = "impress"; }
          { src = "math"; }
          { src = "startcenter"; }
          { src = "writer"; }
          { src = "xsltfilter"; }
        ]; }
      ];
      printing = true;
    };

    bubblewrap = {
      bind.rw = [
        (bindHomeDir name "/.config/libreoffice")

        (sloth.xdgDocumentsDir)
        (sloth.xdgDownloadDir)
        (sloth.concat' sloth.homeDir "/Module")
      ];
    };
  };
}
