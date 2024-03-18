{ config, pkgs, lib, inputs, sloth, ... }:

# https://github.com/nixpak/nixpak
let
  appDir = (name:
    sloth.concat' sloth.homeDir "/.var/app/${name}"
  );
  bindHomeDir = (name: file: [
    (sloth.mkdir (sloth.concat' (appDir name) file))
    (sloth.concat' sloth.homeDir file)
  ]);

  myKDEpkg = (pkg: name: act: ext:
    let
      kdeBin = "${pkg}/bin/${name}";
      kdeBin1 = lib.strings.head (lib.strings.splitString "-" kdeBin);
      kdeBin2 = lib.strings.removePrefix kdeBin1 kdeBin;
      kdeCfg = pkgs.writers.writePython3Bin "${name}" {
        libraries = [];
      } (''
          import os
          import sys
        ''
        + (lib.strings.concatMapStrings (e: ''
          kdeRCfile = "$XDG_CONFIG_HOME/${name}/${name}${e}rc"
          os.system("touch " + kdeRCfile)
          os.system("${act} " + kdeRCfile + " $XDG_CONFIG_HOME/${name}${e}rc")
        '') ext)
        + ''
          kdeBin = "${kdeBin1}"
          kdeBin += "${kdeBin2}"
          os.execv(kdeBin, [kdeBin] + sys.argv[1:])
        ''
      );
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
  myKDEmount = (name: ext: [
    (sloth.concat' sloth.xdgConfigHome "/${name}${ext}rc")
    (sloth.concat' sloth.xdgConfigHome "/${name}/${name}${ext}rc")
  ]);

  appCfgList = [
    ./BilderAnguck.nix
    ./Brave.nix
    ./DevShell.nix
    ./DocPDF.nix
    ./Ferdium.nix
    ./FireFox.nix
    ./GitKraken.nix
    ./LibreWolf.nix
    ./MediaPlayer.nix
    ./Mousai.nix
    ./OBS-Studio.nix
    ./Office.nix
    ./Signal.nix
    ./SIP.nix
    ./ThunderBird.nix
    ./UngoogledChromium.nix
    ./Vesktop.nix
    ./VideoEdit.nix
  ];
  appFuncList = lib.lists.forEach appCfgList (app:
    (import app {
      inherit config;
      inherit lib;
      inherit pkgs;
      inherit sloth;
      inherit appDir;
      inherit bindHomeDir;
      inherit myKDEpkg;
      inherit myKDEmount;
    })
  );
in
{
  imports = [
    (inputs.nixpak + "/modules/lib/sloth.nix")
    ./nixpak.nix
  ]
  ++ appFuncList;
}
