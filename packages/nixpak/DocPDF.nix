{ pkgs, lib, sloth, bindHomeDir, myKDEpkg, myKDEmount, ... }:

let
  name = "DocPDF";
  latexSet = "base";

  latexBase = [
    (pkgs.texlive.combine {
      inherit (pkgs.texlive)
        scheme-small
        latexmk
      ;
    })
  ];
  latexWork = [
    (pkgs.texlive.combine {
      inherit (pkgs.texlive)
        # base texlive packages
        scheme-small
        latexmk
        # TUDa comperate design
        tuda-ci
        anyfontsize
        environ
        fontaxes
        roboto
        xcharter
        xstring
        # additional packages
        csquotes
        fontawesome
        siunitx
      ;
    })
  ];

  okularPkg = (myKDEpkg pkgs.kdePackages.okular "okular" "cp -n" [
    "" "part"
  ]);
in
{
  /*
  nixpkgs.config.permittedInsecurePackages = [
    "xpdf-4.05" # pdfdiff
  ];
  */

  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = okularPkg; binName = "okular"; appFile = [
          { src = "org.kde.okular"; args.remove = "%U"; args.extra = "%U"; }
        ]; }
        { package = pkgs.pdfarranger; binName = "pdfarranger"; appFile = [
          { src = "com.github.jeromerobert.pdfarranger";
            args.remove = "%U"; args.extra = "%U"; }
        ]; }
        { package = pkgs.pympress; binName = "pympress"; appFile = [
          { src = "io.github.pympress"; }
        ]; }
        { package = pkgs.texstudio; binName = "texstudio"; appFile = [
          { args.remove = "%F"; args.extra = "%F"; }
        ]; }
        { package = pkgs.xournalpp; binName = "xournalpp"; appFile = [
          { src = "com.github.xournalpp.xournalpp"; }
        ]; }
        # PDF tools
        #pkgs.pdfdiff
        pkgs.pdfgrep
      ]
      # LaTeX stuff
      ++ lib.optionals (latexSet == "base") latexBase
      ++ lib.optionals (latexSet == "work") latexWork
      ;
      variables = {
        QT_PLUGIN_PATH = [
          "${pkgs.kdePackages.qtwayland}/lib/qt-6/plugins"
          "${pkgs.kdePackages.breeze}/lib/qt-6/plugins"
          "${pkgs.kdePackages.breeze-icons}/lib/qt-6/plugins"
          "${pkgs.kdePackages.frameworkintegration}/lib/qt-6/plugins"
        ];
      };
      printing = true;
    };

    bubblewrap = {
      bind.ro = [
        (myKDEmount "okular" "")
        (myKDEmount "okular" "part")
        "/run/current-system/sw/share/icons"

        (sloth.xdgDocumentsDir)
      ];
      bind.rw = [
        (bindHomeDir name "/.config/pdfarranger")
        (bindHomeDir name "/.config/texstudio")
        (bindHomeDir name "/.config/xournalpp")

        # find ~/.var/app/DocPDF/.local/share/okular -type f -mtime +360 -delete
        (bindHomeDir name "/.local/share/okular")

        (sloth.concat' sloth.xdgDocumentsDir "/Office")
        (sloth.concat' sloth.xdgDocumentsDir "/Studium")
        (sloth.xdgDownloadDir)
        (sloth.concat' sloth.homeDir "/git")
        (sloth.concat' sloth.homeDir "/Module")
      ];
    };
  };
}
