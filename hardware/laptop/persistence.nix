{ config, pkgs, ... }:

{
  environment.persistence = {
    # only start with:
    # /etc -> /mnt/cache/etc (BTRFS subvolume)
    # /var -> /mnt/cache/var (BTRFS subvolume)
    "/mnt/cache" = {
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

    # /root -> /home/root -> /mnt/cache/home/root
    "/home" = {
      directories = [
      ];
      files = [
        "/root/.zhistory"
      ];
    };
  };
}
