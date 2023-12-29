{ config, pkgs, lib, ... }:

let
  username = "keks";
  home-dir = "/home/${username}";
  xdgConfig = "${home-dir}/.config";
  ssd-mnt  = "/mnt/main";

  fs = lib.filesystem;
  forEach = lib.lists.forEach;
  flatList = lib.lists.flatten;
  listFilesRec = fs.listFilesRecursive;

  plasma-config = (pkgs.callPackage ../packages/plasma-config.nix {});
in
{
  # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html
  systemd.tmpfiles.rules =
  let
    mkSymHomeFiles = fileList: (lib.lists.forEach fileList (elem:
      "L+ ${home-dir}/${elem} - - - - ${ssd-mnt}${home-dir}/${elem}"
    ));
    myHomeFiles = [
      ".config/akonadi-firstrunrc"
      ".config/akonadi_akonotes_resource_0rc"
      ".config/akonadi_contacts_resource_0rc"
      ".config/akonadi_davgroupware_resource_0rc"
      ".config/akonadi_ical_resource_0rc"
      ".config/akonadi_indexing_agentrc"
      ".config/akonadi_maildir_resource_0rc"

      ".config/filetypesrc"
      ".config/gwenviewrc"
      ".config/kactivitymanagerd-statsrc"
      ".config/katemoderc"
      ".config/katerc"
      ".config/katesyntaxhighlightingrc"
      ".config/katevirc"
      ".config/kwalletrc"
      ".config/kwriterc"
      ".config/merkuro.calendarrc"
      ".config/mimeapps.list"
      ".config/plasma-org.kde.plasma.desktop-appletsrc"
      ".config/plasma_calendar_holiday_regions"
      ".config/plasmashellrc"
      ".config/session/dolphin_dolphin_dolphin"

      ".local/share/face.png"
      ".local/share/user-places.xbel"
    ];
    initPlasmaFiles = flatList (forEach (listFilesRec plasma-config) (e:
      let
        eFile = builtins.replaceStrings [ "${plasma-config}/" ] [ "" ] e;
      in
      [
        "C  ${xdgConfig}/${eFile} - - - - ${e}"
        "Z  ${xdgConfig}/${eFile} 0644 ${username} ${username} - -"
      ]
    ));
  in
  [
    "L+ ${home-dir}/.face                     - - - - .local/share/face.png"
    "L+ ${home-dir}/.face.icon                - - - - .face"
    "f+ ${home-dir}/.sudo_as_admin_successful - - - - -"
    "L+ ${home-dir}/.xscreensaver             - - - - .config/xscreensaver/config"
    "f+ ${home-dir}/.zshrc                    - - - - -"
  ] ++ [
    "d  ${home-dir}/.config/session - ${username} ${username} - -"
  ]
  ++ mkSymHomeFiles myHomeFiles
  ++ initPlasmaFiles
  ;
}
