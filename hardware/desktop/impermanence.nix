{ config, pkgs, ... }:

{
  imports = [
    ../impermanence.nix
  ];

  environment.persistence = {
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
