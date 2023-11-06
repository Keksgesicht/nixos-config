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
        #"/var/nix-serve"
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
    "L+ /mnt/user/etc          - - - - /mnt/cache/etc"
    "L+ /mnt/user/home         - - - - /mnt/cache/home"
    "L+ /mnt/user/var          - - - - /mnt/cache/var"
    # stuff
    "L+ /mnt/user/appdata      - - - - /mnt/cache/appdata"
    "L+ /mnt/user/appdata2     - - - - /mnt/array/appdata2"
    "L+ /mnt/user/appdata3     - - - - /mnt/ram/appdata3"
    "L+ /mnt/user/backup_array - - - - /mnt/array/backup_array"
    "L+ /mnt/user/backup_cache - - - - /mnt/cache/backup_cache"
    "L+ /mnt/user/games        - - - - /mnt/ram/games"
    "L+ /mnt/user/homeBraunJan - - - - /mnt/array/homeBraunJan"
    "L+ /mnt/user/homeGaming   - - - - /mnt/array/homeGaming"
    # additional data
    "L+ /mnt/user/binWin       - - - - /mnt/cache/binWin"
    "L+ /mnt/user/system       - - - - /mnt/cache/system"
    "L+ /mnt/user/resources    - - - - /mnt/array/resources"
    "L+ /mnt/user/vm           - - - - /mnt/cache/vm"
    "L+ /mnt/user/vm2          - - - - /mnt/array/vm2"
  ];
}
