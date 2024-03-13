{ pkgs, lib, inputs, sloth, ... }:

# https://github.com/nixpak/nixpak
let
  appDir = (name:
    sloth.concat' sloth.homeDir "/.var/app/${name}"
  );
  bindHomeDir = (name: file: [
    (sloth.mkdir (sloth.concat' (appDir name) file))
    (sloth.concat' sloth.homeDir file)
  ]);

  appCfgList = [
    ./Brave.nix
    ./Ferdium.nix
    ./FireFox.nix
    ./GitKraken.nix
    ./LibreWolf.nix
    ./Office.nix
    ./Signal.nix
    ./ThunderBird.nix
    ./UngoogledChromium.nix
  ];
  appFuncList = lib.lists.forEach appCfgList (app:
    (import app {
      inherit pkgs;
      inherit sloth;
      inherit appDir;
      inherit bindHomeDir;
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
