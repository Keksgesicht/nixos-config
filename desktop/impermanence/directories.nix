{ self, config, lib, username, home-dir, ssd-mnt, hdd-mnt, ... }:

let
  kexPaths = config.KexOS.paths;
  inherit (config.KexOS.variables) data-dir;

  bind-opt = [ "bind" "nofail" "x-gvfs-hide" ];
  bind-opts = {
    fsType = "none";
    options = bind-opt;
  };
  data-opts = { depends = [ hdd-mnt home-dir ]; };
  bind-data = (path: bind-opts // data-opts // {
    device = "${data-dir}/${path}";
  });
  bind-gaming = (path: bind-opts // data-opts // {
    device = "${hdd-mnt}/homeGaming/${path}";
  });

  trash-dir = "${hdd-mnt}/Trash/1000";

  my-functions = (import "${self}/nix/my-functions.nix" lib);
in
with my-functions;
{
  fileSystems = {
    # Documents
    "${home-dir}/Documents" = bind-data "Documents";
    "${home-dir}/Music"     = bind-data "Music";
    "${home-dir}/Pictures"  = bind-data "Pictures";
    "${home-dir}/Videos"    = bind-data "Videos";

    # Development
    "${home-dir}/devel"   = bind-data "Documents/development";
    "${home-dir}/git/hdd" = bind-data "Documents/development/git";
    "${home-dir}/git/ssd" = bind-opts // {
      depends = [ home-dir ssd-mnt ];
      device = "${ssd-mnt}${home-dir}/git";
    };

    # Gaming
    "${data-dir}/Documents/Gaming"      = bind-gaming "Documents";
    "${data-dir}/Pictures/Gaming"       = bind-gaming "Pictures";
    "${data-dir}/Videos/Gaming/Desktop" = bind-gaming "Videos/Desktop";
    "${data-dir}/Videos/Gaming/sandbox" = bind-gaming "Videos/sandbox";

    # Miscellaneous
    "${home-dir}/.local/share/Trash" = bind-opts // data-opts // {
      device = trash-dir;
    };
    "${data-dir}/Pictures/Screenshots" = bind-opts // {
      device = "${ssd-mnt}/root${home-dir}/Pictures/Screenshots";
      depends = [ ssd-mnt data-dir ];
    };
    "${data-dir}/Videos/Screencasts" = bind-opts // {
      device = "${ssd-mnt}/root${home-dir}/Videos/Screencasts";
      depends = [ ssd-mnt data-dir ];
    };
    "${home-dir}/Module" = bind-data "Documents/Studium/Module";
  } // {}; # SDDM theming

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
    # /home/keks -> /mnt/main/home/keks
    "${ssd-mnt}" = {
      hideMounts = true;
      # do not even try using the home-manager impermanence module
      users."${username}" = {
        directories = [
          ".config/git"
          ".config/gtk-2.0"
          ".config/gtk-3.0"
          ".config/gtk-4.0"
          ".config/kate"
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
          ".local/share/kwin"
          ".local/share/kxmlgui5"
          ".local/share/plasma"
          ".local/share/plasma-systemmonitor"
          ".local/share/systemd/timers"
          ".local/share/themes"
          ".local/share/waydroid"
        ]
        ++ secureHomeDir [
          ".config/akonadi"
          ".config/AusweisApp"
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
          "background"
          "texmf"
        ];
      };
    };

    # /root -> /mnt/main/home/root
    "${ssd-mnt}/home" = {
      hideMounts = true;
      directories = [
        "/root/.config/ssh"
        "/root/.secrets/ssh"
      ];
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
  in [
  ] ++ resetUserDir [
    "${ssd-mnt}/root${home-dir}/git"
    "${ssd-mnt}/root${home-dir}/Pictures"
    "${ssd-mnt}/root${home-dir}/Pictures/Screenshots"
    "${ssd-mnt}/root${home-dir}/Videos"
    "${ssd-mnt}/root${home-dir}/Videos/Screencasts"

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
  ] ++ secureUserDir [
    "${trash-dir}"
    "${ssd-mnt}/root/root/.cache"
    "${ssd-mnt}/root/root/.cache/ssh"
    "${ssd-mnt}/root/root/.cache/ssh/sockets"
    "${ssd-mnt}/root${home-dir}/.cache"
    "${ssd-mnt}/root${home-dir}/.cache/ssh"
    "${ssd-mnt}/root${home-dir}/.cache/ssh/sockets"
    "${ssd-mnt}/root${home-dir}/.cache/thumbnails"
    "${ssd-mnt}/root${home-dir}/.local/share"
  ] ++ [
    "L+ ${data-dir}/devel  - - - - ${data-dir}/Documents/development"
    "L+ ${data-dir}/git    - - - - ${data-dir}/Documents/development/git"
    "L+ ${data-dir}/Module - - - - ${data-dir}/Documents/Studium/Module"
    "L+ ${kexPaths.nixCfgHomeLink} - - - - ${kexPaths.nixCfgDataDir}"
  ];
}
