{ config, pkgs, ... }:

let
  username = "keks";
  home-dir = "/home/${username}";
  ssd-mnt  = "/mnt/main";
  hdd-mnt  = "/mnt/array";
  data-dir = "${hdd-mnt}/homeBraunJan";
  bind-opt = [
    "bind"
    "nofail"
    "x-gvfs-hide"
  ];

  bind-opts = {
    fsType = "none";
    options = bind-opt;
  };
  data-opts = {
    depends = [
      "${hdd-mnt}"
      "${home-dir}"
    ];
  };
in
{
  fileSystems = {
    "${home-dir}/Documents" = bind-opts // data-opts // {
      device = "${data-dir}/Documents";
    };
    "${home-dir}/Downloads" = bind-opts // data-opts // {
      device = "${data-dir}/Downloads";
    };
    "${home-dir}/Music" = bind-opts // data-opts // {
      device = "${data-dir}/Music";
    };
    "${home-dir}/Pictures" = bind-opts // data-opts // {
      device = "${data-dir}/Pictures";
    };
    "${home-dir}/Videos" = bind-opts // data-opts // {
      device = "${data-dir}/Videos";
    };

    "${home-dir}/devel" = bind-opts // data-opts // {
      device = "${data-dir}/Documents/development";
    };
    "${home-dir}/git/hdd" = bind-opts // data-opts // {
      device = "${data-dir}/Documents/development/git";
    };
    "${home-dir}/git/ssd" = bind-opts // data-opts // {
      device = "${ssd-mnt}${home-dir}/git";
    };
    "${home-dir}/Module" = bind-opts // data-opts // {
      device = "${data-dir}/Documents/Studium/Module";
    };
    "${home-dir}/Games" = bind-opts // {
      depends = [
        "/mnt/ram"
        "${home-dir}"
      ];
      device = "/mnt/ram/Games";
    };

    "${home-dir}/.local/share/Trash" = data-opts // {
      device = "${hdd-mnt}/Trash/1000";
      fsType = "none";
      options = bind-opt ++ [
        "uid=${username}"
        "gid=${username}"
      ];
    };
  };

  # do not even try using the home-manager impermanence module
  environment.persistence = {
    "${ssd-mnt}" = {
      hideMounts = true;
      users."keks" = {
        directories = [
          ".config/akonadi"
          ".config/dconf"
          ".config/git"
          { directory = ".config/gnupg"; user = username; group = username; mode = "0700"; }
          ".config/gtk-2.0"
          ".config/gtk-3.0"
          ".config/gtk-4.0"
          ".config/htop"
          ".config/KDE"
          ".config/kde.org"
          ".config/kdeconnect"
          ".config/keepassxc"
          ".config/libaccounts-glib"
          ".config/Nextcloud"
          ".config/plasma-workspace"
          { directory = ".config/ssh"; user = username; group = username; mode = "0700"; }
          ".config/xscreensaver"
          ".config/xsettingsd"

          ".local/bin"
          ".local/share/akonadi"
          ".local/share/akonadi-davgroupware"
          ".local/share/akonadi_davgroupware_resource_0"
          ".local/share/akonadi_migration_agent"
          ".local/share/applications"
          ".local/share/baloo"
          ".local/share/color-schemes"
          ".local/share/containers"
          ".local/share/dolphin"
          ".local/share/flatpak/db"
          ".local/share/icons"
          ".local/share/kactivitymanagerd"
          ".local/share/kate"
          ".local/share/knewstuff3"
          ".local/share/konsole"
          ".local/share/kscreen"
          ".local/share/kwalletd"
          ".local/share/kwin"
          ".local/share/kwrite"
          ".local/share/kxmlgui5"
          ".local/share/Nextcloud"
          ".local/share/nix-cage"
          ".local/share/org.kde.syntax-highlighting"
          ".local/share/plasma"
          ".local/share/plasma-systemmonitor"
          ".local/share/systemd/timers"
          ".local/share/themes"
          ".local/share/waydroid"

          ".icons"
          { directory = ".local/state/wireplumber"; user = username; group = username; }
          { directory = ".secrets"; mode = "0700"; }
          { directory = ".tpm2_pkcs11"; mode = "0700"; }
          ".var/app"
          "background"
          "texmf"
          "WinePrefixes"
        ];
        files = [
          ".config/akonadi_davgroupware_resource_0rc"
          ".config/filetypesrc"
          ".config/gwenviewrc"
          ".config/kactivitymanagerd-statsrc"
          ".config/katemoderc"
          ".config/katerc"
          ".config/katesyntaxhighlightingrc"
          ".config/katevirc"
          ".config/kcminputrc"
          ".config/kdeglobals"
          ".config/kscreenlockerrc"
          ".config/kwalletrc"
          ".config/kwinrc"
          ".config/kwinrulesrc"
          ".config/kwriterc"
          ".config/merkuro.calendarrc"
          ".config/mimeapps.list"
          ".config/plasmashellrc"
          ".config/plasma-org.kde.plasma.desktop-appletsrc"
          ".config/plasma_calendar_holiday_regions"
          { file = ".config/session/dolphin_dolphin_dolphin";
            parentDirectory = { user = username; group = username; }; }

          ".local/share/face.png"
          ".local/share/krunnerstaterc"
          ".local/share/user-places.xbel"
        ];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "L+ ${home-dir}/.face                     - - - - .local/share/face.png"
    "L+ ${home-dir}/.face.icon                - - - - .face"
    "f+ ${home-dir}/.sudo_as_admin_successful - - - - -"
    "L+ ${home-dir}/.xscreensaver             - - - - .config/xscreensaver/config"
    "f+ ${home-dir}/.zshrc                    - - - - -"
  ];
}
