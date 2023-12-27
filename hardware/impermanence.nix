{ config, lib, pkgs, ... }:

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

          mkdir -p $BACKUP_DIR
          find $BACKUP_DIR -mindepth 1 -maxdepth 1 -mtime +2 -exec \
            btrfs subvolume delete {} \;
          [ -e $TMP_ROOT_DIR ] && \
            mv $TMP_ROOT_DIR $BACKUP_DIR/$(date +%Y%m%d_%H%M%S)

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
        "/var/lib/containers"
        "/var/lib/flatpak"
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
        "/var/lib/logrotate.status"
        "/var/lib/rasdaemon/ras-mc_event.db"
        "/var/nix-serve/public-key.pem"
        "/var/nix-serve/secret-key.pem"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "f+ /var/db/sudo/lectured/1000 - - - - -"
  ];
}
