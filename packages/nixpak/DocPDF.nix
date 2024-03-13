{ pkgs, lib, sloth, bindHomeDir, ... }:

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
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = pkgs.kdePackages.okular; binName = "okular"; appFile = [
          { src = "org.kde.okular"; }
        ]; }
        { package = pkgs.pdfarranger; binName = "pdfarranger"; appFile = [
          { src = "com.github.jeromerobert.pdfarranger"; }
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

      printing = true;
    };

    bubblewrap = {
      bind.rw = [
        (sloth.concat' sloth.xdgConfigHome "/okularpartrc")
        (sloth.concat' sloth.xdgConfigHome "/okularrc")
        (bindHomeDir name "/.config/pdfarranger")
        (bindHomeDir name "/.config/texstudio")
        (bindHomeDir name "/.config/xournalpp")
        (bindHomeDir name "/.local/share/okular")

        (sloth.concat' sloth.xdgDocumentsDir "/Studium")
        (sloth.concat' sloth.homeDir "/git")
        (sloth.concat' sloth.homeDir "/Module")
      ];
    };
  };
}
