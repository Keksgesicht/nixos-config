{ config, pkgs, lib, inputs
, username, home-dir, ssd-mnt
, ... }:

let
  xdgConfig = "${home-dir}/.config";
  plasma-config = (pkgs.callPackage ../packages/plasma-config.nix {});

  my-functions = (import ../nix/my-functions.nix lib);
in
with my-functions;
{
  # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html
  systemd.tmpfiles.rules =
  let
    mkSymHomeFiles = fileList: (forEach fileList (elem:
      "L+ ${home-dir}/${elem} - - - - ${ssd-mnt}${home-dir}/${elem}"
    ));
    myHomeFiles = [
      ".config/akonadi_davgroupware_resource_0rc"
      ".config/filetypesrc"
      ".config/gwenviewrc"
      ".config/kwalletrc"
      ".config/merkuro.calendarrc"
      ".config/plasma_calendar_holiday_regions"
      ".config/plasmashellrc"
      ".config/session/dolphin_dolphin_dolphin"
      ".local/share/user-places.xbel"
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
  ]
  ++ mkSymHomeFiles myHomeFiles
  ++ initPlasmaFiles
  ++ lib.optionals (config.networking.hostName == "cookieclicker")
      (placePlasmaAppletFile "tower")
  ++ lib.optionals (config.networking.hostName == "cookiethinker")
      (placePlasmaAppletFile "laptop")
  ;
}
