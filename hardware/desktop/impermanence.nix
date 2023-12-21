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
  ];
}
