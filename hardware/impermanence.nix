{ config, lib, pkgs, ... }:

let
  ssd-mnt = "/mnt/main";
  ssd-dev = config.fileSystems."${ssd-mnt}".device;
in
{
  systemd.services = {
    "setup-impermanence-root-volume" = {
      description = "Setup new subvolume for /";
      unitConfig = {
        DefaultDependencies = false;
        RefuseManualStart   = true;
        RefuseManualStop    = true;
      };
      wantedBy = [ "mnt-main.mount" ];
      after    = [ "mnt-main.mount" ];
      before   = [ "-.mount" ];
      path = with pkgs; [
        btrfs-progs
        util-linux
      ];
      script = ''
        TMP_ROOT_DIR="${ssd-mnt}/root"
        BACKUP_DIR="${ssd-mnt}/backup_main/boot/root"

        mkdir -p $BACKUP_DIR
        find $BACKUP_DIR -mindepth 1 -maxdepth 1 -mtime +2 -exec \
          btrfs subvolume delete {} \;
        [ -e $TMP_ROOT_DIR ] && \
          mv $TMP_ROOT_DIR $BACKUP_DIR/$(date +%Y%m%d_%H%M%S)

        btrfs subvolume create $TMP_ROOT_DIR
      '';
    };
  };

  fileSystems = {
    "/" = {
      device = ssd-dev;
      fsType = "btrfs";
      options = [
        "subvol=root"
        "compress=zstd:3"
        "nodev"
        "noexec"
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
}
