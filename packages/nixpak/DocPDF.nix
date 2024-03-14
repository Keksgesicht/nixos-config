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

  okularPkg = pkgs.kdePackages.okular;
  okularBin = "${okularPkg}/bin/okular";
  okularCfg = pkgs.writeShellScriptBin "okular" (''
    [ -e "$XDG_CONFIG_HOME/okularpartrc" ] || \
      cp "$XDG_CONFIG_HOME/okular/okularpartrc" "$XDG_CONFIG_HOME/okularpartrc"
    [ -e "$XDG_CONFIG_HOME/okularrc" ] || \
      cp "$XDG_CONFIG_HOME/okular/okularrc" "$XDG_CONFIG_HOME/okularrc"
    exec -a ${okularBin} ${okularBin} $@
  '');
  okularOut = pkgs.symlinkJoin {
    pname = "okular-cfg-wrapper";
    name  = "okular-cfg-wrapper";
    paths = [
      okularCfg
      okularPkg
    ];
  };
in
{
  nixpak."${name}" = {
    wrapper = {
      packages = [
        { package = okularOut; binName = "okular"; appFile = [
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
        [
          (sloth.concat' sloth.xdgConfigHome "/okularpartrc")
          (sloth.concat' sloth.xdgConfigHome "/okular/okularpartrc")
        ]
        [
          (sloth.concat' sloth.xdgConfigHome "/okularrc")
          (sloth.concat' sloth.xdgConfigHome "/okular/okularrc")
        ]
        "/run/current-system/sw/share/icons"
      ];
      bind.rw = [
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
