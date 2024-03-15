{ pkgs, lib, sloth, bindHomeDir, ... }:

let
  name = "BilderAnguck";

  myKDEpkg = (pkg: name:
    let
      kdeBin = "${pkg}/bin/${name}";
      kdeCfg = pkgs.writeShellScriptBin "${name}" (''
        [ -e "$XDG_CONFIG_HOME/${name}rc" ] || \
          cp "$XDG_CONFIG_HOME/${name}/${name}rc" "$XDG_CONFIG_HOME/${name}rc"
        exec -a ${kdeBin} ${kdeBin} $@
      '');
    in
    pkgs.symlinkJoin {
      pname = "${name}-cfg-wrapper";
      name  = "${name}-cfg-wrapper";
      paths = [
        kdeCfg
        pkg
      ];
    }
  );
  myKDEmount = (name: [
    (sloth.concat' sloth.xdgConfigHome "/${name}rc")
    (sloth.concat' sloth.xdgConfigHome "/${name}/${name}rc")
  ]);

  gwenviewPkg = (myKDEpkg pkgs.kdePackages.gwenview "gwenview");
in
{
  nixpak."${name}" = rec {
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
      variables = {
        QT_PLUGIN_PATH = [
          "${pkgs.kdePackages.breeze}/lib/qt-6/plugins"
          "${pkgs.kdePackages.breeze-icons}/lib/qt-6/plugins"
          "${pkgs.kdePackages.frameworkintegration}/lib/qt-6/plugins"
        ];
      };
    };

    bubblewrap = {
      bind.ro =
      [
        (myKDEmount "gwenview")
        ("/run/current-system/sw/share/icons")
      ];
      bind.rw = [
        (bindHomeDir name "/.config/copyq")
        (bindHomeDir name "/.config/GIMP")
        (bindHomeDir name "/.config/inkscape")
      ];
    };
  };
}
