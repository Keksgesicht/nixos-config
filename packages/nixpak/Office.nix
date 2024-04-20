{ pkgs, sloth, bindHomeDir, ... }:

let
  name = "Office";
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.libreoffice; binName = "soffice"; appFile = [
          { src = "base"; args.remove = "%U"; args.extra = "%U"; }
          { src = "calc"; args.remove = "%U"; args.extra = "%U"; }
          { src = "draw"; args.remove = "%U"; args.extra = "%U"; }
          { src = "impress"; args.remove = "%U"; args.extra = "%U"; }
          { src = "math"; args.remove = "%U"; args.extra = "%U"; }
          { src = "startcenter"; args.remove = "%U"; args.extra = "%U"; }
          { src = "writer"; args.remove = "%U"; args.extra = "%U"; }
          { src = "xsltfilter"; args.remove = "%U"; args.extra = "%U"; }
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
