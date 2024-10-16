{ sloth, bindHomeDir, myKDEpkg, myKDEmount, ... }:
{ pkgs, lib, ... }:

let
  name = "DocPDF";
  latexSet = "work";

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
        adjustbox
        anyfontsize
        environ
        fontaxes
        pdfx
        roboto
        urcls
        xcharter
        xstring
        # additional packages
        csquotes
        datetime
        fmtcount
        fontawesome
        forest
        glossaries
        numprint
        pgf-umlsd
        siunitx
        xmpincl
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
        okularPkg
        # PDF tools
        #pkgs.pdfdiff
        pkgs.pdfgrep
        pkgs.ocrmypdf
      ]
      # LaTeX stuff
      ++ lib.optionals (latexSet == "base") latexBase
      ++ lib.optionals (latexSet == "work") latexWork
      ;
      qtKDEintegration = true;
      printing = true;
    };

    bubblewrap = {
      bind.ro = [
        (myKDEmount "okular" "")
        (myKDEmount "okular" "part")
        (sloth.concat' sloth.homeDir "/texmf") # TUDa Logo and other templates
      ];
      bind.rw = [
        (bindHomeDir name "/.config/pdfarranger")
        (bindHomeDir name "/.config/texstudio")
        (bindHomeDir name "/.config/xournalpp")

        (sloth.concat' sloth.xdgDocumentsDir "/Office")
        (sloth.concat' sloth.xdgDocumentsDir "/Studium")
        (sloth.xdgDownloadDir)
        (sloth.concat' sloth.homeDir "/git")
        (sloth.concat' sloth.homeDir "/Module")
      ];
    };
  };
}
