{ config, pkgs, inputs, ... }:

let
  impermanence = inputs.impermanence;

  username = "keks";
  home-dir = "/home/${username}";
  ssd-mnt  = "/mnt/main";
  hdd-mnt  = "/mnt/array";
  data-dir = "${hdd-mnt}/homeBraunJan";

  bind-opts = {
    fsType = "none";
    options = [
      "bind"
      "nofail"
      "x-gvfs-hide"
    ];
  };
  data-opts = {
    depends = [
      "${hdd-mnt}"
      "${home-dir}"
    ];
  };
in
{
  systemd.services = {
    "setup-volume@home-keks" = {
      description = "Setup new subvolume for ${home-dir}";
      unitConfig = { DefaultDependencies = "no"; };
      wantedBy = [ "mnt-main.mount" ];
      after    = [ "mnt-main.mount" ];
      before   = [ "home-keks.mount" ];
      path = with pkgs; [
        btrfs-progs
        util-linux
      ];
      script = ''
        mountpoint ${home-dir} && exit 0
        TMP_HOME_DIR="${ssd-mnt}/home.tmp"
        BACKUP_DIR="${ssd-mnt}/backup_main/boot/home-keks"

        mkdir -p $TMP_HOME_DIR
        mkdir -p $BACKUP_DIR
        find $BACKUP_DIR -mindepth 1 -maxdepth 1 -mtime +2 -exec \
          btrfs subvolume delete {} \;
        [ -e $TMP_HOME_DIR/keks ] && \
          mv $TMP_HOME_DIR/keks $BACKUP_DIR/$(date +%Y%m%d_%H%M%S)

        btrfs subvolume create $TMP_HOME_DIR/keks
        chown ${username}:${username} $TMP_HOME_DIR/keks
        chmod 700 $TMP_HOME_DIR/keks
      '';
    };
  };

  fileSystems = {
    "${home-dir}" = {
      device = config.fileSystems."/mnt/main".device;
      fsType = "btrfs";
      options = [
        "subvol=home.tmp/keks"
        "compress=zstd:3"
        "nodev"
        "noexec"
        "nosuid"
      ];
    };

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
  };

  # do not even try using the home-manager impermanence module
  environment.persistence = {
    "${ssd-mnt}" = {
      hideMounts = true;
      users."keks" = {
        directories = [
          ".cache"
          ".config"
          ".icons"
          ".local/bin"
          ".local/share"
          { directory = ".local/state/wireplumber"; user = username; group = username; }
          { directory = ".secrets"; mode = "0700"; }
          { directory = ".tpm2_pkcs11"; mode = "0700"; }
          ".var/app"
          "background"
          "texmf"
          "WinePrefixes"
        ];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "L+ ${home-dir}/.face.icon                - - - - .face"
    "f+ ${home-dir}/.sudo_as_admin_successful - - - - -"
    "f+ ${home-dir}/.zshrc                    - - - - -"

    # the persist file mount units do not wait for home-keks.mount
    "L+ ${home-dir}/.face           - - - - ${ssd-mnt}${home-dir}/.face"
    "L+ ${home-dir}/.gtkrc-2.0      - - - - ${ssd-mnt}${home-dir}/.gtkrc-2.0"
    "L+ ${home-dir}/.gtkrc-2.0-kde4 - - - - ${ssd-mnt}${home-dir}/.gtkrc-2.0-kde4"
    "L+ ${home-dir}/.xscreensaver   - - - - ${ssd-mnt}${home-dir}/.xscreensaver"
  ];
}
