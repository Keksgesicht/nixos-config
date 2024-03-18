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
      kdeCfg = pkgs.writeShellScriptBin "${name}" (
        (lib.strings.concatMapStrings (e: ''
          touch  $XDG_CONFIG_HOME/${name}/${name}${e}rc
          ${act} $XDG_CONFIG_HOME/${name}/${name}${e}rc \
                 $XDG_CONFIG_HOME/${name}${e}rc
        '') ext)
        + ''
          exec -a ${kdeBin} ${kdeBin} $@
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
    ./DocPDF.nix
    ./Ferdium.nix
    ./FireFox.nix
    ./GitKraken.nix
    ./LibreWolf.nix
    ./MediaPlayer.nix
    ./Mousai.nix
    ./OBS-Studio.nix
    ./Office.nix
    ./Shell.nix
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
