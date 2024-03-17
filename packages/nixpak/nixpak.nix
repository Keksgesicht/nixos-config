{ config, pkgs, lib, inputs, username, ... }:

let
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

  appFileOpts = (binName: types.submodule ({ config, ... }: {
    options = {
      src = lib.mkOption {
        type = types.str;
        default = binName;
      };
      dst = lib.mkOption {
        type = types.str;
        default = config.src;
      };
      args.extra = lib.mkOption {
        type = with types; coercedTo (listOf str) (l:
          lib.strings.concatStringsSep " " l
        ) str;
        default = "";
      };
      args.remove = lib.mkOption {
        type = types.str;
        default = "";
      };
    };
  }));
  pkgWrapOpts = types.submodule ({ config, ... }: {
    options = {
      package = lib.mkOption {
        type = types.package;
      };
      binName = lib.mkOption {
        type = types.str;
        default = config.package.name;
      };
      appFile = lib.mkOption {
        type = types.listOf (appFileOpts config.binName);
        default = [ { src = config.binName; } ];
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
            appFile = [];
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
      wrapper.printing = lib.mkOption {
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
          xdg-utils
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
                # Flatpak does this (/sys/devices), why not NixPak :/
                # https://wiki.alpinelinux.org/wiki/Bubblewrap#Basic_bwrap_setup
                # additionally to nixpak's default (/sys/devices/pci0000:00).
                # my system only needs the following (two first gen ryzen dies):
                "/sys/devices/pci0000:40"

                # POSIX compliance
                [
                  "${pkgs.bashInteractive}/bin/sh"
                  "/bin/sh"
                ]
                [
                  "${pkgs.coreutils}/bin/env"
                  "/usr/bin/env"
                ]

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
              ++ lib.optionals (value.wrapper.printing) [
                "/run/cups/cups.sock"
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
                # https://docs.flatpak.org/en/latest/portal-api-reference.html
                "org.freedesktop.portal.Desktop" = "talk";
                "org.freedesktop.portal.Documents" = "talk";
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
                    arg = arg.removeprefix("file://")
                    fpCmd = flatpakCmd + " " + arg
                    docPath = os.popen(fpCmd).read().replace('\n', "")
                    if docPath != "":
                        wrappedArgs.append(docPath)
                    elif arg != "%U":
                        wrappedArgs.append(arg)
            elif arg == "@@u":
                mark = True
            else:
                wrappedArgs.append(arg)

        os.execv(wrappedCmd, wrappedArgs)
      ''));

      appDesktopPkgs = (builtins.filter (p: p.binName != "")
        value.wrapper.packages
      );
      appDesktopCopy = (p:
      let
        pkgName = lib.getName p.package;
        newBin  = "${mkNPfileWrapper}/bin/${name}";
        deskFileEdit = (lib.lists.forEach p.appFile (af:
          let
            newExec = "${newBin} ${p.binName} ${af.args.extra}";
          in
          ''
            cp $src/share/applications/${af.src}.desktop \
               $out/share/applications/${af.dst}.desktop
            if [ "${af.args.remove}" != "" ]; then
              sed -i '/^Exec=/s/${af.args.remove}//g' \
               $out/share/applications/${af.dst}.desktop
            fi
            sed -i '/^Exec=/s/%[uU]/@@u %U @@/g' \
               $out/share/applications/${af.dst}.desktop
            sed -i '/^Exec=/s/%F/@@u %F @@/g' \
               $out/share/applications/${af.dst}.desktop
            sed -i 's|^Exec=.*${p.binName}|Exec=${newExec}|g' \
               $out/share/applications/${af.dst}.desktop
          ''
        ));
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
        ''
        + lib.strings.concatStrings deskFileEdit;
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
  ) config.nixpak)
  ++ [
    # https://forum.xfce.org/viewtopic.php?id=14926
    pkgs.d-spy
  ];
}
