{ config, lib, ... }:

let
  username = "keks";
  home-dir = "/home/${username}";
  ssd-mnt  = "/mnt/main";
  hdd-mnt  = "/mnt/array";
  data-dir = "${hdd-mnt}/homeBraunJan";

  forEach  = lib.lists.forEach;
  flatList = lib.lists.flatten;

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

    "${data-dir}/Documents/Gaming" = bind-opts // data-opts // {
      device = "${hdd-mnt}/homeGaming/Documents";
    };
    "${data-dir}/Videos/Gaming/Desktop" = bind-opts // data-opts // {
      device = "${hdd-mnt}/homeGaming/Videos/Desktop";
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

  # https://nixos.wiki/wiki/Impermanence#Home_Managing
  # https://github.com/nix-community/impermanence
  environment.persistence =
  let
    usernameDir = list: (forEach list (e:
      { directory = "${e}"; user = username; group = username; }
    ));
  in
  {
    "${ssd-mnt}" = {
      hideMounts = true;
      # do not even try using the home-manager impermanence module
      users."${username}" = {
        directories = [
          ".config/akonadi"
          ".config/dconf"
          ".config/git"
          { directory = ".config/gnupg"; user = username; group = username; mode = "0700"; }
          ".config/gtk-2.0"
          ".config/gtk-3.0"
          ".config/gtk-4.0"
          ".config/KDE"
          ".config/kde.org"
          ".config/kdeconnect"
          ".config/keepassxc"
          ".config/libaccounts-glib"
          ".config/Nextcloud"
          { directory = ".config/ssh"; user = username; group = username; mode = "0700"; }
          ".config/xscreensaver"

          ".local/bin"
          ".local/share/akonadi"
          ".local/share/akonadi-davgroupware"
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

          { directory = ".secrets";     user = username; group = username; mode = "0700"; }
          { directory = ".tpm2_pkcs11"; user = username; group = username; mode = "0700"; }
        ]
        ++ usernameDir [
          ".icons"
          ".local/state/wireplumber"
          ".var/app"
          "background"
          "texmf"
          "WinePrefixes"
        ];
      };
    };
    # exclude impermant directories inside permant directories from persistence
    "${ssd-mnt}/root" = {
      hideMounts = true;
      # do not even try using the home-manager impermanence module
      users."${username}" = {
        directories = usernameDir [
          "Pictures/Screenshots"
        ];
      };
    };
  };

  # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html
  systemd.tmpfiles.rules =
  let
    resetUserDir = list: (flatList (forEach list (e:
      [
        "d  ${e} 0755 ${username} ${username} - -"
        "z  ${e} 0755 ${username} ${username} - -"
      ]
    )));
  in
  [
    "L+ ${data-dir}/devel  - - - - ${data-dir}/Documents/development"
    "L+ ${data-dir}/git    - - - - ${data-dir}/Documents/development/git"
    "L+ ${data-dir}/Module - - - - ${data-dir}/Documents/Studium/Module"
  ]
  ++ resetUserDir [
    "${data-dir}/Documents"
    "${home-dir}/Downloads"
    "${data-dir}/Music"
    "${data-dir}/Pictures"
    "${data-dir}/Videos"
    "${hdd-mnt}/Trash/1000"

    "${ssd-mnt}${home-dir}/git"
    "${data-dir}/Documents/development/git"
    "${data-dir}/Documents/Studium/Module"

    "${hdd-mnt}/homeGaming/Documents"
    "${hdd-mnt}/homeGaming/Videos"
    "${hdd-mnt}/homeGaming/Videos/Desktop"
    "/mnt/ram/Games"
  ];
}
