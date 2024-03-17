{ config, lib
, username, home-dir
, ssd-mnt, hdd-mnt, nvm-mnt, data-dir
, ... }:

let
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

  trash-dir = "${hdd-mnt}/Trash/1000";
  git-ssd-dir = "${ssd-mnt}${home-dir}/git";

  my-functions = (import ../nix/my-functions.nix lib);
in
with my-functions;
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
      device = "${git-ssd-dir}";
    };
    "${home-dir}/Module" = bind-opts // data-opts // {
      device = "${data-dir}/Documents/Studium/Module";
    };

    "${data-dir}/Documents/Gaming" = bind-opts // data-opts // {
      device = "${hdd-mnt}/homeGaming/Documents";
    };
    "${data-dir}/Pictures/Gaming" = bind-opts // data-opts // {
      device = "${hdd-mnt}/homeGaming/Pictures";
    };
    "${data-dir}/Videos/Gaming/Desktop" = bind-opts // data-opts // {
      device = "${hdd-mnt}/homeGaming/Videos/Desktop";
    };
    "${data-dir}/Videos/Gaming/sandbox" = bind-opts // data-opts // {
      device = "${hdd-mnt}/homeGaming/Videos/sandbox";
    };

    "${home-dir}/.local/share/Trash" = bind-opts // data-opts // {
      device = "${trash-dir}";
    };
    "${home-dir}/Games" = bind-opts // {
      device = "${nvm-mnt}/Games";
      depends = [
        "${nvm-mnt}"
        "${home-dir}"
      ];
    };
    "${data-dir}/Pictures/Screenshots" = bind-opts // {
      device = "${ssd-mnt}/root${home-dir}/Pictures/Screenshots";
      depends = [
        "${nvm-mnt}"
        "${data-dir}"
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
    secureHomeDir = list: (forEach list (e:
      { directory = "${e}"; user = username; group = username; mode = "0700"; }
    ));
  in
  {
    "${ssd-mnt}" = {
      hideMounts = true;
      # do not even try using the home-manager impermanence module
      users."${username}" = {
        directories = [
          ".config/dconf"
          ".config/git"
          ".config/gtk-2.0"
          ".config/gtk-3.0"
          ".config/gtk-4.0"
          ".config/kate"
          ".config/KDE"
          ".config/kde.org"
          ".config/xscreensaver"

          ".local/bin"
          ".local/share/aurorae"
          ".local/share/color-schemes"
          ".local/share/dolphin"
          ".local/share/icons"
          ".local/share/kactivitymanagerd"
          ".local/share/kate"
          ".local/share/knewstuff3"
          ".local/share/konsole"
          ".local/share/kscreen"
          ".local/share/kwin"
          ".local/share/kwrite"
          ".local/share/kxmlgui5"
          ".local/share/org.kde.syntax-highlighting"
          ".local/share/plasma"
          ".local/share/plasma-systemmonitor"
          ".local/share/themes"
          ".local/share/waydroid"
        ]
        ++ secureHomeDir [
          ".config/akonadi"
          ".config/gnupg"
          ".config/kdeconnect"
          ".config/keepassxc"
          ".config/Nextcloud"
          ".config/ssh"
          ".local/share/akonadi"
          ".local/share/akonadi-davgroupware"
          ".local/share/flatpak/db"
          ".local/share/kwalletd"
          ".secrets"
          ".tpm2_pkcs11"
          ".var/app"
        ]
        ++ usernameDir [
          ".icons"
          "background"
          "texmf"
          "WinePrefixes"
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
    secureUserDir = list: (forEach list (e:
      "d  ${e} 0700 ${username} ${username} - -"
    ));
  in
  resetUserDir [
    # overrides home-dir creation,
    # but allows SDDM to access ~/.face
    "${ssd-mnt}/root${home-dir}"

    "${ssd-mnt}/root${home-dir}/git"
    "${ssd-mnt}/root${home-dir}/Pictures"
    "${ssd-mnt}/root${home-dir}/Pictures/Screenshots"


    "${data-dir}/Documents"
    "${data-dir}/Documents/development"
    "${data-dir}/Documents/development/git"
    "${data-dir}/Documents/Studium"
    "${data-dir}/Documents/Studium/Module"

    "${home-dir}/Downloads"
    "${data-dir}/Music"
    "${data-dir}/Pictures"
    "${data-dir}/Videos"

    "${hdd-mnt}/homeGaming/Documents"
    "${hdd-mnt}/homeGaming/Pictures"
    "${hdd-mnt}/homeGaming/Videos"
    "${nvm-mnt}/Games"
  ]
  ++ secureUserDir [
    "${trash-dir}"
    "${ssd-mnt}/root${home-dir}/.cache"
    "${ssd-mnt}/root${home-dir}/.local/share"
  ] ++ [
    "L+ ${data-dir}/devel  - - - - ${data-dir}/Documents/development"
    "L+ ${data-dir}/git    - - - - ${data-dir}/Documents/development/git"
    "L+ ${data-dir}/Module - - - - ${data-dir}/Documents/Studium/Module"
  ]
  ;

  # disable home-dir create,
  # as this is done by systemd-tmpfiles now.
  users.users."${username}".createHome = lib.mkForce false;
}
