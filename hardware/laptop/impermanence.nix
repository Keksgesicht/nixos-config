{ config, pkgs, ... }:

{
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
        #"/var/lib/containers"
        #"/var/lib/flatpak"
        #"/var/log"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        #"/var/cache/locatedb"
        #"/var/lib/logrotate.status"
        #"/var/lib/rasdaemon/ras-mc_event.db"
      ];
    };

    # /root -> /mnt/main/home/root
    "/mnt/main/home" = {
      hideMounts = true;
      directories = [
      ];
      files = [
        "/root/.zhistory"
      ];
    };
  };
}
