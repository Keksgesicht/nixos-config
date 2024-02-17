{ config, pkgs, lib, inputs
, username, home-dir, ssd-mnt
, ... }:

let
  xdgConfig = "${home-dir}/.config";
  xdgState = "${home-dir}/.local/state";

  my-audio = (pkgs.callPackage ../packages/my-audio.nix {});
  secrets-pkg = (pkgs.callPackage ../packages/my-secrets.nix {});
  plasma-config = (pkgs.callPackage ../packages/plasma-config.nix {});

  my-functions = (import ../nix/my-functions.nix lib);
in
with my-functions;
{
  environment.etc = {
    "flake-output/my-secrets" = {
      source = secrets-pkg;
    };
  };

  # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html
  systemd.tmpfiles.rules =
  let
    mkSymHomeFiles = fileList: (forEach fileList (elem:
      "L+ ${home-dir}/${elem} - - - - ${ssd-mnt}${home-dir}/${elem}"
    ));
    myHomeFiles = [
      ".config/session/dolphin_dolphin_dolphin"
    ];

    initPlasmaFiles = flatList (forEach (listFilesRec plasma-config) (e:
      let
        eFile = lib.removePrefix "${plasma-config}/" e;
      in
      [
        "C  ${xdgConfig}/${eFile} - - - - ${e}"
        "Z  ${xdgConfig}/${eFile} 0644 ${username} ${username} - -"
      ]
    ));
    initSecretFiles = flatList (forEach (listFilesRec "${secrets-pkg}/linux-root/home") (e:
      let
        eFile = lib.removePrefix "${secrets-pkg}/linux-root/home/" e;
      in
      [
        "C  ${home-dir}/${eFile} - - - - ${e}"
        "Z  ${home-dir}/${eFile} 0644 ${username} ${username} - -"
      ]
    ));
    initWireplumberState = flatList (forEach (listFilesRec "${my-audio}/state") (e:
      let
        eFile = lib.removePrefix "${my-audio}/state/" e;
      in
      [
        "C  ${xdgState}/wireplumber/${eFile} - - - - ${e}"
        "Z  ${xdgState}/wireplumber/${eFile} 0644 ${username} ${username} - -"
      ]
    ));

    appletFile = "${xdgConfig}/plasma-org.kde.plasma.desktop-appletsrc";
    appletSrcPrefix = "${plasma-config}/plasma-desktop-appletsrc";
    placePlasmaAppletFile = name: [
      "C  ${appletFile} - - - - ${appletSrcPrefix}.${name}"
      "Z  ${appletFile} 0644 ${username} ${username} - -"
    ];
  in
  [
    "L+ ${home-dir}/.face                     - - - - ${inputs.self}/files/face.png"
    "L+ ${home-dir}/.face.icon                - - - - .face"
    "f+ ${home-dir}/.sudo_as_admin_successful - - - - -"
    "L+ ${home-dir}/.xscreensaver             - - - - .config/xscreensaver/config"
    "L+ ${home-dir}/.zhistory                 - - - - ${ssd-mnt}${home-dir}/.zhistory"
    "f+ ${home-dir}/.zshrc                    - - - - -"
  ] ++ [
    "d  ${home-dir}/.config/session - ${username} ${username} - -"
    "d  ${xdgState}              0700 ${username} ${username} - -"
    "d  ${xdgState}/wireplumber     - ${username} ${username} - -"
  ]
  ++ mkSymHomeFiles myHomeFiles
  ++ initPlasmaFiles
  ++ initSecretFiles
  ++ initWireplumberState
  ++ lib.optionals (config.networking.hostName == "cookieclicker")
      (placePlasmaAppletFile "tower")
  ++ lib.optionals (config.networking.hostName == "cookiethinker")
      (placePlasmaAppletFile "laptop")
  ;
}
