{ config, pkgs, lib, inputs, sloth, username, ... }:

let
  toplevelConfig = config;
  inherit (lib) types;

  # https://github.com/nixpak/nixpak
  mkNixPak = inputs.nixpak.lib.nixpak {
    inherit (pkgs) lib;
    inherit pkgs;
  };

  npPrefix = "com.nixpak";
  strFunc = lib.strings;
  mapAL = lib.attrsets.mapAttrsToList;
  writePyBin = pkgs.writers.writePython3Bin;

  pkgWrapOpts = types.submodule ({ config, ... }: {
    options = {
      package = lib.mkOption {
        type = types.package;
      };
      binName = lib.mkOption {
        type = types.str;
        default = config.package.name;
      };
      appFileSrc = lib.mkOption {
        type = types.str;
        default = config.binName;
      };
      appFileDst = lib.mkOption {
        type = types.str;
        default = config.appFileSrc;
      };
      extraParams = lib.mkOption {
        type = types.str;
        default = "";
      };
      delParams = lib.mkOption {
        type = types.str;
        default = "";
      };
    };
  });

  nixpakOpts = { name, config, ... }: {
    options = {
      wrapper.packages = lib.mkOption {
        type = types.listOf (
          types.coercedTo types.package (p: {
            package = p;
            binName = "";
            appFileSrc = "";
            appFileDst = "";
          }) pkgWrapOpts
        );
        default = [];
      };
      wrapper.variables = lib.mkOption {
        default = {};
        type = with types; attrsOf (oneOf [ (listOf str) str path ]);
        apply = lib.attrsets.mapAttrs (n: v:
          if lib.isList v then
            lib.strings.concatStringsSep ":" v
          else "${v}"
        );
      };
      wrapper.xdg-portal = lib.mkOption {
        type = types.bool;
        default = true;
      };
      wrapper.audio = lib.mkOption {
        type = types.bool;
        default = false;
      };
      wrapper.time = lib.mkOption {
        type = types.bool;
        default = false;
      };
      output.script = lib.mkOption {
        description = "The final wrapper script.";
        internal = true;
        readOnly = true;
        type = types.package;
      };
      output.env = lib.mkOption {
        description = "App wrapper script replacing the regular binary.";
        internal = true;
        readOnly = true;
        type = types.package;
      };
      app = lib.mkOption {
        type = types.attrs;
        default = {};
      };
      bubblewrap = lib.mkOption {
        type = types.attrs;
        default = {};
      };
      dbus = lib.mkOption {
        type = types.attrs;
        default = {};
      };
      etc = lib.mkOption {
        type = types.attrs;
        default = {};
      };
      flatpak = lib.mkOption {
        type = types.attrs;
        default = {};
      };
    };

    # enable merging with defaults
    config = {
      wrapper = {
        packages = with pkgs; [
          zsh bash
          coreutils gawk ncurses
          bat eza gnugrep
        ];
        variables = {
          PATH = lib.lists.forEach config.wrapper.packages (p:
            "${p.package}/bin"
          );
        };
      };
      output.env    = (mkNixPakPkg name config "env");
      output.script = (mkNixPakPkg name config "script");
      bubblewrap = {
        network = false;
      };
    };
  };

  mkNixPakPkg = (name: value: out:
    let
      wrapVariables = lib.strings.concatStringsSep "\n" (
        lib.attrsets.mapAttrsToList (name: value:
          "export ${name}=${value}"
        ) value.wrapper.variables
      ) + "\n";
      wrapExec = ''
        truncate -s 0 ~/.zshrc
        exec -a $1 $@
      '';
      wrapNPscript = pkgs.writeShellScriptBin "${name}-ns-exec" (
        wrapVariables + wrapExec
      );

      np = mkNixPak {
        config = { sloth, ... }: {
          app = lib.mkMerge [
            ({
              package = lib.mkDefault wrapNPscript;
              binPath = lib.mkDefault "bin/${name}-ns-exec";
            })
            value.app
          ];

          bubblewrap = lib.mkMerge [
            ({
              bind.ro = [
                "/etc/fonts"
                "/etc/zinputrc"
                "/etc/zshenv"
                "/etc/zshrc"
                "/etc/zshrc.local"

                (sloth.mkdir "/tmp/flatpak-shared")

                (sloth.concat' sloth.xdgConfigHome "/gtkrc")
                (sloth.concat' sloth.xdgConfigHome "/gtkrc-2.0")
                (sloth.concat' sloth.xdgConfigHome "/kdeglobals")
                (sloth.concat' sloth.xdgConfigHome "/gtk-2.0")
                (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
                (sloth.concat' sloth.xdgConfigHome "/gtk-4.0")

                (sloth.concat' sloth.xdgDataHome "/color-schemes")
                (sloth.concat' sloth.xdgDataHome "/fonts")
                (sloth.concat' sloth.xdgDataHome "/icons")
                (sloth.concat' sloth.xdgDataHome "/themes")
              ]
              ++ lib.optionals (value.wrapper.time) [
                "/etc/localtime"
                [
                  "${pkgs.tzdata}/share/zoneinfo"
                  "/usr/share/zoneinfo"
                ]
              ];
              bind.rw = [
                [
                  (sloth.mkdir (
                    sloth.concat' sloth.homeDir "/.var/home/${name}"
                  ))
                  (sloth.homeDir)
                ]
              ]
              ++ lib.optionals (value.wrapper.xdg-portal) [
                [
                  (sloth.concat [
                    sloth.runtimeDir
                    "/doc/by-app/${npPrefix}.${name}"
                  ])
                  (sloth.concat' sloth.runtimeDir "/doc")
                ]
              ];
              sockets = {
                wayland = lib.mkDefault true;
                x11     = lib.mkDefault false;
                pipewire = lib.mkDefault value.wrapper.audio;
                pulse    = lib.mkDefault value.wrapper.audio;
              };
            })
            value.bubblewrap
          ];

          dbus = lib.mkMerge [
            ({
              enable = lib.mkDefault value.wrapper.xdg-portal;
              policies = lib.mkIf (value.wrapper.xdg-portal) {
                "org.freedesktop.portal.Desktop" = "talk";
                "org.freedesktop.portal.Documents" = "talk";
                "org.freedesktop.portal.FileChooser" = "talk";
              };
            })
            value.dbus
          ];

          etc = lib.mkMerge [
            ({
              sslCertificates.enable = lib.mkDefault value.bubblewrap.network;
            })
            value.etc
          ];

          flatpak = lib.mkMerge [
            ({
              appId = "com.nixpak.${name}";
            })
            value.flatpak
          ];
        };
      };

      npOut = np.config."${out}";
      npOut1 = strFunc.head (strFunc.splitString "-" npOut);
      npOut2 = strFunc.removePrefix npOut1 npOut;
      mkNPfileWrapper = (writePyBin "${name}" {
        libraries = [];
      } (''
        import sys
        import os

        if len(sys.argv) <= 1:
            sys.exit(1)

        flatpakCmd = "${pkgs.flatpak}"
        flatpakCmd += "/bin/flatpak document-export"
        flatpakCmd += " --app=${npPrefix}.${name}"
        wrappedCmd = "${npOut1}"
        wrappedCmd += "${npOut2}"
        wrappedCmd += "/bin/${name}-ns-exec"
        wrappedArgs = [wrappedCmd, sys.argv[1]]

        mark = False
        for arg in sys.argv[2:]:
            if mark:
                if arg == "@@":
                    mark = False
                else:
                    fpCmd = flatpakCmd + " " + arg
                    docPath = os.popen(fpCmd).read().replace('\n', "")
                    if docPath != "":
                        wrappedArgs.append(docPath)
                    elif arg != "%u":
                        wrappedArgs.append(arg)
            elif arg == "@@u":
                mark = True
            else:
                wrappedArgs.append(arg)

        os.execv(wrappedCmd, wrappedArgs)
      ''));

      appDesktopPkgs = (builtins.filter (p: p.appFileSrc != "")
        value.wrapper.packages
      );
      appDesktopCopy = (p:
      let
        pkgName = lib.getName p.package;
        newExec = "${mkNPfileWrapper}/bin/${name} ${p.binName} ${p.extraParams}";
      in
      pkgs.stdenv.mkDerivation {
        name = "${name}-${pkgName}-desktop-file";
        src = p.package;
        installPhase = ''
          mkdir -p $out/share/applications
          mkdir -p $out/share/icons

          if [ -d $src/share/icons ]; then
            cp -r $src/share/icons/. $out/share/icons/
          fi

          cp $src/share/applications/${p.appFileSrc}.desktop \
             $out/share/applications/${p.appFileDst}.desktop
          if [ "${p.delParams}" != "" ]; then
            sed -i '/^Exec=/s/${p.delParams}//g' \
             $out/share/applications/${p.appFileDst}.desktop
          fi
          sed -i '/^Exec=/s/%[uU]/@@u %U @@/g' \
             $out/share/applications/${p.appFileDst}.desktop
          sed -i 's|^Exec=.*${p.binName}|Exec=${newExec}|g' \
             $out/share/applications/${p.appFileDst}.desktop
        '';
      });
      appDesktopList = lib.lists.forEach appDesktopPkgs (p: appDesktopCopy p);
    in
    pkgs.symlinkJoin {
      pname = "${name}";
      name  = "${name}";
      paths = [ mkNPfileWrapper ] ++ appDesktopList;
    }
  );
in
{
  options.nixpak = lib.mkOption {
    default = {};
    type = with types; attrsOf (submodule nixpakOpts);
    description = lib.mdDoc ''
      Create sandboxed applications and include them into your users session.
    '';
  };

  config.users.users."${username}".packages = (mapAL (name: value:
    value.output.env
  ) config.nixpak);
}
