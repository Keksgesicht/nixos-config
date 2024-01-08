{ config, pkgs, lib, ... }:

let
  ssd-mnt = "/mnt/main";
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
          TMP_MNT="/mnt-main"
          TMP_ROOT_DIR="$TMP_MNT/root"
          BACKUP_DIR="$TMP_MNT/backup_main/boot/root"

          mkdir -p $TMP_MNT
          mount -t ${ssd-fs-cfg.fsType} -o ${ssd-fs-opt-str} \
            ${ssd-fs-cfg.device} $TMP_MNT

          delete_subvolumes() {
              IFS=$'\n'
              for sv in $(btrfs subvolume list -o "$1" | cut -d' ' -f9); do
                  btrfs subvolume delete /mnt-main/$sv
              done
              btrfs subvolume delete $1
          }
          mkdir -p $BACKUP_DIR
          for sv in $(find $BACKUP_DIR -mindepth 1 -maxdepth 1 -mtime +2); do
            delete_subvolumes $sv
          done
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
    "L+ /mnt/user/etc          - - - - /mnt/main/etc"
    "L+ /mnt/user/home         - - - - /mnt/main/home"
    "L+ /mnt/user/var          - - - - /mnt/main/var"
    # stuff
    "L+ /mnt/user/appdata      - - - - /mnt/main/appdata"
    "L+ /mnt/user/appdata2     - - - - /mnt/array/appdata2"
    "L+ /mnt/user/appdata3     - - - - /mnt/ram/appdata3"
    "L+ /mnt/user/backup_array - - - - /mnt/array/backup_array"
    "L+ /mnt/user/backup_main  - - - - /mnt/main/backup_main"
    "L+ /mnt/user/Games        - - - - /mnt/ram/Games"
    "L+ /mnt/user/homeBraunJan - - - - /mnt/array/homeBraunJan"
    "L+ /mnt/user/homeGaming   - - - - /mnt/array/homeGaming"
    # additional data
    "L+ /mnt/user/binWin       - - - - /mnt/main/binWin"
    "L+ /mnt/user/system       - - - - /mnt/main/system"
    "L+ /mnt/user/resources    - - - - /mnt/array/resources"
    "L+ /mnt/user/vm           - - - - /mnt/main/vm"
    "L+ /mnt/user/vm2          - - - - /mnt/array/vm2"

    # suppress warning/info after every reboot
    "f+ /var/db/sudo/lectured/1000 - - - - -"
  ];
}
