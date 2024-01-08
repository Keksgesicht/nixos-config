{ config, pkgs, lib, ... }:

let
  username = "keks";
  home-dir = "/home/${username}";
  ssd-mnt  = "/mnt/main";
  hdd-mnt  = "/mnt/array";
  link-dir = "/mnt/user";

  ssd-fs-cfg = config.fileSystems."${ssd-mnt}";
  ssd-fs-opt-str = (lib.concatStringsSep "," ssd-fs-cfg.options);
  biss = config.boot.initrd.systemd.services;
in
{
  boot.initrd.systemd = {
    storePaths = biss."setup-impermanence-root-volume".path;
    services = {
      "setup-impermanence-root-volume" = {
        description = "Setup new subvolume for /";
        unitConfig = {
          DefaultDependencies = false;
          # only exists in initrd, so this should not be needed
          #RefuseManualStart   = true;
          #RefuseManualStop    = true;
        };
        wantedBy = [ "initrd-root-device.target" ];
        after    = [ "initrd-root-device.target" ];
        before   = [ "initrd-root-fs.target" "sysroot.mount" ];
        serviceConfig = { Type = "oneshot"; };
        environment = {
          TZ = config.time.timeZone;
        };
        path = with pkgs; [
          btrfs-progs
          coreutils
          findutils
          util-linux
        ];
        script = ''
          BACKUPS_DAYS=3
          TMP_MNT="/mnt-main"
          TMP_ROOT_DIR="$TMP_MNT/root"
          BACKUP_DIR="$TMP_MNT/backup_main/boot/root"

          list_backups() {
            find $BACKUP_DIR \
              -mindepth 1 -maxdepth 1 \
              -mtime +$BACKUPS_DAYS
          }
          delete_subvolumes() {
              IFS=$'\n'
              for sv in $(btrfs subvolume list -o "$1" | cut -d' ' -f9); do
                  btrfs subvolume delete /mnt-main/$sv
              done
              btrfs subvolume delete $1
          }

          mkdir -p $TMP_MNT
          mount -t ${ssd-fs-cfg.fsType} -o ${ssd-fs-opt-str} \
            ${ssd-fs-cfg.device} $TMP_MNT

          mkdir -p $BACKUP_DIR
          back_num=$(list_backups | wc -l)
          if [ $BACKUPS_DAYS -lt "$back_num" ]; then
            for sv in $(list_backups); do
              delete_subvolumes $sv
            done
          fi
          if [ -e $TMP_ROOT_DIR ]; then
            mv $TMP_ROOT_DIR $BACKUP_DIR/$(date +%Y%m%d_%H%M%S)
          fi

          btrfs subvolume create $TMP_ROOT_DIR
          umount $TMP_MNT
          exit 0
        '';
      };
    };
  };

  fileSystems = {
    "/" = {
      device = ssd-fs-cfg.device;
      fsType = ssd-fs-cfg.fsType;
      options = [
        "subvol=root"
        "compress=zstd:3"
        "nodev"
        "nosuid"
      ];
    };
  };

  environment.persistence = {
    # only start with:
    # /etc -> /mnt/main/etc (BTRFS subvolume)
    # /var -> /mnt/main/var (BTRFS subvolume)
    "/mnt/main" = {
      hideMounts = true;
      directories = [
        "/etc/NetworkManager/system-connections"
        "/etc/nixos"
        "/etc/secureboot"
        "/etc/unCookie"
        "/var/lib/bluetooth"
        "/var/lib/containers"
        "/var/lib/flatpak"
        "/var/lib/systemd/backlight"
        "/var/lib/systemd/timers"
        "/var/lib/waydroid"
        "/var/log"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/var/cache/locatedb"
        "/var/lib/rasdaemon/ras-mc_event.db"
        "/var/nix-serve/public-key.pem"
        "/var/nix-serve/secret-key.pem"
      ];
    };

    # /root -> /mnt/main/home/root
    "/mnt/main/home" = {
      hideMounts = true;
      directories = [
        "/root/.secrets/ssh"
      ];
      files = [
        "/root/.config/ssh/known_hosts"
        "/root/.zhistory"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    # essential
    "L+ ${link-dir}/etc  - - - - ${ssd-mnt}/etc"
    "L+ ${link-dir}/home - - - - ${ssd-mnt}/home"
    "L+ ${link-dir}/var  - - - - ${ssd-mnt}/var"
    # stuff
    "L+ ${link-dir}/appdata      - - - - ${ssd-mnt}/appdata"
    "L+ ${link-dir}/appdata2     - - - - ${hdd-mnt}/appdata2"
    "L+ ${link-dir}/appdata3     - - - - /mnt/ram/appdata3"
    "L+ ${link-dir}/backup_array - - - - ${hdd-mnt}/backup_array"
    "L+ ${link-dir}/backup_main  - - - - ${ssd-mnt}/backup_main"
    "L+ ${link-dir}/Games        - - - - /mnt/ram/Games"
    "L+ ${link-dir}/homeBraunJan - - - - ${hdd-mnt}/homeBraunJan"
    "L+ ${link-dir}/homeGaming   - - - - ${hdd-mnt}/homeGaming"
    # useful subvolumes
    "q  ${ssd-mnt}/appdata      - - - - -"
    "q  ${hdd-mnt}/appdata2     - - - - -"
    "q  /mnt/ram/appdata3       - - - - -"
    "q  /mnt/ram/Games          0755 ${username} ${username} - -"
    "q  ${hdd-mnt}/homeBraunJan 0755 ${username} ${username} - -"
    "q  ${hdd-mnt}/homeGaming   0755 ${username} ${username} - -"
    # additional data
    "L+ ${link-dir}/binWin    - - - - ${ssd-mnt}/binWin"
    "L+ ${link-dir}/system    - - - - ${ssd-mnt}/system"
    "L+ ${link-dir}/resources - - - - ${hdd-mnt}/resources"
    "L+ ${link-dir}/vm        - - - - ${ssd-mnt}/vm"
    "L+ ${link-dir}/vm2       - - - - ${hdd-mnt}/vm2"

    # suppress warning/info after every reboot
    "f+ /var/db/sudo/lectured/1000 - - - - -"
  ];
}
